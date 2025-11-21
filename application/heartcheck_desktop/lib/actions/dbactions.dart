import 'dart:io';
import 'package:heartcheck_desktop/windows/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>?> fetchUser(String firebaseUid) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('users')
      .select('firstname, lastname')
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