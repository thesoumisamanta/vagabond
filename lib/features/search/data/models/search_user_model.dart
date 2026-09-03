import 'package:vagabond/features/search/domain/entities/search_user.dart';

class SearchUserModel extends SearchUser {
  const SearchUserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePicture,
    required super.accountType,
    required super.isVerified,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    final rawProfilePicture = json['profilePicture'];
    String profilePicUrl = '';
    if (rawProfilePicture is Map) {
      profilePicUrl = rawProfilePicture['url'] ?? '';
    } else if (rawProfilePicture is String) {
      profilePicUrl = rawProfilePicture;
    }

    return SearchUserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: profilePicUrl,
      accountType: json['accountType'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'accountType': accountType,
      'isVerified': isVerified,
    };
  }
}
