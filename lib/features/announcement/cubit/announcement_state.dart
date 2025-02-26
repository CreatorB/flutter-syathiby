import 'package:syathiby/features/announcement/model/announcement_model.dart';

abstract class AnnouncementState {}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;

  AnnouncementLoaded(this.announcements);
}

class AnnouncementError extends AnnouncementState {
  final String message;

  AnnouncementError(this.message);
}