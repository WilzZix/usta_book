part of 'clients_bloc.dart';

@immutable
sealed class ClientsEvent {}

final class GetClientsEvent extends ClientsEvent {}

final class DeleterClientEvent extends ClientsEvent {
  final RecordModel record;

  DeleterClientEvent({required this.record});
}

final class EditClientEvent extends ClientsEvent {
  final RecordModel record;

  EditClientEvent({required this.record});
}
