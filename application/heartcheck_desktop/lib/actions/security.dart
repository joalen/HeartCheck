
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:system_info2/system_info2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class FingerprintMethods
{ 
    static Future<String> getDesktopFingerprint() async 
    { 
      final os = Platform.operatingSystem;
      final osVersion = Platform.operatingSystemVersion;
      final hostname = Platform.localHostname; 

      final cpuModel = SysInfo.kernelArchitecture;
      final cpuCores = SysInfo.cores.length;
      final cpuArch = SysInfo.cores.isNotEmpty ? SysInfo.cores[0].architecture : "unknown";
      final cpuName = SysInfo.cores.isNotEmpty ? SysInfo.cores[0].name : "unknown";
      final cpuSocket = SysInfo.cores.isNotEmpty ? SysInfo.cores[0].socket : 0;
      final cpuVendor = SysInfo.cores.isNotEmpty ? SysInfo.cores[0].vendor : "unknown";

      final totalRam = SysInfo.getTotalPhysicalMemory();

      String diskInfo = '';
      try {
        if (Platform.isWindows) {
          final result = await Process.run('wmic', ['diskdrive', 'get', 'SerialNumber']);
          diskInfo = result.stdout.toString().replaceAll(RegExp(r'\s+'), '');
        } else if (Platform.isLinux) {
          final result = await Process.run('lsblk', ['-o', 'NAME,SERIAL,SIZE']);
          diskInfo = result.stdout.toString().replaceAll(RegExp(r'\s+'), '');
        } else if (Platform.isMacOS) {
          final result = await Process.run('system_profiler', ['SPStorageDataType']);
          diskInfo = result.stdout.toString().replaceAll(RegExp(r'\s+'), '');
        }
      } catch (_) {
        diskInfo = 'unknown';
      }

      String macAddresses = '';
      try {
        if (Platform.isWindows) {
          final result = await Process.run('getmac', []);
          macAddresses = result.stdout.toString().replaceAll(RegExp(r'\s+'), '');
        } else {
          final result = await Process.run('ifconfig', []);
          macAddresses = result.stdout.toString().replaceAll(RegExp(r'\s+'), '');
        }
        macAddresses = sha256.convert(utf8.encode(macAddresses)).toString();
      } catch (_) {
        macAddresses = 'unknown';
      }

      final rawDetails = [os, osVersion, hostname, cpuModel, cpuCores, cpuArch, cpuName, cpuSocket, cpuVendor, totalRam, diskInfo, macAddresses].join('|');
      return sha256.convert(utf8.encode(rawDetails)).toString();
    }

    static Future<String> getWebFingerprint() async
    { 
      final deviceInfo = DeviceInfoPlugin();
      final webInfo = await deviceInfo.webBrowserInfo;
      final raw = [
        webInfo.userAgent,
        webInfo.platform,
        webInfo.language,
        webInfo.hardwareConcurrency,
        webInfo.deviceMemory
      ].join('|');

      final hash = sha256.convert(utf8.encode(raw));
      return hash.toString();
    }

    static Future<String> getMobileFingerprint() async 
    { 
      final deviceInfo = DeviceInfoPlugin();
      String deviceSpecificInfo = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceSpecificInfo = [
          androidInfo.id,
          androidInfo.model,
          androidInfo.device,
          androidInfo.product,
          androidInfo.brand,
          androidInfo.manufacturer,
          androidInfo.version.sdkInt,
          androidInfo.version.release,
          androidInfo.hardware,
        ].join('|');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceSpecificInfo = [
          iosInfo.identifierForVendor,
          iosInfo.model,
          iosInfo.name,
          iosInfo.systemName,
          iosInfo.systemVersion,
          iosInfo.utsname.machine,
          iosInfo.utsname.nodename,
          iosInfo.utsname.release,
          iosInfo.utsname.version,
        ].join('|');
      }

      final raw = deviceSpecificInfo;

      final hash = sha256.convert(utf8.encode(raw));
      return hash.toString();
    }
}


Future<String> getDeviceFingerprint() async {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux || Platform.isFuchsia)
  { 
    return FingerprintMethods.getDesktopFingerprint();
  } else if (Platform.isIOS || Platform.isAndroid)
  { 
    return FingerprintMethods.getMobileFingerprint();
  } else if (kIsWeb)
  { 
    return FingerprintMethods.getWebFingerprint();
  }

  return "";
}

Future<String> getPublicIp() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    if (response.statusCode == 200) {
      return response.body.trim();
    }
  } catch (_) {}
  return 'unknown';
}

Future<Map<String, String>> getVisitorInfo() async {
  final ip = await getPublicIp();
  final fingerprint = await getDeviceFingerprint();
  return {
    'ip_addr': ip,
    'device_fingerprint': fingerprint,
  };
}