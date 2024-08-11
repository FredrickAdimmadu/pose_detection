# Jumping Jacks Counter - Flutter Project


# Overview
This Flutter project implements a Jumping Jacks counter using Google's ML Kit Pose Detection API. The app detects and counts Jumping Jacks performed by the user in real-time using the device's camera. The application also allows users to save their workout summaries, including the number of repetitions, workout duration, and form consistency, to Firebase Firestore.


# Features
1. Real-Time Pose Detection: Utilizes Google's ML Kit to detect body landmarks and identify Jumping Jacks.
2. Workout Session Management: Start, stop, and reset workout sessions with live feedback on form and repetitions.
3. Camera Integration: Accesses the device's camera to capture video frames for pose detection.
4. Firebase Integration: Stores workout summaries in Firebase Firestore, with real-time data retrieval for users.
5. Workout Summary: Displays a history of workout sessions, showing details such as total repetitions, duration, and feedback.



# Project Structure
'PoseDetectorProvider'

1. Pose Detection: This class handles pose detection using Google's ML Kit. It updates the Jumping Jack count and provides feedback based on the user's form.
2. State Management: Implements ChangeNotifier to update the UI with the latest pose detection results.
3. Methods:
   detectPose(InputImage inputImage): Detects the user's pose from an input image and updates the Jumping Jack count.
   isJumpingJack(...): Determines if the detected pose matches the criteria for a Jumping Jack.
   resetCounter(): Resets the Jumping Jack count and feedback message.
   dispose(): Closes the pose detector when no longer needed.

 'WorkoutScreen'
1. Camera Integration: Manages the camera to capture live video frames and processes them using the PoseDetectorProvider.
2. Workout Management: Allows the user to start and stop workout sessions, providing real-time feedback on Jumping Jacks.
3. UI Elements:
   CameraPreview: Displays the camera feed.
   FloatingActionButton: Controls for starting/stopping workouts, saving the workout summary, and resetting the counter.
   Drawer: Navigation drawer for accessing workout history and logging out.

 'WorkoutSummaryScreen'
1. Firebase Integration: Retrieves workout summaries from Firebase Firestore.
2. UI Elements:
      StreamBuilder: Dynamically displays the workout history, updating in real-time.
      Card: Displays each workout summary with details on repetitions, duration, and feedback.

 'Dependencies'
1. flutter: SDK for building the application.
2. google_mlkit_pose_detection: ML Kit package for pose detection.
3. firebase_auth: Firebase Authentication for user management.
4. cloud_firestore: Firebase Firestore for storing workout summaries.
5. camera: Flutter plugin for camera access.
6. provider: State management solution for managing the pose detection state.

 'Usage'
1. Launch the app and log in using Firebase Authentication.
2. Start a workout session by tapping the play button. The app will begin detecting Jumping Jacks in real-time.
3. View the count and feedback on your form as you perform the exercises.
4. Stop the workout session to save your progress. The summary will be stored in Firestore.
5. Access the workout summary from the drawer to view past sessions.


## About the devloper
1. Name: Fredrick Adimmadu.
2. Email: fredyadim@gmail.com
3. LinkedIn: Fredrick Adimmadu
4. Education: Master of science in Advanced Computer Science and Bachelor of science in Computer science.
5. Experience: 8 Years of commercial expeience as a senior full stack developer with various skillsets out of which 6 are Flutter/Dart.
6. Platforms: Android. iOS, Web and Desktop.
7. Others: Google Cloud Platform, Firebase, APIs, Payment gateways (Paypal/Stripe), Node.js, Swift, Java, etc..

