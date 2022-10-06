import 'dart:convert';
import 'dart:io';

import 'package:process/process.dart';

import '../adb/adb.dart';
import '../adb/models/device.dart';
import '../adb/models/ios_device.dart';

Future<List<Device>> getAndroidDevices() async {
  final devices = await Adb.getDevices();
  return devices;
}

Future<List<Device>> getIosDevices() async {
  final hasXcode = LocalProcessManager().canRun("xcrun");
  if (hasXcode) {
    final result = await Process.run(
        "xcrun", "simctl list --json devices available".split(" "));
    final jsonOutput = jsonDecode(result.stdout.toString());
    final iosDevices = (jsonOutput['devices'] as Map).values.map((e) {
      return (e as List)
          .map((e) => IosDevice(e['udid'].toString(), e['name'],
          isAvailable: e['isAvailable'], state: e['state']))
          .toList();
    });

    final filteredDevices = iosDevices
        .expand((element) => element)
        .toList()
        .where((element) =>
    element.isAvailable == true &&
        element.state?.toLowerCase() == 'booted');
    return filteredDevices.toList();
  }
  print("Xcode not found");
  return [];
}
Future<List<Device>> getDevices() async{
  final devices = <Device>[];
  devices.addAll(await getAndroidDevices());
  devices.addAll(await getIosDevices());
  if (devices.isEmpty) {
    print("No device found");
  }
  return devices;
}