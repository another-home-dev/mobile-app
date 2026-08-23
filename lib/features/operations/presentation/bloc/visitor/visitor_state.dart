import 'package:another_home/core/network/dtos/operations_models.dart';

abstract class VisitorState {
  const VisitorState();
}

class VisitorInitial extends VisitorState {
  const VisitorInitial();
}

class VisitorLoading extends VisitorState {
  const VisitorLoading();
}

class VisitorSubmitSuccess extends VisitorState {
  final VisitorRequestModel visitorRequest;
  const VisitorSubmitSuccess(this.visitorRequest);
}

class VisitorLoadSuccess extends VisitorState {
  final List<VisitorRequestModel> visitors;
  const VisitorLoadSuccess(this.visitors);
}

class VisitorFailure extends VisitorState {
  final String message;
  const VisitorFailure(this.message);
}
