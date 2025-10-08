class ServiceModel {
  // 1. Unique ID (Document ID)
  final String id;

  // 2. Multilingual Names
  final String nameRu;
  final String nameUz;

  // 3. Other Core Attributes
  final String category;
  final double priceFrom;
  final bool isActive;

  // Constructor
  ServiceModel({
    required this.id,
    required this.nameRu,
    required this.nameUz,
    required this.category,
    required this.priceFrom,
    required this.isActive,
  });

  // 4. Factory Method: Mapping Firestore Data to the Model
  factory ServiceModel.fromFirestore(
      // The raw data map from the Firestore document
      Map<String, dynamic> firestoreData,
      // The document ID, which is separate from the data map
      String documentId,
      ) {
    return ServiceModel(
      id: documentId,
      // Safely access fields, casting to the correct type
      nameRu: firestoreData['name_ru'] as String,
      nameUz: firestoreData['name_uz'] as String,
      category: firestoreData['category'] as String? ?? 'Other', // Handle potential null/missing data
      priceFrom: firestoreData['price_from'] is int // Firestore stores numbers as 'int' or 'double'
          ? (firestoreData['price_from'] as int).toDouble()
          : firestoreData['price_from'] as double? ?? 0.0,
      isActive: firestoreData['is_active'] as bool? ?? true,
    );
  }

  // (Optional) Helper to get the name based on the active language code
  String getName(String langCode) {
    if (langCode == 'uz') {
      return nameUz;
    }
    return nameRu; // Default to Russian or any other default language
  }
}