enum ContactRelationship {
  family,
  friend,
  caregiver,
  doctor,
  nurse,
  other,
}

class ContactModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final ContactRelationship relationship;
  final bool isEmergencyContact;
  final String? profileImage;
  final DateTime createdAt;

  ContactModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.relationship,
    required this.isEmergencyContact,
    this.profileImage,
    required this.createdAt,
  });

  String get relationshipString {
    switch (relationship) {
      case ContactRelationship.family:
        return 'Family';
      case ContactRelationship.friend:
        return 'Friend';
      case ContactRelationship.caregiver:
        return 'Caregiver';
      case ContactRelationship.doctor:
        return 'Doctor';
      case ContactRelationship.nurse:
        return 'Nurse';
      case ContactRelationship.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'relationship': relationship.index,
      'isEmergencyContact': isEmergencyContact ? 1 : 0,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      relationship: ContactRelationship.values[map['relationship']],
      isEmergencyContact: map['isEmergencyContact'] == 1,
      profileImage: map['profileImage'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ContactModel copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    ContactRelationship? relationship,
    bool? isEmergencyContact,
    String? profileImage,
  }) {
    return ContactModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
    );
  }
}
