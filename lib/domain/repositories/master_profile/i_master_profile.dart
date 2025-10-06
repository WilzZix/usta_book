import 'package:usta_book/data/models/master_profile.dart';

abstract class IMasterProfile {
  Future<void> updateMasterProfile(String masterUID, MasterProfile profile);
}
