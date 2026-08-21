class ApiConstants {
  // Live Backend URL from Swagger
  static const String defaultBaseUrl = 'https://chat-app-backend-1coz.onrender.com';
  
  // App
  static const String root = '/api/v1';

  // Auth endpoints
  static const String login = '/api/v1/auth/login';
  static const String signup = '/api/v1/auth/signup';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/auth/me';
  static const String refreshToken = '/api/v1/auth/refresh-token';

  // Chat endpoints
  static const String conversations = '/api/v1/chat/conversations';
  static String conversationDetail(String id) => '/api/v1/chat/conversations/$id';
  static String conversationMessages(String id) => '/api/v1/chat/conversations/$id/messages';
  static String messageDetail(String id) => '/api/v1/chat/messages/$id';
  static const String upload = '/api/v1/chat/upload';

  // Users endpoints
  static const String users = '/api/v1/users';
  static String userDetail(String id) => '/api/v1/users/$id';
  static const String userAvatar = '/api/v1/users/avatar';
  static const String userProfile = '/api/v1/users/profile';
  static const String searchUsers = '/api/v1/users/search';
}
