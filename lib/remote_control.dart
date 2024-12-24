import 'package:cement_robot_v1_4/control_buttons.dart';
import 'package:cement_robot_v1_4/drive_control.dart';
import 'package:flutter/material.dart';
import 'package:cement_robot_v1_4/bluetooth_page.dart'; // إضافة استيراد الصفحة الجديدة

class RemoteControl extends StatefulWidget {
  const RemoteControl({super.key});

  @override
  State<RemoteControl> createState() => _SecondPageState();
}

class _SecondPageState extends State<RemoteControl> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF4D4D4D),
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Remote control',
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
          ),
          backgroundColor: const Color(0xFFFF8C00),
          automaticallyImplyLeading: false,
        ),
        body: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  ControlButtons(
                    icon: Icons.bluetooth,
                    text: "Bluetooth connection",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BluetoothPage()),
                      );
                    },
                  ),
                ],
              ),
              //SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Expanded(
                child: DriveControl(
                    arrowsColor: Color.fromARGB(255, 255, 255, 255)),
              ),
              //SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}
