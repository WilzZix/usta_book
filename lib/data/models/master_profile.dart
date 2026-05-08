import 'package:cloud_firestore/cloud_firestore.dart';

class MasterProfile {
  final String name;
  final String? photoURL;
  final String serviceType;
  final Map<String, String> workingHours; // {"mon": "09:00-18:00"}
  final String language;
  final int? totalClients;
  final String? totalEarning;
  final bool profileCompleted;
  final String uid;
  final DateTime? trialStartedAt;
  final DateTime? paidUntil;

  MasterProfile({
    this.uid = '',
    required this.name,
    this.photoURL,
    required this.serviceType,
    required this.workingHours,
    this.totalClients,
    this.totalEarning,
    this.language = 'RU',
    required this.profileCompleted,
    this.trialStartedAt,
    this.paidUntil,
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
    DateTime? trialStartedAt,
    DateTime? paidUntil,
  }) {
    return MasterProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      serviceType: serviceType ?? this.serviceType,
      workingHours: workingHours ?? this.workingHours,
      language: language ?? this.language,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      totalClients: totalClients ?? this.totalClients,
      totalEarning: totalEarning ?? this.totalEarning,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      paidUntil: paidUntil ?? this.paidUntil,
    );
  }

  factory MasterProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    final Map<String, String> workingHoursMap =
        (data['workingHours'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value.toString())) ?? {};

    return MasterProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      photoURL: data['photoURL'] as String?,
      serviceType: data['serviceType'] ?? '',
      workingHours: workingHoursMap,
      language: data['language'] as String? ?? 'RU',
      profileCompleted: data['profile_completed'] ?? false,
      totalClients: data['totalClients'] as int?,
      totalEarning: data['totalEarning'] as String?,
      trialStartedAt: (data['trialStartedAt'] as Timestamp?)?.toDate(),
      paidUntil: (data['paidUntil'] as Timestamp?)?.toDate(),
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

  static const trialDurationDays = 10;

  SubscriptionStatus get subscriptionStatus {
    final now = DateTime.now();
    if (paidUntil != null && paidUntil!.isAfter(now)) return SubscriptionStatus.paid;
    if (trialStartedAt == null) return SubscriptionStatus.notStarted;
    final daysSinceStart = now.difference(trialStartedAt!).inDays;
    return daysSinceStart < trialDurationDays
        ? SubscriptionStatus.trial
        : SubscriptionStatus.expired;
  }

  int get trialDaysRemaining {
    if (trialStartedAt == null) return trialDurationDays;
    final daysSinceStart = DateTime.now().difference(trialStartedAt!).inDays;
    final remaining = trialDurationDays - daysSinceStart;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canCreateRecords {
    final s = subscriptionStatus;
    return s == SubscriptionStatus.trial ||
        s == SubscriptionStatus.paid ||
        s == SubscriptionStatus.notStarted;
  }
}

enum SubscriptionStatus { notStarted, trial, expired, paid }
