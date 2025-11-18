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
