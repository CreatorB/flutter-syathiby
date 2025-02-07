part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceStatus extends HomeEvent {}

class LoadPosts extends HomeEvent {}

class SubmitAttendance extends HomeEvent {
  final bool isCheckIn;
  final double latitude;
  final double longitude;

  const SubmitAttendance({
    required this.isCheckIn,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [isCheckIn, latitude, longitude];
}