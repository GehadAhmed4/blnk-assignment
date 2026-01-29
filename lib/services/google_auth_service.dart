import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis_auth/googleapis_auth.dart';
// import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _currentUser;
  // AuthClient? _authenticatedClient;

  factory GoogleAuthService() {
    return _instance;
  }

  GoogleAuthService._internal();

  // Get the current signed-in user
  GoogleSignInAccount? get currentUser => _currentUser;

  // Check if user is signed in
  bool get isSignedIn => _currentUser != null;

  // Initialize auth service (check if already signed in)
  Future<void> initialize() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
    } catch (e) {
      print('Error initializing Google Auth: $e');
    }
  }

  // Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      // _authenticatedClient?.close();
      // _authenticatedClient = null;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Create an authenticated client for API calls
  // Future<void> _createAuthenticatedClient() async {
  //   try {
  //     final auth = await _currentUser!.authentication;
  //     _authenticatedClient = authenticatedClient(
  //       http.Client(),
  //       AccessCredentials(
  //         AccessToken(
  //           'Bearer',
  //           auth.accessToken!,
  //           DateTime.now().add(Duration(hours: 1)),
  //         ),
  //         null,
  //         [],
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error creating authenticated client: $e');
  //   }
  // }

  // Get authenticated Drive API client
  // Future<drive.DriveApi?> getDriveApi() async {
  //   if (_authenticatedClient == null) {
  //     await _createAuthenticatedClient();
  //   }
  //   if (_authenticatedClient != null) {
  //     return drive.DriveApi(_authenticatedClient!);
  //   }
  //   return null;
  // }

  /// Get user email
  String? getUserEmail() => _currentUser?.email;

  /// Get user display name
  String? getUserName() => _currentUser?.displayName;
}
