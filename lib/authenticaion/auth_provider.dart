import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Session? _session;
  User? get user => _session?.user;
  bool get isLoggedIn => user != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
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

  // 1) Gửi link đến email
  Future<String?> sendForgotPasswordEmail(String email) async {
  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo:'travelapp://login-callback', // dùng chung callback xác thực
    );
    return null; // null = không lỗi
  } on AuthException catch (e) {
    return e.message;
  } catch (e) {
    return e.toString();
  }
}


  // 2) Xác thực OTP (user nhập code)
  Future<String?> verifyOtpCode(String email, String otpCode) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otpCode,
      );

      _isLoading = false;
      notifyListeners();
      return null; // OTP đúng
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message; // OTP sai / hết hạn
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Mã OTP không hợp lệ.";
    }
  }

  // 3) Đặt mật khẩu mới (chỉ gọi sau verify OTP)
  Future<String?> resetPassword(String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _isLoading = false;
      notifyListeners();
      return null; // Thành công
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Không thể đặt lại mật khẩu.";
    }
  }
}
