part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class AttendanceStatusLoaded extends HomeState {
  final bool canCheckIn;
  final Map<String, dynamic>? todayAttendance;

  const AttendanceStatusLoaded({
    required this.canCheckIn,
    this.todayAttendance,
  });

  @override
  List<Object?> get props => [canCheckIn, todayAttendance];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}