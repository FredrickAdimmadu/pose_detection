import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorProvider extends ChangeNotifier {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    ),
  );

  int jumpingJackCount = 0;
  bool isJumpingJackStarted = false;
  String feedbackMessage = '';

 // Detects the pose from the input image and updates the jumping jack count and feedback message.
  Future<void> detectPose(InputImage inputImage) async {
    try {
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        feedbackMessage = 'No pose detected';
        notifyListeners();
        return;
      }

      final pose = poses.first;

      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
      final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

      if (leftShoulder == null || rightShoulder == null ||
          leftHip == null || rightHip == null ||
          leftAnkle == null || rightAnkle == null) {
        feedbackMessage = 'Incomplete pose detected';
        notifyListeners();
        return;
      }

      if (isJumpingJack(leftShoulder, rightShoulder, leftHip, rightHip, leftAnkle, rightAnkle)) {
        if (!isJumpingJackStarted) {
          jumpingJackCount++;
          isJumpingJackStarted = true;
          feedbackMessage = 'Jumping Jack detected! Count: $jumpingJackCount';
          notifyListeners();
        }
      } else {
        isJumpingJackStarted = false;
        feedbackMessage = 'Adjust your pose to perform a Jumping Jack';
        notifyListeners();
      }
    } catch (e) {
      feedbackMessage = 'Error detecting pose: ${e.toString()}';
      debugPrint(feedbackMessage);
      notifyListeners();
    }
  }

 // Determines if the detected pose corresponds to a jumping jack.
  bool isJumpingJack(PoseLandmark leftShoulder, PoseLandmark rightShoulder,
      PoseLandmark leftHip, PoseLandmark rightHip, PoseLandmark leftAnkle, PoseLandmark rightAnkle) {

    final shoulderDistance = (leftShoulder.x - rightShoulder.x).abs();
    final hipDistance = (leftHip.x - rightHip.x).abs();
    final ankleDistance = (leftAnkle.x - rightAnkle.x).abs();

    // Define criteria for detecting jumping jack more robustly
    final shoulderToHipRatio = shoulderDistance / hipDistance;
    final ankleToHipRatio = ankleDistance / hipDistance;

    // Additional checks for jumping jack movement (optional)
    bool armsUp = leftShoulder.y < leftHip.y && rightShoulder.y < rightHip.y;
    bool legsApart = ankleDistance > hipDistance * 1.5;

    // Adjust these ratios based on testing
    return shoulderToHipRatio > 1.5 && ankleToHipRatio < 2.0 && armsUp && legsApart;
  }


  // Resets the jumping jack counter to zero and feedback message.
  void resetCounter() {
    jumpingJackCount = 0;
    feedbackMessage = 'Counter reset';
    notifyListeners();
  }

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }
}
