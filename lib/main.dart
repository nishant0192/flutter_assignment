import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'screens/home_screen.dart';
import 'utils/app_constants.dart';
import 'utils/theme_manager.dart';
import 'models/user_profile.dart';
import 'models/cart_manager.dart';
import 'models/order_manager.dart';
import 'models/bookmark_manager.dart';
import 'package:provider/provider.dart';

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
    orderManager.init(),
    bookmarkManager.init(),
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cartManager),
        ChangeNotifierProvider.value(value: orderManager),
        ChangeNotifierProvider.value(value: bookmarkManager),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        final isDark = themeManager.themeMode == ThemeMode.dark ||
            (themeManager.themeMode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Fully transparent
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent, // Match edge-to-edge
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Flutter Assignment',
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            textTheme: GoogleFonts.poppinsTextTheme(),
            scaffoldBackgroundColor: AppColors.bgLight,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            scaffoldBackgroundColor: AppColors.bgDark,
            cardColor: AppColors.cardDark,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
