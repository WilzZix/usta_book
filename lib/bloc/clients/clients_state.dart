part of 'clients_bloc.dart';

@immutable
sealed class ClientsState {}

final class ClientsInitial extends ClientsState {}

final class ClientsListLoaded extends ClientsState {
  final List<RecordModel> data;

  ClientsListLoaded({required this.data});
}

final class ClientsListLoading extends ClientsState {}

final class ClientsListLoadError extends ClientsState {
  final String msg;

  ClientsListLoadError({required this.msg});
}
