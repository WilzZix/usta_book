import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/service_model.dart';

abstract class IMasterProfile {
  Future<void> updateMasterProfile(String masterUID, MasterProfile profile);

  Future<MasterProfile?> getMasterProfile(String masterUID);

  Future<List<ServiceModel>> getAvailableServices();
}
