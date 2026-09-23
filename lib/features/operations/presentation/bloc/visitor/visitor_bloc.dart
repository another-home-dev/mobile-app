import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_visitors_usecase.dart';
import '../../../domain/usecases/request_visitor_usecase.dart';
import 'visitor_event.dart';
import 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final GetVisitorsUseCase getVisitorsUseCase;
  final RequestVisitorUseCase requestVisitorUseCase;

  VisitorBloc({
    required this.getVisitorsUseCase,
    required this.requestVisitorUseCase,
  }) : super(const VisitorInitial()) {
    on<LoadVisitors>(_onLoadVisitors);
    on<SubmitVisitorRequest>(_onSubmitVisitorRequest);
  }

  Future<void> _onLoadVisitors(
    LoadVisitors event,
    Emitter<VisitorState> emit,
  ) async {
    emit(const VisitorLoading());
    try {
      final visitors = await getVisitorsUseCase();
      emit(VisitorLoadSuccess(visitors));
    } catch (e) {
      emit(VisitorFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSubmitVisitorRequest(
    SubmitVisitorRequest event,
    Emitter<VisitorState> emit,
  ) async {
    emit(const VisitorLoading());
    try {
      final visitorRequest = await requestVisitorUseCase(
        roomId: event.roomId,
        visitorName: event.visitorName,
        visitorContact: event.visitorContact,
        purpose: event.purpose,
        visitDate: event.visitDate,
        visitTime: event.visitTime,
      );
      emit(VisitorSubmitSuccess(visitorRequest));
    } catch (e) {
      emit(VisitorFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
