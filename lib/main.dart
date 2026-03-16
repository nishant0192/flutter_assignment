import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'screens/home_screen.dart';
import 'utils/app_constants.dart'; // localUserID is now here

// Please set your AppID and AppSign here
const int zegoAppID = ***REMOVED***;
const String zegoAppSign =
    "***REMOVED***";

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Set the navigator key for Zego Invitation Service
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // 2. Initialize the Zego Invitation Service
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: zegoAppID,
    appSign: zegoAppSign,
    userID: localUserID,
    userName: "User_$localUserID",
    plugins: [ZegoUIKitSignalingPlugin()],
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Assignment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
