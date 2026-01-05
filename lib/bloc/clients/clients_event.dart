part of 'clients_bloc.dart';

@immutable
sealed class ClientsEvent {}

final class GetClientsEvent extends ClientsEvent {}
