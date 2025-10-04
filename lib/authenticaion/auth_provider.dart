import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Session? _session;
  User? get user => _session?.user;
  bool get isLoggedIn => user != null;

  AuthProvider() {
    // lắng nghe thay đổi session
    supabase.auth.onAuthStateChange.listen((event) {
      _session = event.session;
      notifyListeners();
    });
    _session = supabase.auth.currentSession;
  }

  Future<void> signUp(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> googleSignIn() async {
    const webClientId =
        '200682765749-mg1uvradgam0khfjepck6jlrdto99hct.apps.googleusercontent.com';
    const iosClientId = 'my-ios.apps.googleusercontent.com';
    final scopes = ['email', 'profile'];

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId: webClientId,
      clientId: iosClientId,
    );

    // 🔹 Sign out trước để đảm bảo popup chọn tài khoản luôn hiện
    await googleSignIn.signOut();

    // 🔹 Gọi authenticate() để hiển thị chọn tài khoản
    final googleUser = await googleSignIn.authenticate();

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('No ID Token found.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }
}
