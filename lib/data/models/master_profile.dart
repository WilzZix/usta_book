import 'package:cloud_firestore/cloud_firestore.dart';

class MasterProfile {
  final String name;
  final String? photoURL;
  final String serviceType;
  final Map<String, String> workingHours; // {"mon": "09:00-18:00"}
  final String language;
  final int totalClients;
  final String totalEarning;
  final bool profileCompleted;
  final String uid; // The Master's User ID
  MasterProfile({
    required this.uid,
    required this.name,
    this.photoURL,
    required this.serviceType,
    required this.workingHours,
    required this.totalClients,
    required this.totalEarning,
    this.language = 'RU',
    required this.profileCompleted,
  });

  MasterProfile copyWith({
    String? uid,
    String? name,
    String? photoURL,
    String? serviceType,
    Map<String, String>? workingHours,
    String? language,
    String? totalEarning,
    int? totalClients,
    bool? profileCompleted,
  }) {
    return MasterProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      // Use photoURL != null ? photoURL : this.photoURL for nullable fields
      photoURL: photoURL ?? this.photoURL,
      serviceType: serviceType ?? this.serviceType,
      workingHours: workingHours ?? this.workingHours,
      language: language ?? this.language,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      totalClients: totalClients ?? this.totalClients,
      totalEarning: totalEarning ?? this.totalEarning,
    );
  }

  factory MasterProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    // Ensure all data types match your model
    final Map<String, String> workingHoursMap =
        (data['workingHours'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value.toString())) ?? {};

    return MasterProfile(
      uid: doc.id,
      // UID is typically the Document ID in a user-centric collection
      name: data['name'] ?? '',
      serviceType: data['serviceType'] ?? '',
      workingHours: workingHoursMap,
      profileCompleted: data['profile_completed'],
      totalClients: data['totalClients'],
      totalEarning: data['totalEarning'],
      // ... map other fields
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photoURL': photoURL,
      'serviceType': serviceType,
      'workingHours': workingHours,
      'language': language,
      'profile_completed': profileCompleted,
    };
  }
}
