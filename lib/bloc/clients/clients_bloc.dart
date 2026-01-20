import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/clients/i_clients.dart';

import '../../data/models/client_model.dart';

part 'clients_event.dart';

part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final IClients clientsRepo;
  final ShredPrefService shredPrefService;

  ClientsBloc(this.clientsRepo, this.shredPrefService) : super(ClientsInitial()) {
    on<GetClientsEvent>(_getClientsEvent);
    on<DeleterClientEvent>(_deleteClientEvent);
    on<EditClientEvent>(_editClientEvent);
  }

  FutureOr<void> _getClientsEvent(GetClientsEvent event, Emitter<ClientsState> emit) async {
    emit(ClientsListLoading());
    try {
      final response = await clientsRepo.getClients(shredPrefService.getMasterUID()!);
      emit(ClientsListLoaded(data: response));
    } catch (e) {
      emit(ClientsListLoadError(msg: e.toString()));
    }
  }

  FutureOr<void> _deleteClientEvent(DeleterClientEvent event, Emitter<ClientsState> emit) async {
    try {
      await clientsRepo.deleteClient(shredPrefService.getMasterUID()!, event.record);
      add(GetClientsEvent());
    } catch (e) {
      emit(ClientsListLoadError(msg: e.toString()));
    }
  }

  FutureOr<void> _editClientEvent(EditClientEvent event, Emitter<ClientsState> emit) async {
    await clientsRepo.editClient(shredPrefService.getMasterUID()!, event.record);
    add(GetClientsEvent());
  }
}
