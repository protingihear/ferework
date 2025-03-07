class Post {
  final int id;
  final String author;
  final String content;

  Post({
    required this.id,
    required this.author,
    required this.content,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      author: json["author"] ?? "Anonymous",
      content: json["content"] ?? "",
    );
  }
}