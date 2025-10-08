import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/service_model.dart';

import '../repositories/master_profile/i_master_profile.dart';

@LazySingleton()
class MasterProfileUseCase {
  final IMasterProfile masterProfile;

  MasterProfileUseCase({required this.masterProfile});

  Future<void> updateMasterProfile(
    String masterUID,
    MasterProfile profile,
  ) async {
    masterProfile.updateMasterProfile(masterUID, profile);
  }

  Future<List<ServiceModel>> getAvailableServices() async {
    return masterProfile.getAvailableServices();
  }
}
