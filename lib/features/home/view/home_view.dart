import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _loadDates();
    _loadPosts();
  }

  Future<String> _getHijriDate() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/gToH?date=${DateFormat('dd-MM-yyyy').format(DateTime.now())}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hijri = data['data']['hijri'];

        // Get month name in English
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

  Future<void> _checkStatus() async {
    try {
      final response = await _attendanceService.getStatus();
      LoggerUtil.debug('Status response: ${response.data}');

      if (response.data != null) {
        setState(() {
          // Explicitly convert to Map<String, dynamic>
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data);

          // Safely check for today's attendance, providing a default empty map if null
          final todayAttendance = responseData['today_attendance'] != null
              ? Map<String, dynamic>.from(responseData['today_attendance'])
              : <String, dynamic>{};

          // Use null-aware operators to safely access values
          final checkIn = todayAttendance['check_in'];
          final checkOut = todayAttendance['check_out'];

          // Jika belum check-out, maka tetap bisa check-out
          if (checkIn != null && checkOut == null) {
            _canCheckIn = false; // Sudah check-in
          } else {
            // Jika sudah check-out atau belum check-in sama sekali
            _canCheckIn = true;
          }

          _todayAttendance = todayAttendance;
        });
      } else {
        // Handle case where response data is null
        setState(() {
          _canCheckIn = true;
          _todayAttendance = null;
        });

        // Optional: Log or show a message about the unexpected response
        LoggerUtil.error('Attendance status response is null');
      }
    } catch (e) {
      if (mounted) {
        LoggerUtil.error('Error checking attendance status', e);

        // Reset to default state
        setState(() {
          _canCheckIn = true;
          _todayAttendance = null;
        });

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
  // Future<void> _checkStatus() async {
  //   try {
  //     final response = await _attendanceService.getStatus();
  //     LoggerUtil.debug('Status response: ${response.data}');

  //     if (response.data != null) {
  //       setState(() {
  //         // Cek apakah sudah check-in dan check-out hari ini
  //         final todayAttendance = response.data['today_attendance'];
  //         final checkIn = todayAttendance['check_in'];
  //         final checkOut = todayAttendance['check_out'];

  //         // Jika belum check-out, maka tetap bisa check-out
  //         if (checkIn != null && checkOut == null) {
  //           _canCheckIn = false; // Sudah check-in
  //         } else {
  //           // Jika sudah check-out atau belum check-in sama sekali
  //           _canCheckIn = true;
  //         }

  //         _todayAttendance = response.data['today_attendance'];
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       LoggerUtil.error('Error checking attendance status', e);
  //       showCupertinoDialog(
  //         context: context,
  //         builder: (context) => CupertinoAlertDialog(
  //           title: const Text('Error'),
  //           content: Text(e.toString()),
  //           actions: [
  //             CupertinoDialogAction(
  //               child: const Text('OK'),
  //               onPressed: () => Navigator.pop(context),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

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
          title: Text(_canCheckIn ? 'Check In' : 'Check Out'),
          content: Text(_canCheckIn
              ? LocaleKeys.are_you_sure_to_check_in_right_now.tr()
              : LocaleKeys.are_you_sure_to_check_out_right_now.tr()),
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

      if (_canCheckIn) {
        await _attendanceService.checkIn(latitude, longitude);
      } else {
        await _attendanceService.checkOut(latitude, longitude);
      }
      _checkStatus();
    } catch (e) {
      if (mounted) {
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
    } finally {
      // Pastikan loading state selalu di-set ke false
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onRefresh: () async {
        await _checkStatus();
        await _loadPosts();
      },
      title: LocaleKeys.home,
      children: [
        // Attendance Section
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
              // Date section at top right
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
              const SizedBox(height: 16),
              // Attendance section
              Center(
                child: Text(
                  'Absen Sekarang',
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
                    : ElevatedButton(
                        onPressed: _handleAttendance,
                        child: Text(_canCheckIn ? 'Check In' : 'Check Out'),
                      ),
              ),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: _handleAttendance,
              //     child: Text(_canCheckIn ? 'Check In' : 'Check Out'),
              //   ),
              // ),
            ],
          ),
        ),
        // Today's Attendance
        if (_todayAttendance != null)
          if (_todayAttendance!['status'] != null)
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

        // News Section Header
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          width: UIHelper.deviceWidth,
          child: Text(
            'Latest Post',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // WordPress Posts
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
