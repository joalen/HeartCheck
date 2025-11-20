import 'dart:convert';
import 'package:http/http.dart' as http;

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
}