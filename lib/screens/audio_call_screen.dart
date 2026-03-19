import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart'; // Added core UIKit back for ZegoUIKitUser
import '../utils/app_constants.dart'; // Import localUserID here

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final TextEditingController _targetUserIdController = TextEditingController();

  @override
  void dispose() {
    _targetUserIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dial Audio Call'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your User ID is: $localUserID",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Share this ID with the other device so they can call you.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _targetUserIdController,
              decoration: const InputDecoration(
                labelText: "Enter Target User ID",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (text) {
                // Trigger rebuild to update the Call Button
                setState(() {});
              },
            ),
            const SizedBox(height: 30),
            // The Button that sends the ring/invitation
            ZegoSendCallInvitationButton(
              isVideoCall: false, // Ensure this is Voice Call only
              resourceID: "zego_data",
              invitees: [
                ZegoUIKitUser(
                  id: _targetUserIdController.text.trim(),
                  name: "User_${_targetUserIdController.text.trim()}",
                ),
              ],
              iconSize: const Size(60, 60),
              buttonSize: const Size(60, 60),
            ),
            const SizedBox(height: 10),
            const Text("Tap to Ring", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
