//TODO Move this to a seperate package
import 'dart:io';

import 'package:process/process.dart';

import 'models/android_device.dart';

class Adb{


  static final RegExp _kDeviceRegex = RegExp(r'^(\S+)\s+(\S+)(.*)');


  static Future<bool> isInstalled() async{
    return LocalProcessManager().canRun("adb");
  }


  static List<AndroidDevice> parseADBDeviceOutput(
      String text) {
    // Check for error messages from adb
    final devices = <AndroidDevice>[];
    if (!text.contains('List of devices')) {
      return devices;
    }

    for (final String line in text.trim().split('\n')) {
      // Skip lines like: * daemon started successfully *
      if (line.startsWith('* daemon ')) {
        continue;
      }

      // Skip lines about adb server and client version not matching
      if (line.startsWith(RegExp(r'adb server (version|is out of date)'))) {
        continue;
      }

      if (line.startsWith('List of devices')) {
        continue;
      }

      if (_kDeviceRegex.hasMatch(line)) {
        final Match match = _kDeviceRegex.firstMatch(line)!;

        final String deviceID = match[1]!;
        final String deviceState = match[2]!;
        String rest = match[3]!;

        final Map<String, String> info = <String, String>{};
        if (rest.isNotEmpty) {
          rest = rest.trim();
          for (final String data in rest.split(' ')) {
            if (data.contains(':')) {
              final List<String> fields = data.split(':');
              info[fields[0]] = fields[1];
            }
          }
        }

        final String? model = info['model'];
        if (model != null) {
          info['model'] = _cleanAdbDeviceName(model);
        }

        if (deviceState == 'unauthorized' || deviceState == 'offline') {
          continue;
        } else {
          devices.add(AndroidDevice(
            deviceID,
            productID: info['product'],
            modelID: info['model'] ?? deviceID,
            deviceCodeName: info['device'],
          ));
        }
      }
    }
    return devices;
  }
  /// Returns available devices
  /// Returns empty list if adb is not installed
  static Future<List<AndroidDevice>> getDevices() async{
    if(!await isInstalled()){
      print("adb is not installed");
      return [];
    }
    final result = await runCommand("devices -l");
    if(result.stderr!= null){
      String text = result.stdout.toString();
      return parseADBDeviceOutput(text);
    }
    return [];
  }

  static Future<ProcessResult> runCommand(String command) async{
      return Process.run("adb", command.split(" "));
  }

  /// Runs adb command on device id
  static Future<ProcessResult> runCommandOnDevice(String deviceId, String command) async {
    final arguments = ["-s",deviceId] + command.split(" ");
    return Process.run("adb",arguments);
  }



  static final RegExp _whitespace = RegExp(r'\s+');

  static String _cleanAdbDeviceName(String name) {
    // Some emulators use `___` in the name as separators.
    name = name.replaceAll('___', ', ');

    // Convert `Nexus_7` / `Nexus_5X` style names to `Nexus 7` ones.
    name = name.replaceAll('_', ' ');

    name = name.replaceAll(_whitespace, ' ').trim();

    return name;
  }
}