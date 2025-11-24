import 'dart:io';
import 'package:heartcheck_desktop/actions/security.dart';
import 'package:heartcheck_desktop/health_metrics.dart';
import 'package:heartcheck_desktop/windows/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, String> reverseMapping(Map<String, dynamic> originalMapping) {
  Map<String, String> reversedMap = {};

  originalMapping.forEach((key, value) {
    reversedMap[value] = key;
  });

  return reversedMap;
}

Future<Map<String, dynamic>?> fetchUser(String firebaseUid) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('users')
      .select()
      .eq('firebaseuid', firebaseUid)
      .maybeSingle();

  return data;
}

Future<void> updateUserEmail(String firebaseUid, String newEmail) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('users')
      .update({'email': newEmail})
      .eq('firebaseuid', firebaseUid);
}

Future<String> uploadProfilePicture(File file) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final filePath = 'profile_pictures/$userId.jpg';

  await supabase.storage
      .from('profile_pictures')
      .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

  return supabase.storage.from('profile_pictures').getPublicUrl(filePath);
}

Future<void> updateProfileImageUrl(String url) async {
  final uid = CurrentUser.instance!.firebaseUid;

  await Supabase.instance.client
      .from("users")
      .update({'profile_url': url})
      .eq("firebaseuid", uid);
}

Future<void> uploadAndSaveProfileImage(File file) async {
  final url = await uploadProfilePicture(file);
  await updateProfileImageUrl(url);
}

Future<void> createUser(String firebaseUid, String email, String firstname, String lastname) async
{
  final supabase = Supabase.instance.client;
  await supabase.from('users').insert({
    'firebaseuid': firebaseUid,
    'email': email,
    'firstname': firstname,
    'lastname': lastname,
    'created_at': DateTime.now().toIso8601String(),
  });
}

Future<void> updateUser(String firebaseUid, Map<String, dynamic> updates) async
{
  final supabase = Supabase.instance.client;

  final allowedFields = 
  [
    'firstname',
    'lastname',
    'email',
    'gender',
    'dob'
  ];

  final safeUpdates = <String, dynamic>{};
  updates.forEach((k, v)
  { 
    if (allowedFields.contains(k))
    {
      safeUpdates[k] = v;
    }
  });

  if (safeUpdates.isEmpty) return; 

  await supabase
    .from('users')
    .update(safeUpdates)
    .eq('firebaseuid', firebaseUid);
}

Future<void> updateTimeSeriesDB(String firebaseUid, String metricName, Map<String, dynamic> updates) async
{
  if ((await UserSettings.loadUserPermissionAccess()) == "4")
  { 
    return;
  }
  
  final supabase = Supabase.instance.client;

  final abbreviationResponse = await supabase
    .from('measurementattributes')
    .select('abbreviation')
    .eq('fullname', metricName)
    .maybeSingle();

  final mappingResponse = await supabase 
    .from('measurementattributes')
    .select('mapping')
    .eq('fullname', metricName)
    .maybeSingle(); 
  

  if (abbreviationResponse == null || abbreviationResponse['abbrieviation'] == null)
  { 
    throw Exception("Metric abbreviation not found for $metricName");
  }

  if (mappingResponse == null)
  { 
    throw Exception("Could not retrieve mappings for $metricName");
  }

  Map<String, String>? mappings = mappingResponse['mapping'] != null ? reverseMapping(Map<String, dynamic>.from(mappingResponse['mapping'])) : null;
  final allowedFields = 
  [
    'value'
  ];

  final safeUpdates = <String, dynamic>{};
  updates.forEach((k, v)
  { 
    if (allowedFields.contains(k))
    {
      if (mappings != null)
      { 
        v = mappings[v.toString().toLowerCase()];
      }

      safeUpdates[k] = v;
    }
  });

  if (safeUpdates.isEmpty) return; 

  await supabase
    .from('measurement_timeseries')
    .update(safeUpdates)
    .eq('firebaseuid', firebaseUid)
    .eq('metric', abbreviationResponse['abbreviation']);
}

Future<void> deleteUser(String firebaseUid) async
{ 
  final supabase = Supabase.instance.client;
  await supabase
    .from('users')
    .delete()
    .eq('firebaseuid', firebaseUid);
}

Future<void> addDemoAccountUser() async 
{ 
  try 
  { 
      final supabase = Supabase.instance.client; 
      await supabase
        .from('demo_ai_usage')
        .insert(await getVisitorInfo());
  } on PostgrestException catch (e)
  { 
    if (e.message.contains('duplicate key value violates unique constraint'))
    { 
      return;
    }
  }

} 

Future<int> retrieveDemoAccountUsage(String ipaddr, String devfgnt) async 
{ 
  final supabase = Supabase.instance.client; 
  final response = await supabase
    .from('demo_ai_usage')
    .select('remaining')
    .eq('ip_addr', ipaddr)
    .eq('device_fingerprint', devfgnt)
    .maybeSingle();

  if (response == null)
  { 
    throw Exception('Failed to retrieve demo account user');
  } else { 
    return response['remaining'];
  }
}

Future<void> updateDemoAccountAPIUse(String ipaddr, String devfgnt) async
{ 
  final supabase = Supabase.instance.client; 
  final retrieveResponse = await supabase
    .from('demo_ai_usage')
    .select('remaining')
    .eq('ip_addr', ipaddr)
    .eq('device_fingerprint', devfgnt)
    .maybeSingle();

  if (retrieveResponse == null)
  { 
    throw Exception('Failed to retrieve demo account API usage credits');
  } else { 
    final remainingCredits = retrieveResponse['remaining'];

    if (remainingCredits - 1 <= 0)
    { 
      return;
    } else 
    { 
      await supabase 
        .from('demo_ai_usage')
        .update({'remaining': (remainingCredits - 1), 'last_used': DateTime.now().toIso8601String()})
        .eq('ip_addr', ipaddr)
        .eq('device_fingerprint', devfgnt);
    }
  }
}

Future<List<HealthMetric>> populateHealthMetricsFromDB(String userUid, List<HealthMetric> healthWidgets) async
{ 
  final supabase = Supabase.instance.client;

  final response = await supabase
    .from('measurement_timeseries')
    .select('metric, value, measured_at')
    .eq('firebaseuid', userUid)
    .order('metric', ascending: true)
    .order('measured_at', ascending: false)
    .limit(100);

  final latestMetricsMap = <String, dynamic>{};
  final trendMap = <String, List<double>>{}; 

  for (final row in response)
  { 
    final metric = row['metric'] as String;
    final mappingResponse = await supabase 
      .from('measurementattributes')
      .select('mapping, fullname')
      .eq('abbreviation', metric)
      .maybeSingle(); 

    if (mappingResponse == null)
    { 
      throw Exception("Could not retrieve mappings for $metric");
    }

    Map<String, dynamic>? mappings = mappingResponse['mapping'] != null ? Map<String, dynamic>.from(mappingResponse['mapping']) : null;
    final val = mappings != null ? mappings[row['value'].toString()] : row['value'];

    if (!latestMetricsMap.containsKey(mappingResponse['fullname']))
    { 
      latestMetricsMap[mappingResponse['fullname']] = row;
    }

    latestMetricsMap[mappingResponse['fullname']]['value'] = val;
    trendMap.putIfAbsent(mappingResponse['fullname'], () => []);
    double numericValue;

    if (val is int)
    { 
      numericValue = val.toDouble();
    } else if (val is double)
    { 
      numericValue = val;
    } else if (val is String && val.contains('/'))
    { 
      numericValue = double.tryParse(val.split("/")[0]) ?? 0;
    } else if (val is String)
    { 
      numericValue = double.tryParse(row['value']) ?? 0;
    } else 
    { 
      numericValue = double.tryParse(val.toString()) ?? 0;
    }

    trendMap[mappingResponse['fullname']]!.add(numericValue);

    latestMetricsMap.putIfAbsent(mappingResponse['fullname'], () => val);
  }

  for (int i = 0; i < healthWidgets.length; i++)
  { 
    final label = healthWidgets[i].label;
    if (latestMetricsMap.containsKey(label))
    { 
      healthWidgets[i] = healthWidgets[i].copyWith(value: latestMetricsMap[label]['value']).copyWith(trend: trendMap[label]!);
    }
  }

  return healthWidgets;
}


class UserSettings
{ 
  
  static Future<String> loadUserFirstName() async { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return user['firstname']?.toString() ?? '';
      }
    }

    return "";
  }

  static Future<String> loadUserLastName() async { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return user['lastname']?.toString() ?? '';
      }
    }

    return "";
  }

  static Future<String> loadUserGender() async 
  { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return '${user['gender']}';
      }
    }

    return "";
  }

  static Future<String> loadUserDob() async 
  { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return '${user['dob']}';
      }
    }

    return "";
  }

  static Future<String> loadUserPermissionAccess() async
  { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return '${user['permission']}';
      }
    }

    return "3";
  }
}