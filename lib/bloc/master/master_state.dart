part of 'master_bloc.dart';

@immutable
sealed class MasterState {}

final class MasterInitial extends MasterState {}

class MasterProfileUpdated extends MasterState {}

///Service type
class ServiceTypeLoaded extends MasterState {
  final List<ServiceModel> data;

  ServiceTypeLoaded({required this.data});
}

class ServiceTypeLoadFailure extends MasterState {
  final String msg;

  ServiceTypeLoadFailure({required this.msg});
}
