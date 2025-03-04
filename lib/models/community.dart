class Community {
  final int id;
  final String name;
  final String description;
  final String imageBase64; // Properti ini harus ada

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageBase64,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],  // Perbaikan di sini
      name: json['name'] ?? 'Unknown Name',
      description: json['description'] ?? 'No description available',
      imageBase64: json['foto'] ?? '', // Pastikan sesuai dengan API response
    );
  }
}

