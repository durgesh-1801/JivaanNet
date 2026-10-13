/// Model representing a trusted emergency contact.
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      isPrimary: (map['is_primary'] as int) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ phone.hashCode ^ isPrimary.hashCode;

  @override
  String toString() =>
      'EmergencyContact(id: $id, name: $name, phone: $phone, isPrimary: $isPrimary)';
}
