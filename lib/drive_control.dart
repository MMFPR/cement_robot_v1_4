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

  void _sendBluetoothData(String data) {
    if (widget.connection != null && widget.connection!.isConnected) {
      widget.connection!.output.add(Uint8List.fromList(data.codeUnits));
      widget.connection!.output.allSent.then((_) {
        debugPrint('Data sent: $data');
      });
    } else {
      debugPrint('Not connected');
    }
  }

  void _startContinuousSending(String data) {
    _stopContinuousSending(); // Stop any ongoing timer before starting a new one
    _continuousSendingTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) {
      _sendBluetoothData(data);
    });
  }

  void _stopContinuousSending() {
    _continuousSendingTimer?.cancel();
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
    return Expanded(
      child: Center(
        child: Expanded(
          child: Container(
            padding: const EdgeInsets.all(1),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Directional control
                  Expanded(child: _buildDirectionalControl()),

                  // Y Axis control
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildAxisControl('Y Axis', "6", "7"),

                  // X and Z Axis control
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Expanded(child: _buildXZControls()),

                  // Automatic control
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildAutomaticControl(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  )
                ],
              ),
            ),
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
          child: Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Expanded(
                  child: _createControlButton(
                    icon: Icons.arrow_drop_up,
                    top: 10,
                    onPressed: () => _sendBluetoothData("0"),
                    onLongPress: () => _startContinuousSending("0"),
                    onLongPressUp: _stopContinuousSending,
                  ),
                ),
                Expanded(
                  child: _createControlButton(
                    icon: Icons.arrow_left,
                    left: 4,
                    onPressed: () => _sendBluetoothData("2"),
                    onLongPress: () => _startContinuousSending("2"),
                    onLongPressUp: _stopContinuousSending,
                  ),
                ),
                Expanded(
                  child: _createControlButton(
                    icon: Icons.arrow_right,
                    right: 4,
                    onPressed: () => _sendBluetoothData("3"),
                    onLongPress: () => _startContinuousSending("3"),
                    onLongPressUp: _stopContinuousSending,
                  ),
                ),
                Expanded(
                  child: _createControlButton(
                    icon: Icons.arrow_drop_down,
                    bottom: 10,
                    onPressed: () => _sendBluetoothData("1"),
                    onLongPress: () => _startContinuousSending("1"),
                    onLongPressUp: _stopContinuousSending,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 90,
                    height: 120,
                  ),
                ),
              ],
            ),
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
      child: Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Expanded(
              child: _createControlButton(
                icon: Icons.arrow_right,
                right: 0,
                onPressed: () => _sendBluetoothData(rightCommand),
                onLongPress: () => _startContinuousSending(rightCommand),
                onLongPressUp: _stopContinuousSending,
              ),
            ),
            Expanded(
              child: SizedBox(
                width: 75,
                height: 55,
                child: Center(
                  child: Text(
                    axis,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _createControlButton(
                icon: Icons.arrow_left,
                left: 0,
                onPressed: () => _sendBluetoothData(leftCommand),
                onLongPress: () => _startContinuousSending(leftCommand),
                onLongPressUp: _stopContinuousSending,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXZControls() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSingleAxisControl('X Axis', "4", "5"),
          SizedBox(width: MediaQuery.of(context).size.width * 0.16),
          _buildSingleAxisControl('Z Axis', "8", "9"),
        ],
      ),
    );
  }

  Widget _buildSingleAxisControl(
      String axis, String upCommand, String downCommand) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 2,
        ),
      ),
      child: Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Expanded(
              child: _createControlButton(
                icon: Icons.arrow_drop_up,
                top: 10,
                onPressed: () => _sendBluetoothData(upCommand),
                onLongPress: () => _startContinuousSending(upCommand),
                onLongPressUp: _stopContinuousSending,
              ),
            ),
            const Expanded(child: SizedBox(height: 10)),
            Expanded(
              child: SizedBox(
                width: 70,
                height: 48,
                child: Center(
                  child: Text(
                    axis,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox(height: 10)),
            Expanded(
              child: _createControlButton(
                icon: Icons.arrow_drop_down,
                bottom: 10,
                onPressed: () => _sendBluetoothData(downCommand),
                onLongPress: () => _startContinuousSending(downCommand),
                onLongPressUp: _stopContinuousSending,
              ),
            ),
          ],
        ),
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
      child: Expanded(
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
          Expanded(
            child: ElevatedButton(
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
                backgroundColor:
                    Colors.orange, // تعيين لون الخلفية إلى البرتقالي
              ),
              child: const Text(
                'Auto',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
