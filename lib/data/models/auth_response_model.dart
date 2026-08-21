import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] ?? json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      user: UserModel.fromJson(json['user'] ?? json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}
