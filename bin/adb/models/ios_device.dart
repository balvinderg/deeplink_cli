import 'device.dart';

class IosDevice extends Device {
  final String modelName;
  final String? state;
  final bool? isAvailable;

  IosDevice(String id,this.modelName, {this.state,this.isAvailable}) : super(id);

  @override
  String getName() {
    return modelName;
  }
}
