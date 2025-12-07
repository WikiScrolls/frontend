/// Represents the like/save status for an article
class InteractionCheck {
  final bool liked;
  final bool saved;

  const InteractionCheck({
    required this.liked,
    required this.saved,
  });

  factory InteractionCheck.fromJson(Map<String, dynamic> json) => InteractionCheck(
        liked: json['liked'] == true,
        saved: json['saved'] == true,
      );

  Map<String, dynamic> toJson() => {
        'liked': liked,
        'saved': saved,
      };

  InteractionCheck copyWith({bool? liked, bool? saved}) => InteractionCheck(
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
      );
}
