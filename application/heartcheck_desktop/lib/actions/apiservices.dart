import 'dart:convert';
import 'package:HeartCheck/actions/dbactions.dart';
import 'package:HeartCheck/actions/globalmetrics.dart';
import 'package:HeartCheck/windows/auth/login.dart';
import 'package:http/http.dart' as http;
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

Future<Map<String, dynamic>> createPayloadFromMetrics() async 
{ 
  final supabase = Supabase.instance.client;

  const Map<String, String> mappings = {
  'Age': 'age',
  'Sex': 'sex',
  'Cholesterol': 'chol',
  'Resting Blood Pressure': 'bp',
  'Chest Pain': 'cp',
  'Max Heart Rate': 'bpm',
  'ST Depression': 'oldpeak',
  'ST Slope': 'st_slope',
  'Thalassemia': 'thal',
  'Major Vessel Count': 'ca',
  'Exercise Induced Angina': 'exang',
  'Fasting Blood Sugar': 'glucose',
  'CK-MB': 'ck_mb',
  'Troponin': 'troponin',
  'Ejection Fraction': 'ef',
  'Brain Natrieretic Peptide': 'bnp',
  'C-Reactive Protein': 'crp',
  'Resting ECG': 'restecg'
  };

  Map<String, dynamic> payload = {};

  // Iterate over each metric in the GlobalMetrics instance
  for (var metric in GlobalMetrics().metrics) {
    try {
      /*
      final mappingResponse = await supabase
          .from('measurementattributes')
          .select('mapping, fullname')
          .eq('abbreviation', metric.label)
          .maybeSingle(); 
      
      if (mappingResponse == null) {
        throw Exception("Could not retrieve mappings for ${metric.label}");
      }

      // Get the 'mapping' field from the response (assuming it's a map)
      Map<String, dynamic>? mappings = mappingResponse['mapping'] != null
          ? Map<String, dynamic>.from(mappingResponse['mapping'])
          : null;
      */

      final mappingResponse = await supabase 
        .from('measurementattributes')
        .select('mapping')
        .eq('fullname', metric.label)
        .maybeSingle(); 
      if (mappingResponse == null)
      { 
        throw Exception("Could not retrieve mappings for $metric");
      }

      Map<String, String>? mappingsForEnums = mappingResponse['mapping'] != null ? reverseMapping(Map<String, dynamic>.from(mappingResponse['mapping'])) : null;


      String? payloadKey = mappings[metric.label];

      if (payloadKey != null)
      { 
        if (mappingsForEnums != null)
        { 
          payload[payloadKey] = mappingsForEnums[metric.value];
          continue;
        }

        if (metric.label == "Resting Blood Pressure")
        { 
          metric.value = metric.value.split("/")[0];
        }

        payload[payloadKey] = (metric.value == "true" || metric.value == "yes") ? 1 : ((metric.value == "false" || metric.value == "no") ? 0 : int.tryParse(metric.value) ?? 0);
      }

    } catch (e) {
      throw Exception('Error fetching mapping for ${metric.label}: $e');
    }
  }

  payload["sex"] = (await UserSettings.loadUserGender()) == "Male" ? 1 : 0;
  
  // calculate age: 
  int age = DateTime.now().year - DateTime.tryParse(await UserSettings.loadUserDob())!.year;
  payload['age'] = age;

  return payload;
}

Future<String?> fetchPrediction([String? ipaddress, String? devfingerprint]) async 
{ 
  final payload = await createPayloadFromMetrics();
  if (ipaddress != null && devfingerprint != null)
  { 
    final remainingCredits = await retrieveDemoAccountUsage(ipaddress, devfingerprint); 

    if (remainingCredits <= 0)
    { 
      return "Usage reached";
    }
  } else if ((await UserSettings.loadAIRemainingCredits()) == "0")
  { 
    return "Usage reached";
  }
  
  final response = await http.post(
    Uri.parse(const String.fromEnvironment('HFURL')),
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${const String.fromEnvironment('HFTOKEN')}'
    },
    body: json.encode(payload)
  );

  if (response.statusCode == 200)
  { 
    /*
      Payload format (example): 
      {"prediction":1,"probability_no_disease":0.3024,"probability_disease":0.6976,"risk_level":"High Risk","message":"High probability - seek immediate medical attention","simplePrediction":"yes"}
    */

    if (devfingerprint != null && ipaddress != null)
    { 
      await updateDemoAccountAPIUse(ipaddress, devfingerprint);
    }

    await updateAIUsageForUser(CurrentUser.instance!.firebaseUid);

    final Map<String, dynamic> predictionResult = json.decode(response.body);
    return predictionResult['simplePrediction'];
  } else { 
    return "Unavailable";
  }
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
      if (data['error']['message'].contains("EMAIL_NOT_FOUND"))
      { 
        throw Exception("Email not registed! Please create an account");
      } else if (data['error']['message'].contains("INVALID_PASSWORD"))
      { 
        throw Exception("Password invalid! Re-enter password");
      } else if (data['error']['message'].contains("USER_DISABLED"))
      {
        throw Exception("Account disabled! Contact your administrator/vendor of who created your account or create a ticket/issue if registered by normal means");
      } else { 
        throw Exception(data['error']['message']);
      }
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
      'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${const String.fromEnvironment('FIREBASE_API_KEY')}',
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
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${const String.fromEnvironment('FIREBASE_API_KEY')}',
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
      'https://identitytoolkit.googleapis.com/v1/accounts:update?key=${const String.fromEnvironment('FIREBASE_API_KEY')}',
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
      'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${const String.fromEnvironment('FIREBASE_API_KEY')}',
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