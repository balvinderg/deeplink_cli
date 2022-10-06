import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../adb/adb.dart';
import '../adb/models/android_device.dart';
import '../utils/utils.dart';

class RunCommand extends Command {
  @override
  String get description => "Runs a deeplink in all the devices";

  @override
  String get name => "run";

  RunCommand() {
    argParser.addOption("deeplink", abbr: "d", mandatory: true);
  }

  @override
  FutureOr<void> run() async {
    final deeplink = argResults!['deeplink'];
    if (!await Adb.isInstalled()) {
      print("adb not found. Cannot run deeplink on android devices.");
    }
    final devices = await  getDevices();

    for (var element in devices) {
      print("Running deeplink $deeplink on device ${element.getName()}");
      if (element is AndroidDevice) {
        final command =
            "shell am start -a android.intent.action.VIEW -d \"$deeplink\"";
        Adb.runCommandOnDevice(element.id, command);
      } else {
        Process.run(
            "xcrun", "simctl openurl ${element.id} $deeplink".split(" "));
      }
    }
  }
}
