import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'control_buttons.dart';

class DriveControl extends StatefulWidget {
  final Color arrowsColor;
  final BluetoothConnection? connection;

  const DriveControl({super.key, required this.arrowsColor, this.connection});

  @override
  _DriveControlState createState() => _DriveControlState();
}

class _DriveControlState extends State<DriveControl> {
  final TextEditingController _textController = TextEditingController();
  Timer? _continuousSendingTimer;

  @override
  void dispose() {
    _textController.dispose();
    _stopContinuousSending();
    super.dispose();
  }

  void _sendBluetoothData(String data) async {
    if (widget.connection != null && widget.connection!.isConnected) {
      try {
        widget.connection!.output.add(Uint8List.fromList(data.codeUnits));
        await widget.connection!.output.allSent; // تأكيد إرسال البيانات
        debugPrint('Data sent: $data');
      } catch (e) {
        debugPrint('Error sending data: $e');
      }
    } else {
      debugPrint('Not connected');
    }
  }

  void _startContinuousSending(String data) {
    _stopContinuousSending(); // تأكد من إيقاف أي مؤقت آخر قيد العمل

    _continuousSendingTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) {
      _sendBluetoothData(data); // إرسال البيانات بشكل منفصل
    });
  }

  void _stopContinuousSending() {
    _continuousSendingTimer?.cancel(); // إيقاف المؤقت
    _continuousSendingTimer = null;
  }

  Widget _createControlButton({
    required IconData icon,
    double? top,
    double? left,
    double? right,
    double? bottom,
    required VoidCallback onPressed,
    required VoidCallback onLongPress,
    required VoidCallback onLongPressUp,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: onPressed,
        onLongPressStart: (_) => onLongPress(),
        onLongPressEnd: (_) => onLongPressUp(),
        child: ControlButtons(
          icon: icon,
          height: 65,
          width: 65,
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4D4D4D),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(1),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Created by Majed (@MMFPR)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              // Directional control
              Expanded(child: _buildDirectionalControl()),

              // Y Axis control
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildAxisControl('Y Axis', "2\n", "3\n"),

              // X and Z Axis control
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Expanded(child: _buildXZControls()),

              // Automatic control
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildAutomaticControl(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionalControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.66,
          height: MediaQuery.of(context).size.height * 0.28,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _createControlButton(
                icon: Icons.arrow_drop_up,
                top: 10,
                onPressed: () => _sendBluetoothData("6\n"),
                onLongPress: () => _startContinuousSending("6\n"),
                onLongPressUp: _stopContinuousSending,
              ),
              _createControlButton(
                icon: Icons.arrow_left,
                left: 4,
                onPressed: () => _sendBluetoothData("9\n"),
                onLongPress: () => _startContinuousSending("9\n"),
                onLongPressUp: _stopContinuousSending,
              ),
              _createControlButton(
                icon: Icons.arrow_right,
                right: 4,
                onPressed: () => _sendBluetoothData("8\n"),
                onLongPress: () => _startContinuousSending("8\n"),
                onLongPressUp: _stopContinuousSending,
              ),
              _createControlButton(
                icon: Icons.arrow_drop_down,
                bottom: 10,
                onPressed: () => _sendBluetoothData("7\n"),
                onLongPress: () => _startContinuousSending("7\n"),
                onLongPressUp: _stopContinuousSending,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAxisControl(
      String axis, String rightCommand, String leftCommand) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 0.66,
      height: MediaQuery.of(context).size.height * 0.12,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _createControlButton(
            icon: Icons.arrow_right,
            right: 0,
            onPressed: () => _sendBluetoothData(rightCommand),
            onLongPress: () => _startContinuousSending(rightCommand),
            onLongPressUp: _stopContinuousSending,
          ),
          SizedBox(
            width: 75,
            height: 55,
            child: Center(
              child: Text(
                axis,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          _createControlButton(
            icon: Icons.arrow_left,
            left: 0,
            onPressed: () => _sendBluetoothData(leftCommand),
            onLongPress: () => _startContinuousSending(leftCommand),
            onLongPressUp: _stopContinuousSending,
          ),
        ],
      ),
    );
  }

  Widget _buildXZControls() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSingleAxisControl('X Axis', "0\n", "1\n"),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          _buildKnifeControl('Knife', "10\n", "11\n"),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          _buildSingleAxisControl('Z Axis', "4\n", "5\n"),
        ],
      ),
    );
  }

  Widget _buildSingleAxisControl(
      String axis, String upCommand, String downCommand) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 0.20,
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _createControlButton(
            icon: Icons.arrow_drop_up,
            top: 10,
            onPressed: () => _sendBluetoothData(upCommand),
            onLongPress: () => _startContinuousSending(upCommand),
            onLongPressUp: _stopContinuousSending,
          ),
          SizedBox(
            width: 70,
            height: 48,
            child: Center(
              child: Text(
                axis,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          _createControlButton(
            icon: Icons.arrow_drop_down,
            bottom: 10,
            onPressed: () => _sendBluetoothData(downCommand),
            onLongPress: () => _startContinuousSending(downCommand),
            onLongPressUp: _stopContinuousSending,
          ),
        ],
      ),
    );
  }

  Widget _buildKnifeControl(String axis, String upCommand, String downCommand) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 0.20,
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _createControlButton(
            icon: Icons.keyboard_double_arrow_up_outlined,
            top: 10,
            onPressed: () => _sendBluetoothData(upCommand),
            onLongPress: () {}, // دالة فارغة
            onLongPressUp: () {}, // دالة فارغة
          ),
          SizedBox(
            width: 70,
            height: 48,
            child: Center(
              child: Text(
                axis,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          _createControlButton(
            icon: Icons.keyboard_double_arrow_down_outlined,
            bottom: 10,
            onPressed: () => _sendBluetoothData(downCommand),
            onLongPress: () {}, // دالة فارغة
            onLongPressUp: () {}, // دالة فارغة
          ),
        ],
      ),
    );
  }

  Widget _buildAutomaticControl() {
    return Container(
      padding: const EdgeInsets.all(14),
      width: MediaQuery.of(context).size.width * 0.66,
      height: MediaQuery.of(context).size.height * 0.075,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter value Cm',
                  labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              String value = _textController.text.trim();

              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value before proceeding.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue >= 100) {
                  _sendBluetoothData(value);
                  debugPrint('Value sent: $value');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a value of 100 or more.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              'Auto',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
