class Community {
  final String name;
  final String description;
  final String imageBase64; // Properti ini harus ada

  Community({required this.name, required this.description, required this.imageBase64});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      name: json['name'] ?? 'Unknown Name',
      description: json['description'] ?? 'No description available',
      imageBase64: json['foto'] ?? '', // Pastikan ini sesuai dengan API response
    );
  }
}
