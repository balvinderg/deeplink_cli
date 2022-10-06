import 'package:args/command_runner.dart';

import 'commands/devices_command.dart';
import 'commands/run_command.dart';

void main(List<String> arguments) {
  CommandRunner("dh",
      "A utility tools that helps you launch deeplinks on emulators/simulators")
    ..addCommand(RunCommand())
    ..addCommand(DeviceCommand())
    ..run(arguments).catchError((error) {
    });

}
