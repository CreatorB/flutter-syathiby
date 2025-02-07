// home_view.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/home/service/attendance_service.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/common/widgets/custom_scaffold.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _canCheckIn = true;
  Map<String, dynamic>? _todayAttendance;
  final double latitude = -6.395193286627945;
  final double longitude = 106.96255401126793;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final response = await _attendanceService.getStatus();
      LoggerUtil.debug('Status response: ${response.data}');

      if (response.data != null) {
        setState(() {
          _canCheckIn = response.data['can_check_in'] ?? true;
          _todayAttendance = response.data['today_attendance'];
        });
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

  Future<void> _handleAttendance() async {
    try {
      if (_canCheckIn) {
        await _attendanceService.checkIn(latitude, longitude);
      } else {
        await _attendanceService.checkOut(latitude, longitude);
      }
      _checkStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onRefresh: _checkStatus,
      title: LocaleKeys.home,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(20),
          width: UIHelper.deviceWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Attendance Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleAttendance,
                child: Text(_canCheckIn ? 'Check In' : 'Check Out'),
              ),
            ],
          ),
        ),
        if (_todayAttendance != null)
          Container(
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
                Text('Today\'s Attendance',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text('Check In: ${_todayAttendance!['check_in'] ?? 'Not yet'}'),
                Text(
                    'Check Out: ${_todayAttendance!['check_out'] ?? 'Not yet'}'),
                Text('Status: ${_todayAttendance!['status']}'),
                if (_todayAttendance!['late'] == true)
                  const Text('Status: Late',
                      style: TextStyle(color: Colors.red)),
                if (_todayAttendance!['is_overtime'] == true)
                  const Text('Status: Overtime',
                      style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
      ],
    );
  }
}
