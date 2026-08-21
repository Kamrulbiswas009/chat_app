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
    // If response is wrapped in 'data'
    Map<String, dynamic> root = json;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      root = json['data'] as Map<String, dynamic>;
    }

    // Tokens may be inside 'tokens' or direct properties
    Map<String, dynamic>? tokensMap;
    if (root['tokens'] != null && root['tokens'] is Map<String, dynamic>) {
      tokensMap = root['tokens'] as Map<String, dynamic>;
    } else if (json['tokens'] != null && json['tokens'] is Map<String, dynamic>) {
      tokensMap = json['tokens'] as Map<String, dynamic>;
    }

    final accessToken = tokensMap?['accessToken'] ??
        tokensMap?['access_token'] ??
        tokensMap?['token'] ??
        root['accessToken'] ??
        root['access_token'] ??
        root['token'] ??
        json['accessToken'] ??
        json['access_token'] ??
        json['token'] ??
        '';

    final refreshToken = tokensMap?['refreshToken'] ??
        tokensMap?['refresh_token'] ??
        root['refreshToken'] ??
        root['refresh_token'] ??
        json['refreshToken'] ??
        json['refresh_token'];

    // User may be inside 'user' or direct properties
    Map<String, dynamic> userMap = {};
    if (root['user'] != null && root['user'] is Map<String, dynamic>) {
      userMap = root['user'] as Map<String, dynamic>;
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      userMap = json['user'] as Map<String, dynamic>;
    } else {
      userMap = root;
    }

    return AuthResponseModel(
      accessToken: accessToken.toString(),
      refreshToken: refreshToken?.toString(),
      user: UserModel.fromJson(userMap),
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
