import 'dart:io';
import 'dart:math' show sqrt;
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path_provider/path_provider.dart';

class IdCardProcessor {
  static Future<String?> extractIdCard(String imagePath) async {
    try {
      // Read the original image
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print('Image file not found: $imagePath');
        return null;
      }

      // Read image using opencv_dart
      final mat = cv.imread(imagePath);
      if (mat.isEmpty) {
        print('Failed to read image with OpenCV');
        return null;
      }

      // Convert to grayscale
      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // Apply Gaussian blur to reduce noise
      final blurred = cv.gaussianBlur(gray, (5, 5), 0);

      // Apply Canny edge detection
      final edges = cv.canny(blurred, 50, 150);

      // Find contours
      final (contours, _) = cv.findContours(edges, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);

      if (contours.length == 0) {
        print('No contours found');
        return null;
      }

      // Find the largest rectangular contour (likely the ID card)
      double maxArea = 0;
      cv.VecPoint? largestApprox;

      for (int i = 0; i < contours.length; i++) {
        final contour = contours[i];
        final area = cv.contourArea(contour);
        final perimeter = cv.arcLength(contour, true);
        
        // Approximate contour to reduce points
        final approx = cv.approxPolyDP(contour, 0.02 * perimeter, true);

        // Check if contour is roughly rectangular (4 corners)
        if (approx.length == 4 && area > maxArea) {
          maxArea = area;
          largestApprox = approx;
        }
      }

      if (largestApprox == null) {
        print('No rectangular contour found for ID card');
        // Return original image if no contour found
        return imagePath;
      }

      // Get the perspective transform
      final pts = largestApprox;
      final srcPts = _orderPoints(pts);
      
      final width = _distance(srcPts[0], srcPts[1]).toInt();
      final height = _distance(srcPts[1], srcPts[2]).toInt();

      // Create destination points for perspective transform
      final dstPts = [
        cv.Point(0, 0),
        cv.Point(width, 0),
        cv.Point(width, height),
        cv.Point(0, height),
      ];

      // Convert lists to VecPoint for OpenCV
      final srcVec = cv.VecPoint.fromList(srcPts);
      final dstVec = cv.VecPoint.fromList(dstPts);

      // Get perspective transform matrix
      final m = cv.getPerspectiveTransform(srcVec, dstVec);

      // Apply perspective transform
      final warped = cv.warpPerspective(mat, m, (width, height));

      // Save the extracted image
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extractedPath = '${tempDir.path}/id_card_extracted_$timestamp.jpg';

      cv.imwrite(extractedPath, warped);

      print('ID card extracted successfully: $extractedPath');
      return extractedPath;
    } catch (e) {
      print('Error extracting ID card: $e');
      return null;
    }
  }

  /// Calculate distance between two points
  static double _distance(cv.Point p1, cv.Point p2) {
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    return sqrt((dx * dx + dy * dy).toDouble());
  }

  /// Order points in counter-clockwise order starting from top-left
  static List<cv.Point> _orderPoints(cv.VecPoint points) {
    final pointsList = <cv.Point>[];
    for (int i = 0; i < points.length; i++) {
      pointsList.add(points[i]);
    }
    
    // Sort by x coordinate first
    pointsList.sort((a, b) => a.x.compareTo(b.x));

    // Left points (smallest x values) and right points (largest x values)
    final left = pointsList.sublist(0, 2);
    final right = pointsList.sublist(2, 4);

    // Sort left points by y (top-left, bottom-left)
    left.sort((a, b) => a.y.compareTo(b.y));

    // Sort right points by y (top-right, bottom-right)
    right.sort((a, b) => a.y.compareTo(b.y));

    // Return in order: top-left, top-right, bottom-right, bottom-left
    return [left[0], right[0], right[1], left[1]];
  }
}
