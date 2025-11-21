import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/core/di/di.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> initDi() async {
  getIt.init();

  return getIt.allReady();
}

Future<void> disposeDi() {
  return getIt.reset();
}
