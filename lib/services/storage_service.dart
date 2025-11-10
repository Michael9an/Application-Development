import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadEventImage(
    File imageFile,
    String eventId, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Check file size first
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) { // 5MB limit
        throw Exception('Image file is too large. Please choose an image under 5MB.');
      }

      // Prepare upload metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'eventId': eventId},
      );

      String fileName = 'events/$eventId/${basename(imageFile.path)}';
      final storageRef = _storage.ref(fileName);
      
      // Create the upload task with metadata
      final uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Create a completer to handle timeout
      final uploadCompleter = Completer<String>();
      
      // Handle upload progress
      StreamSubscription? progressSubscription;
      Timer? uploadTimeout;
      
      // Set upload timeout
      uploadTimeout = Timer(Duration(seconds: 30), () {
        progressSubscription?.cancel();
        if (!uploadCompleter.isCompleted) {
          uploadCompleter.completeError(
            TimeoutException('Image upload timed out. Please try again.')
          );
        }
        uploadTask.cancel();
      });

      // Listen to upload progress
      progressSubscription = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);

          // Check if upload is complete
          if (snapshot.state == TaskState.success) {
            uploadTimeout?.cancel();
            progressSubscription?.cancel();
            // Get download URL after successful upload
            storageRef.getDownloadURL().then((url) {
              print('Image uploaded successfully. URL: $url'); // Debug log
              if (!uploadCompleter.isCompleted) {
                uploadCompleter.complete(url);
              }
            }).catchError((e) {
              print('Failed to get download URL: $e'); // Debug log
              if (!uploadCompleter.isCompleted) {
                uploadCompleter.completeError(e);
              }
            });
          }
        },
        onError: (e) {
          print('Upload error: $e'); // Debug log
          uploadTimeout?.cancel();
          progressSubscription?.cancel();
          if (!uploadCompleter.isCompleted) {
            uploadCompleter.completeError(e);
          }
        },
        cancelOnError: true,
      );

      // Wait for upload to complete or timeout
      final downloadUrl = await uploadCompleter.future;
      return downloadUrl;
      
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Return null instead of rethrowing to prevent app crashes
    } finally {
      // Ensure we clean up resources
      onProgress?.call(0);
    }
  }


}