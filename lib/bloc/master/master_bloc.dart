import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/master_profile.dart';
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
  }

  Future<void> _masterProfileUpdate(
    UpdateMasterProfile event,
    Emitter<MasterState> emit,
  ) async {
    await masterProfileUseCase.updateMasterProfile(
      shredPrefService.getMasterUID()!,
      event.masterProfile,
    );
    emit(MasterProfileUpdated());
  }
}
