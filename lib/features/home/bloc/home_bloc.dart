import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../service/attendance_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syathiby/core/utils/logger_util.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AttendanceService _attendanceService;

  HomeBloc({required AttendanceService attendanceService})
      : _attendanceService = attendanceService,
        super(HomeInitial()) {
    on<LoadAttendanceStatus>(_onLoadAttendanceStatus);
    on<LoadPosts>(_onLoadPosts);
    on<SubmitAttendance>(_onSubmitAttendance);
  }

  Future<void> _onLoadAttendanceStatus(
    LoadAttendanceStatus event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final response = await _attendanceService.getStatus();
      if (response.data != null) {
        emit(AttendanceStatusLoaded(
          canCheckIn: response.data['can_check_in'] ?? true,
          todayAttendance: response.data['today_attendance'],
        ));
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadPosts(
    LoadPosts event,
    Emitter<HomeState> emit,
  ) async {
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

  Future<void> _onSubmitAttendance(
    SubmitAttendance event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (event.isCheckIn) {
        await _attendanceService.checkIn(event.latitude, event.longitude);
      } else {
        await _attendanceService.checkOut(event.latitude, event.longitude);
      }
      add(LoadAttendanceStatus());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
