import 'dart:async';

import 'package:args/command_runner.dart';

import '../utils/utils.dart';

class DeviceCommand extends Command{

  @override
  FutureOr<void> run() async{
    final devices = await getDevices();
    if(devices.isNotEmpty){
      print("Available devices\n");
    }
    devices.forEach((element) {
      print(element.getName());
    });
  }

  @override
  // TODO: implement description
  String get description => "Lists all the available devices";

  @override
  // TODO: implement name
  String get name => "devices";
}