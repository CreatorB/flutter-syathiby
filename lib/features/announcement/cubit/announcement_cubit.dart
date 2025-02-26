import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/announcement/cubit/announcement_state.dart';
import 'package:syathiby/features/announcement/service/announcement_service.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementService _service;

  AnnouncementCubit(this._service) : super(AnnouncementInitial());

  Future<void> loadAnnouncements() async {
    try {
      emit(AnnouncementLoading());
      final announcements = await _service.getActiveAnnouncements();
      emit(AnnouncementLoaded(announcements));
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        emit(AnnouncementError('Session expired. Please login again.'));
      } else {
        emit(AnnouncementError(e.toString()));
      }
    }
  }
}