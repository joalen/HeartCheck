import 'dart:convert';
import 'package:heartcheck_desktop/windows/auth/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> fetchLatestGitHubTag() async {
  final res = await http.get(
    Uri.parse("https://api.github.com/repos/joalen/HeartCheck/tags"),
  );

  final isOk = res.statusCode == 200;
  if (!isOk) return null;

  final List data = json.decode(res.body);
  return data.isEmpty ? null : data.first['name'];
}

class FirebaseRestAuth {
  final String apiKey;

  FirebaseRestAuth({required this.apiKey});

  /// Sign in with email + password
  Future<String?> signIn({required String email, required String password}) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['idToken'] as String;
    } else {
      throw Exception(data['error']['message']);
    }
  }

  /// Sign up
  Future<String?> signUp({required String email, required String password}) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['idToken'] as String;
    } else {
      throw Exception(data['error']['message']);
    }
  }

  // email update (within settings)
  static Future<void> updateFirebaseEmail(String idToken, String newEmail) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${dotenv.env['FIREBASE_API_KEY']}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        'email': newEmail,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to update email: ${data['error']['message']}');
    } else 
    { 
      CurrentUser.instance?.firebaseUid = data['localId'];
      CurrentUser.instance?.email = data['email'];
      CurrentUser.instance?.jwt = data['idToken'];
    }
  }

  // forgot password
  Future<void> passwordReset(String email) async 
  { 
    final supabase = Supabase.instance.client; 
    final user = await supabase.
      from('users')
      .select('email')
      .ilike('email', email.trim())
      .maybeSingle(); 
    
    if (user == null)
    { 
      throw Exception("User not found! Please sign up instead");
    }
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${dotenv.env['FIREBASE_API_KEY']}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send password reset email: ${data['error']['message']}');
    }
  }

  // password update (within settings)
  static Future<void> updateFirebasePassword(String idToken, String newPassword) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${dotenv.env['FIREBASE_API_KEY']}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        'password': newPassword,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${data['error']['message']}');
    } else { 
      CurrentUser.instance?.firebaseUid = data['localId'];
      CurrentUser.instance?.jwt = data['idToken'];
    }
  }

  // Delete account 
  static Future<void> deleteFirebaseUser(String? idToken) async
  { 
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${dotenv.env['FIREBASE_API_KEY']}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to erase your account: ${data['error']['message']}');
    } else { 
      CurrentUser.instance?.firebaseUid = data['localId'];
      CurrentUser.instance?.jwt = data['idToken'];
    }
  }

  // Decode JWT payload and retrieve out the Uid needed to access PostgreSQLDB
  String getUidFromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT');

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    final Map<String, dynamic> payloadMap = json.decode(decoded);
    return payloadMap['sub']; // Firebase UID
  }

  String getEmailFromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT');

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    final Map<String, dynamic> payloadMap = json.decode(decoded);
    return payloadMap['email']; // Firebase UID
  }
}