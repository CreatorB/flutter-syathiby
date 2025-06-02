import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/common/helpers/app_helper.dart';
import 'package:syathiby/core/di/injection.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/router/router_manager.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/announcement/cubit/announcement_cubit.dart';
import 'package:syathiby/features/announcement/cubit/announcement_state.dart';
import 'package:syathiby/features/announcement/widget/announcement_widget.dart';
import 'package:syathiby/features/profile/service/user_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/home/service/attendance_service.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/common/widgets/custom_scaffold.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
export 'package:syathiby/features/announcement/cubit/announcement_cubit.dart';
export 'package:syathiby/features/announcement/cubit/announcement_state.dart';
export 'package:syathiby/features/announcement/model/announcement_model.dart';
export 'package:syathiby/features/announcement/service/announcement_service.dart';
export 'package:syathiby/features/announcement/widget/announcement_widget.dart';

class WordPressPost {
  final String title;
  final String content;
  final String date;
  final String link;
  final String thumbnailUrl;

  WordPressPost({
    required this.title,
    required this.content,
    required this.date,
    required this.link,
    required this.thumbnailUrl,
  });

  factory WordPressPost.fromJson(Map<String, dynamic> json) {
    String thumbnailUrl = '';
    if (json['yoast_head_json'] != null &&
        json['yoast_head_json']['schema'] != null &&
        json['yoast_head_json']['schema']['@graph'] != null) {
      for (var item in json['yoast_head_json']['schema']['@graph']) {
        if (item['@type'] == 'Article' && item['thumbnailUrl'] != null) {
          thumbnailUrl = item['thumbnailUrl'];
          break;
        }
      }
    }

    return WordPressPost(
      title: json['title']['rendered'] ?? '',
      content: json['content']['rendered'] ?? '',
      date: json['date'] ?? '',
      link: json['link'] ?? '',
      thumbnailUrl: thumbnailUrl,
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementCubit>()..loadAnnouncements(),
      child: HomeContent(),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final String _baseLocal = dotenv.env['BASE_LOCAL'] ?? "";
  final AttendanceService _attendanceService = AttendanceService();
  final List<WordPressPost> _posts = [];
  bool _canCheckIn = true;
  Map<String, dynamic>? _todayAttendance;
  final double latitude = -6.395193286627945;
  final double longitude = 106.96255401126793;
  String _masehi = '';
  String _hijri = '';
  bool _isLoading = false;
  bool _canCheckOut = false;
  Map<String, dynamic>? _yesterdayIncomplete;
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();
  Map<String, dynamic>? userData;
  HttpResponseModel<dynamic>? apiResponse;
  late String _appVersion;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkStatus();
    _loadDates();
    _loadPosts();
  }

  Future<void> _loadData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String? authToken = await _userService.getAuthTokenFromSP();
    if (authToken != null) {
      final response = await _userService.getUserData(token: authToken);
      setState(() {
        _appVersion = "v${packageInfo.version}";
        apiResponse = response;
        userData =
            response.data is Map ? response.data as Map<String, dynamic> : null;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _getHijriDate() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/gToH?date=${DateFormat('dd-MM-yyyy').format(DateTime.now())}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hijri = data['data']['hijri'];

        final monthName = hijri['month']['en'];

        return '${hijri['day']} $monthName ${hijri['year']} H';
      }
      return '';
    } catch (e) {
      LoggerUtil.error('Error getting Hijri date', e);
      return '';
    }
  }

  Future<void> _loadDates() async {
    setState(() {
      _masehi = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    });
    final hijri = await _getHijriDate();
    if (mounted) {
      setState(() {
        _hijri = hijri;
      });
    }
  }

  String _parseHtmlString(String htmlString) {
    return htmlString
        .replaceAll('&#8217;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&#038;', '&')
        .replaceAll('&#8211;', '-')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  Future<void> _loadPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://syathiby.id/wp-json/wp/v2/posts?per_page=3'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _posts.clear();
          _posts.addAll(
              data.map((post) => WordPressPost.fromJson(post)).toList());
        });
      }
    } catch (e) {
      LoggerUtil.error('Error loading posts', e);
    }
  }

  void _showIncompleteAttendanceDialog() {
    final date = _yesterdayIncomplete?['date'];
    final checkIn = _yesterdayIncomplete?['check_in'];

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Incomplete Attendance'),
        content: Text(
            'Anda memiliki absensi tanggal ${DateFormat('dd MMM yyyy').format(DateTime.parse(date))} '
            'yang belum di-checkout (Check In: ${DateFormat('HH:mm').format(DateTime.parse(checkIn))}). '
            'Silakan checkout terlebih dahulu sebelum melakukan check in hari ini.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _checkStatus() async {
    try {
      final response = await _attendanceService.getStatus();
      LoggerUtil.debug('Status response: ${response.data}');

      if (response.data != null) {
        setState(() {
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data);

          _todayAttendance = responseData['today_attendance'] != null
              ? Map<String, dynamic>.from(responseData['today_attendance'])
              : null;

          _yesterdayIncomplete = responseData['yesterday_incomplete'] != null
              ? Map<String, dynamic>.from(responseData['yesterday_incomplete'])
              : null;

          if (_yesterdayIncomplete != null) {
            _canCheckIn = false;
            _canCheckOut = true;
          } else {
            _canCheckIn = responseData['can_check_in'] ?? false;
            _canCheckOut = responseData['can_check_out'] ?? false;
          }
          LoggerUtil.debug("Yesterday incomplete: $_yesterdayIncomplete");
          LoggerUtil.debug("Can check in: $_canCheckIn");
          LoggerUtil.debug("Can check out: $_canCheckOut");
        });

        if (_yesterdayIncomplete != null && mounted) {
          _showIncompleteAttendanceDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        LoggerUtil.error('Error checking attendance status', e);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> _isConnectedToOfficeNetwork() async {
    try {
      final socket = await Socket.connect(_baseLocal, 80,
          timeout: const Duration(seconds: 2));

      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleAttendance() async {
    bool? confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(_canCheckOut ? 'Check Out' : 'Check In'),
          content: Text(_canCheckOut
              ? LocaleKeys.are_you_sure_to_check_out_right_now.tr()
              : LocaleKeys.are_you_sure_to_check_in_right_now.tr()),
          actions: [
            CupertinoDialogAction(
              child: const Text(LocaleKeys.cancel),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text(LocaleKeys.yes),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool isOfficeNetwork = await _isConnectedToOfficeNetwork();

      if (!isOfficeNetwork) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Warning'),
              content: const Text(
                  'Afwan, fitur absen hanya bisa menggunakan jaringan (WiFi/LAN) Mahad Syathiby.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (_canCheckOut) {
        await _attendanceService.checkOut(latitude, longitude);
      } else {
        await _attendanceService.checkIn(latitude, longitude);
      }
      await _checkStatus();
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title:
                Text(_canCheckOut ? 'Check In Berhasil' : 'Check Out Berhasil'),
            content: Text(_canCheckOut
                ? 'Bismillah, semoga Allah memudahkan urusan-urusan kita dalam kebaikan.'
                : 'Alhamdulillah, semoga Allah memberkahi ikhtiar kita dan mengampuni dosa-dosa kita.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Afwan'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD - Yesterday incomplete: $_yesterdayIncomplete");
    print("BUILD - Can check in: $_canCheckIn");
    print("BUILD - Can check out: $_canCheckOut");
    if (userData == null) {
      return CustomScaffold(
        title: LocaleKeys.home,
        children: [
          Center(
            child: CupertinoActivityIndicator(),
          ),
        ],
      );
    }
    return CustomScaffold(
      onRefresh: () async {
        await context.read<AnnouncementCubit>().loadAnnouncements();
        await _checkStatus();
        await _loadPosts();
      },
      title: LocaleKeys.home,
      scrollController: _scrollController,
      children: [
        BlocBuilder<AnnouncementCubit, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state is AnnouncementError) {
              if (state.message.contains('unauthorized')) {
                SharedPreferencesService.instance
                    .removeData(PreferenceKey.authToken);
                SharedPreferencesService.instance
                    .removeData(PreferenceKey.userData);

                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.login.path, (route) => false);
                }
              }
              return const SizedBox.shrink();
            }

            if (state is AnnouncementLoaded && state.announcements.isNotEmpty) {
              return Column(
                children: state.announcements
                    .map((announcement) => AnnouncementWidget(
                          announcement: announcement,
                        ))
                    .toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(20),
          width: UIHelper.deviceWidth,
          decoration: BoxDecoration(
            color: ColorConstants.lightPrimaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                    children: [
                      TextSpan(text: _masehi),
                      const TextSpan(text: ' / '),
                      TextSpan(text: _hijri),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                    children: [
                      TextSpan(
                          text: '(${userData!['email'] ?? 'Loading ...' } - ${_appVersion})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Ahlan, ${userData?['name']}!',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        children: [
                          if (_yesterdayIncomplete != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Anda belum checkout kemarin (${DateFormat('dd/MM').format(DateTime.parse(_yesterdayIncomplete!['date']))})',
                                      style:
                                          TextStyle(color: Colors.orange[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ElevatedButton(
                            onPressed: _handleAttendance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _yesterdayIncomplete != null || _canCheckOut
                                      ? Colors.orange[800]
                                      : Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              _canCheckOut ? 'CHECK OUT' : 'CHECK IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
        if (_todayAttendance != null)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            width: UIHelper.deviceWidth,
            decoration: BoxDecoration(
              color: ColorConstants.darkPrimaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Attendance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        )),
                const SizedBox(height: 10),
                Text(
                  'Check In: ${_todayAttendance!['check_in'] != null ? DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID').format(DateTime.parse(_todayAttendance!['check_in']).toLocal()) : 'Not yet'}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  'Check Out: ${_todayAttendance!['check_out'] != null ? DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'id_ID').format(DateTime.parse(_todayAttendance!['check_out']).toLocal()) : 'Not yet'}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  'Status: ${_todayAttendance!['status']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
                if (_todayAttendance!['late'] == true)
                  const Text('Status: Late',
                      style: TextStyle(color: Colors.red)),
                if (_todayAttendance!['is_overtime'] == true)
                  const Text('Status: Overtime',
                      style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        if (_yesterdayIncomplete != null)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Text(
                      'ABSENSI BELUM SELESAI',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda belum melakukan checkout pada:',
                  style: TextStyle(color: Colors.orange[800]),
                ),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy')
                      .format(DateTime.parse(_yesterdayIncomplete!['date'])),
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan lakukan checkout terlebih dahulu',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          width: UIHelper.deviceWidth,
          child: Text(
            'Latest Post',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ..._posts
            .map((post) => Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  width: UIHelper.deviceWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.thumbnailUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: post.thumbnailUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _parseHtmlString(post.title),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(post.date),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Read More'),
                        onPressed: () => launchUrl(Uri.parse(post.link)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}
