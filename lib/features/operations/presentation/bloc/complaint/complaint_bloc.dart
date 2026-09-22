import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_incidents_usecase.dart';
import '../../../domain/usecases/report_incident_usecase.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final GetIncidentsUseCase getIncidentsUseCase;
  final ReportIncidentUseCase reportIncidentUseCase;

  ComplaintBloc({
    required this.getIncidentsUseCase,
    required this.reportIncidentUseCase,
  }) : super(const ComplaintInitial()) {
    on<LoadComplaints>(_onLoadComplaints);
    on<SubmitComplaint>(_onSubmitComplaint);
  }

  Future<void> _onLoadComplaints(
    LoadComplaints event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(const ComplaintLoading());
    try {
      final incidents = await getIncidentsUseCase();
      emit(ComplaintLoadSuccess(incidents));
    } catch (e) {
      emit(ComplaintFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSubmitComplaint(
    SubmitComplaint event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(const ComplaintLoading());
    try {
      final incident = await reportIncidentUseCase(
        category: event.category,
        title: event.title,
        description: event.description,
        roomId: event.roomId,
      );
      emit(ComplaintSubmitSuccess(incident));
    } catch (e) {
      emit(ComplaintFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
