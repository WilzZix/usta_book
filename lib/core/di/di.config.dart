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
import 'package:usta_book/data/repositories/sign_up/sign_up_repository.dart'
    as _i633;
import 'package:usta_book/domain/repositories/sign_up/i_sign_up.dart' as _i343;
import 'package:usta_book/domain/usecases/sign_up_usecase.dart' as _i336;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i343.ISignUp>(() => _i633.SignUpRepository());
    gh.factory<_i336.SignUpUseCase>(
      () => _i336.SignUpUseCase(iSignUp: gh<_i343.ISignUp>()),
    );
    return this;
  }
}
