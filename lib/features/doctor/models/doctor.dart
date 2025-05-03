class Doctor {
  final String id;
  final String name;
  final String type;
  final String rating;
  final String patients;
  final String experience;
  final String reviews;
  final String image;
  final String hospital;

  Doctor({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.patients,
    required this.experience,
    required this.reviews,
    required this.image,
    required this.hospital,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rating': rating,
      'patients': patients,
      'experience': experience,
      'reviews': reviews,
      'image': image,
      'hospital': hospital,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      rating: map['rating'] ?? '',
      patients: map['patients'] ?? '',
      experience: map['experience'] ?? '',
      reviews: map['reviews'] ?? '',
      image: map['image'] ?? '',
      hospital: map['hospital'] ?? '',
    );
  }
}
