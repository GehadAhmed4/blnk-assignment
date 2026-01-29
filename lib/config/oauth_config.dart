/// OAuth 2.0 Configuration
/// DO NOT commit this file to public repositories with real credentials
class GoogleOAuthConfig {
  static const String clientId = '25807717577-fdsg501dptg8at31sqd0i95jfprp3frv.apps.googleusercontent.com';
  static const String clientSecret = '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';
  static const String redirectUrl = 'http://localhost:8080/';
  
  // Google OAuth endpoints
  static const String authorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const String revokeEndpoint = 'https://oauth2.googleapis.com/revoke';
  
  // Scopes required
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/drive',
  ];
}
