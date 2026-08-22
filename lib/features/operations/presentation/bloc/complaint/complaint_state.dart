import 'package:another_home/core/network/dtos/operations_models.dart';

abstract class ComplaintState {
  const ComplaintState();
}

class ComplaintInitial extends ComplaintState {
  const ComplaintInitial();
}

class ComplaintLoading extends ComplaintState {
  const ComplaintLoading();
}

class ComplaintSubmitSuccess extends ComplaintState {
  final IncidentModel incident;
  const ComplaintSubmitSuccess(this.incident);
}

class ComplaintLoadSuccess extends ComplaintState {
  final List<IncidentModel> incidents;
  const ComplaintLoadSuccess(this.incidents);
}

class ComplaintFailure extends ComplaintState {
  final String message;
  const ComplaintFailure(this.message);
}
