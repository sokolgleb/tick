import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInAnonymously() async {
    await _client.auth.signInAnonymously();
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.sokolgleb.tick://login-callback',
      );
    } else {
      await _nativeGoogleSignIn();
    }
  }

  Future<void> linkWithGoogle() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      await _client.auth.linkIdentity(OAuthProvider.google);
    } else {
      await _nativeGoogleLink();
    }
  }

  Future<void> _nativeGoogleSignIn() async {
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

    final googleSignIn = GoogleSignIn(
      clientId: iosClientId.isNotEmpty ? iosClientId : null,
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;
    if (idToken == null) throw Exception('No ID token');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> _nativeGoogleLink() async {
    await _client.auth.linkIdentity(OAuthProvider.google);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> linkWithEmail(String email, String password) async {
    await _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  Future<bool> hasData() async {
    final user = currentUser;
    if (user == null) return false;
    final data = await _client
        .from('activities')
        .select('id')
        .limit(1);
    return data.isNotEmpty;
  }

  Future<void> deleteAnonymousData() async {
    await _client.rpc('delete_anonymous_data');
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
