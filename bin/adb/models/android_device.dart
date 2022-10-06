import 'device.dart';

class AndroidDevice extends Device {

  AndroidDevice(String id, {
    this.productID,
    required this.modelID,
    this.deviceCodeName,
  }): super(id);


  final String? productID;
  final String modelID;
  final String? deviceCodeName;

  @override
  String getName() {
    return id;
  }

}