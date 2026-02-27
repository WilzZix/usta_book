// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:usta_book/data/repositories/appointment/appointment_repository.dart'
    as _i623;
import 'package:usta_book/data/repositories/clients/clients_repository.dart'
    as _i453;
import 'package:usta_book/data/repositories/master_profile/master_profile.dart'
    as _i972;
import 'package:usta_book/data/repositories/sign_in/sign_in_repository.dart'
    as _i787;
import 'package:usta_book/data/sources/local/shared_pref.dart' as _i858;
import 'package:usta_book/domain/repositories/appointment/i_appointment.dart'
    as _i227;
import 'package:usta_book/domain/repositories/clients/i_clients.dart' as _i729;
import 'package:usta_book/domain/repositories/master_profile/i_master_profile.dart'
    as _i524;
import 'package:usta_book/domain/repositories/sign_in/i_sign_in.dart' as _i465;
import 'package:usta_book/domain/usecases/master_profile_usecase.dart' as _i119;
import 'package:usta_book/domain/usecases/sign_in_usecase.dart' as _i755;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i858.ShredPrefService>(() => _i858.ShredPrefService());
    gh.lazySingleton<_i524.IMasterProfile>(() => _i972.MasterProfileImpl());
    gh.lazySingleton<_i119.MasterProfileUseCase>(
      () =>
          _i119.MasterProfileUseCase(masterProfile: gh<_i524.IMasterProfile>()),
    );
    gh.singleton<_i729.IClients>(() => _i453.ClientsRepository());
    gh.singleton<_i465.ISignIn>(() => _i787.SignInRepository());
    gh.singleton<_i227.IAppointment>(() => _i623.AppointmentRepo());
    gh.factory<_i755.SignInUseCase>(
      () => _i755.SignInUseCase(iSignIn: gh<_i465.ISignIn>()),
    );
    return this;
  }
}
