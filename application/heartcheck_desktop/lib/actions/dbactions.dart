import 'dart:io';
import 'package:heartcheck_desktop/windows/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final response = await supabase
    .from('users')
    .update(safeUpdates)
    .eq('firebaseuid', firebaseUid);

  if (response == null)
  { 
    throw Exception('Failed to update user profile');
  }
}

Future<void> deleteUser(String firebaseUid) async
{ 
  final supabase = Supabase.instance.client;
  final response = await supabase
    .from('users')
    .delete()
    .eq('firebaseuid', firebaseUid);

  if (response == null)
  { 
    throw Exception('Failed to delete account');
  }
}

class UserSettings
{ 
  
  static Future<String> loadUserFirstName() async { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return '${user['firstname']}';
      }
    }

    return "";
  }

  static Future<String> loadUserLastName() async { 
    final uid = CurrentUser.instance?.firebaseUid;
    if (uid != null && uid.isNotEmpty) {
      final user = await fetchUser(uid);
      if (user != null) {
        return '${user['lastname']}';
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
}