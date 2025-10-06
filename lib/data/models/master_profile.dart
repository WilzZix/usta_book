class MasterProfile {
  final String name;
  final String? photoURL;
  final String serviceType;
  final Map<String, String> workingHours; // {"mon": "09:00-18:00"}
  final String language;

  MasterProfile({
    required this.name,
    this.photoURL,
    required this.serviceType,
    required this.workingHours,
    this.language = 'RU',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photoURL': photoURL,
      'serviceType': serviceType,
      'workingHours': workingHours,
      'language': language,
    };
  }
}
