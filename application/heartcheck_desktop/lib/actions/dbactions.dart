import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>?> fetchUser(String firebaseUid) async {
  String supabaseUrl = await dotenv.env['SUPABASE_URL']!;
  String supabaseKey = await dotenv.env['SUPABASE_ANON_KEY']!;

  final uri = Uri.parse(
      '$supabaseUrl/rest/v1/users?firebaseuid=eq.$firebaseUid&select=firstname,lastname');

  final response = await http.get(
    uri,
    headers: {
      'apikey': supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    if (data.isNotEmpty) {
      return data.first as Map<String, dynamic>;
    } else {
      return null; // user not found -- shouldn't happen in any case due to Firebase providing the code to retrieve
    }
  } else {
    throw Exception('Failed to fetch user: ${response.statusCode}');
  }
}

Future<void> updateUserEmail(String firebaseUid, String newEmail) async
{ 
  String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  String? supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  final uri = Uri.parse('$supabaseUrl/rest/v1/users?firebaseuid=eq.$firebaseUid');

  final response = await http.patch( 
    uri, 
    headers: {
      'apikey': ?supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'email': newEmail}),
  );

  if (response.statusCode != 200)
  { 
    throw Exception('Failed to update email in DB: ${response.statusCode}');
  }
}