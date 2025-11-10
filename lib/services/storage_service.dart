import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import 'firebase_init.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadEventImage(
    File imageFile,
    String eventId, {
    void Function(double progress)? onProgress,
  }) async {
    // Ensure Firebase is initialized before attempting Storage operations.
    final initialized = await ensureFirebaseInitialized(timeout: Duration(seconds: 10));
    if (!initialized) {
      print('uploadEventImage: Firebase not initialized within timeout');
      return null;
    }
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

  /// Resolve a stored bannerUrl into a usable HTTPS download URL.
  ///
  /// Accepts:
  /// - full HTTPS URLs (returned as-is)
  /// - `gs://...` storage URLs (converted via `refFromURL().getDownloadURL()`)
  /// - storage-relative paths like `events/<id>/file.jpg` (resolved with `ref(path).getDownloadURL()`)
  /// - local file paths starting with `/` are returned as-is (for Image.file)
  Future<String?> resolveImageUrl(String? storedUrl, {Duration initTimeout = const Duration(seconds: 10)}) async {
    if (storedUrl == null || storedUrl.isEmpty) return null;

    // Local file path -> return as-is for Image.file
    if (storedUrl.startsWith('/')) return storedUrl;

    // HTTPS already usable
    if (storedUrl.startsWith('http')) return storedUrl;

    // Ensure Firebase initialized before trying to talk to storage
    final ok = await ensureFirebaseInitialized(timeout: initTimeout);
    if (!ok) return null;

    try {
      // gs:// style URL
      if (storedUrl.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(storedUrl);
        return await ref.getDownloadURL();
      }

      // Otherwise treat as a storage path (e.g. events/1234/xyz.jpg)
      final ref = FirebaseStorage.instance.ref(storedUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('resolveImageUrl: failed to resolve $storedUrl -> $e');
      return null;
    }
  }


}