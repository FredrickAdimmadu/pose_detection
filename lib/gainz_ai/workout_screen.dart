import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pose_detector/gainz_ai/workout_summary.dart';
import 'package:provider/provider.dart';
import '../authentication/loginpage.dart';
import '../helper/dialogs.dart';
import 'pose_detector.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  CameraController? cameraController;
  bool isDetecting = false;
  bool isWorkoutActive = false;
  int workoutStartTime = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      cameraController = CameraController(firstCamera, ResolutionPreset.high);

      await cameraController?.initialize();
      if (!mounted) return; // Ensure the widget is still mounted before calling setState

      cameraController?.startImageStream((image) async {
        if (isDetecting || !isWorkoutActive) return;
        isDetecting = true;

        try {
          final inputImage = getInputImageFromCameraImage(image);
          await context.read<PoseDetectorProvider>().detectPose(inputImage); // Await the async method
        } catch (e) {
          // Handle error in pose detection
          debugPrint('Error in pose detection: $e');
        } finally {
          setState(() {
            isDetecting = false; // Ensure detection flag is reset after processing
          });
        }
      });

      setState(() {});
    } catch (e) {
      // Handle camera initialization error
      print('Error initializing camera: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to initialize camera: $e'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  InputImage getInputImageFromCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Dynamically determine rotation based on device orientation
    final cameraRotation = cameraController!.description.sensorOrientation;
    final InputImageRotation imageRotation;
    switch (cameraRotation) {
      case 90:
        imageRotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        imageRotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        imageRotation = InputImageRotation.rotation270deg;
        break;
      case 0:
      default:
        imageRotation = InputImageRotation.rotation0deg;
        break;
    }

    final InputImageFormat inputImageFormat = InputImageFormat.yuv420;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }


  void _toggleWorkoutSession() {
    setState(() {
      if (isWorkoutActive) {
        // Calculate the duration of the workout when stopping
        final workoutDuration = DateTime.now().millisecondsSinceEpoch - workoutStartTime;
        // Save the workout summary
        _saveWorkoutSummary(workoutDuration);
      } else {
        // Start workout session
        workoutStartTime = DateTime.now().millisecondsSinceEpoch;
      }
      isWorkoutActive = !isWorkoutActive;
    });
  }

  Future<void> _saveWorkoutSummary(int workoutDuration) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case when user is not signed in
      print('No user is signed in');
      return;
    }

    final poseDetector = context.read<PoseDetectorProvider>();
    final workoutSummary = {
      'total_reps': poseDetector.jumpingJackCount,
      'duration': workoutDuration,
      'form_consistency': poseDetector.feedbackMessage, // You may need a more robust measure for form consistency
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('workout_users')
          .doc(user.uid)
          .collection('workout_summary')
          .add(workoutSummary);
      print('Workout summary saved successfully');
      // Remove navigation to WorkoutSummaryScreen here
    } catch (e) {
      print('Error saving workout summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final poseDetector = context.watch<PoseDetectorProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Jumping Jacks Counter'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Workout Summary'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkoutSummaryScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  // Show progress bar
                  Dialogs.showProgressBar(context);
                  try {
                    // Sign out the user
                    await FirebaseAuth.instance.signOut();
                    // Navigate to the login page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } catch (error) {
                    print('Error during logout: $error');
                  } finally {
                    // Close progress dialog
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
        body: cameraController != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(cameraController!),
            Center(
              child: Text(
                'Count: ${poseDetector.jumpingJackCount}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Display feedback message
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  poseDetector.feedbackMessage,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        )
            : Center(child: CircularProgressIndicator()),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () async {
                // Save workout summary when pressed
                final workoutDuration = DateTime.now().millisecondsSinceEpoch - workoutStartTime;
                await _saveWorkoutSummary(workoutDuration);
              },
              child: Icon(Icons.save),
              tooltip: 'Save Workout',
              heroTag: null,
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: _toggleWorkoutSession,
              child: Icon(isWorkoutActive ? Icons.stop : Icons.play_arrow),
              tooltip: isWorkoutActive ? 'Stop Workout' : 'Start Workout',
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: poseDetector.resetCounter,
              child: Icon(Icons.refresh),
              tooltip: 'Reset Counter',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
