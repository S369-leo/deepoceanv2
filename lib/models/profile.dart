class Profile {
  final String id;
  final String name;
  final int age;
  final String gender; // "Male" | "Female" | "Other"
  final String imageUrl;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.imageUrl,
  });
}
