import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'authentication/loginpage.dart';
import 'firebase_options.dart';
import 'gainz_ai/pose_detector.dart';
import 'navigate.dart';

late Size mq;
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set up portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Firebase and other services asynchronously
  await _initializeApp();

  runApp(MyApp());
}

Future<void> _initializeApp() async {
  // Initialization for non-web platforms
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await requestPermissions();
  await Firebase.initializeApp();
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.location,
    Permission.notification,
    Permission.bluetooth,
    Permission.accessMediaLocation,
    Permission.microphone,
    Permission.photos,
    Permission.videos,
    Permission.sensors,
    Permission.activityRecognition,
  ].request();

  if (kDebugMode) {
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PoseDetectorProvider()), // Add your provider here
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return NavigatePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
