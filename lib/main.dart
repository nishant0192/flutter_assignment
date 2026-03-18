import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'screens/home_screen.dart';
import 'utils/app_constants.dart';
import 'models/user_profile.dart';
import 'models/cart_manager.dart';

// Please set your AppID and AppSign here
const int zegoAppID = ***REMOVED***;
const String zegoAppSign =
    "***REMOVED***";

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load cached user profile and cart data
  await Future.wait([
    loadUserProfile(),
    cartManager.loadFromCache(),
  ]);

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

  // 3. Make system status bar edge-to-edge transparent
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Fully transparent
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent, // Match edge-to-edge
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
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
