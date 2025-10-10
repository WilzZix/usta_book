import 'package:bloc/bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/service_model.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/usecases/master_profile_usecase.dart';

part 'master_event.dart';

part 'master_state.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  final MasterProfileUseCase masterProfileUseCase;
  final ShredPrefService shredPrefService;

  MasterBloc(this.masterProfileUseCase, this.shredPrefService)
    : super(MasterInitial()) {
    on<UpdateMasterProfile>(_masterProfileUpdate);
    on<GetMasterProfile>(_getMasterProfile);
    on<GetServiceTypes>(_getServiceTypes);
  }

  Future<void> _masterProfileUpdate(
    UpdateMasterProfile event,
    Emitter<MasterState> emit,
  ) async {
    await masterProfileUseCase.updateMasterProfile(
      shredPrefService.getMasterUID()!,
      event.masterProfile.copyWith(uid: shredPrefService.getMasterUID()),
    );
    emit(MasterProfileUpdated());
  }

  Future<void> _getMasterProfile(
    GetMasterProfile event,
    Emitter<MasterState> emit,
  ) async {
    try {
      MasterProfile? profile = await masterProfileUseCase.getMasterProfile(
        shredPrefService.getMasterUID(),
      );
      emit(MasterProfileLoaded(profile: profile));
    } catch (e) {
      emit(MasterProfileLoadError(msg: e.toString()));
    }
  }

  Future<void> _getServiceTypes(
    GetServiceTypes event,
    Emitter<MasterState> emit,
  ) async {
    try {
      List<ServiceModel> data = await masterProfileUseCase
          .getAvailableServices();
      emit(ServiceTypeLoaded(data: data));
    } catch (e) {
      emit(ServiceTypeLoadFailure(msg: e.toString()));
    }
  }
}
