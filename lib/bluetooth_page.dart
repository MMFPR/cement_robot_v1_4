import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'drive_control.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _bondedDevicesList = [];
  final List<BluetoothDiscoveryResult> _discoveredDevicesList = [];
  BluetoothConnection? _connection;
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions();
  }

  void requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    if (statuses.values.every((status) => status.isGranted)) {
      print('All Bluetooth permissions granted');
      getBondedDevices();
    } else {
      print('Some Bluetooth permissions are denied');
    }
  }

  void getBondedDevices() async {
    try {
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _bondedDevicesList = devices;
      });
      print('Bonded devices: ${_bondedDevicesList.length}');
    } catch (e) {
      print('Error getting bonded devices: $e');
    }
  }

  void startDiscovery() {
    _discoveredDevicesList.clear();
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        _discoveredDevicesList.add(r);
      });
    }).onDone(() {
      print('Discovery finished');
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      _selectedDevice = device;
    });

    try {
      // تأكد من إيقاف الاكتشاف قبل بدء الاتصال
      await FlutterBluetoothSerial.instance.cancelDiscovery();

      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
      });
      print('Connected to the device');

      // قم بنقل الاتصال إلى DriveControl مع الاحتفاظ به
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriveControl(
            arrowsColor: Colors.white,
            connection: _connection!,
          ),
        ),
      );
    } catch (e) {
      print('Error connecting to the device: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: Text('Failed to connect to device: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // لا تقم بإنهاء الاتصال هنا إذا كنت تريد الاستمرار فيه بين الشاشات
    _connection?.dispose();
    _connection = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF4D4D4D),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Bluetooth Page',
            style: TextStyle(color: Colors.white, fontSize: 26),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFF8C00),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startDiscovery,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Discover New Devices'),
                  SizedBox(width: 10),
                  Icon(Icons.search),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount:
                    _bondedDevicesList.length + _discoveredDevicesList.length,
                itemBuilder: (context, index) {
                  if (index < _bondedDevicesList.length) {
                    BluetoothDevice device = _bondedDevicesList[index];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.white),
                      title: Text(
                        device.name ?? 'Unknown Device',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(device.address),
                      onTap: () => connectToDevice(device),
                    );
                  } else {
                    BluetoothDiscoveryResult result = _discoveredDevicesList[
                        index - _bondedDevicesList.length];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.white),
                      title: Text(
                        result.device.name ?? 'Unknown Device',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(result.device.address),
                      onTap: () => connectToDevice(result.device),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
