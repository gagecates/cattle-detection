import 'dart:async';
import 'dart:io';
import 'package:cattle_detection/system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_manager/photo_manager.dart';

Future<void> syncPhotosWithCloud() async {
  print("Syncing photos to cloud storage...");

  List<AssetEntity> photos = await fetchPhotos();

  // for each image, convert to file and upload with snapshot results
  for (AssetEntity image in photos) {
    // Requesting the original file data
    File? file = await getFileFromAssetEntity(image);
    if (file != null) {
      try {
        String fileName = path.basename(file.path);
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child('images/$fileName')
            .putFile(file);

        if (snapshot.state == TaskState.success) {
          print("Photo successfully uploaded to firebase storage");
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}

// convert image assets to file
Future<File?> getFileFromAssetEntity(AssetEntity asset) async {
  final file = await asset.file; // Get the file
  if (file != null) {
    // If there's temporary directory needed, you can copy the file to a temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${path.basename(file.path)}');
    await file.copy(tempFile.path);
    return tempFile;
  }
  return null;
}

// upload individual image to cloud
Future<void> uploadImage(XFile image) async {
  final _firebaseStorage = FirebaseStorage.instance;
  var file = File(image.path);
  String fileName = image.path.split('/').last;

  if (image != null) {
    //Upload to Firebase
    var snapshot =
        await _firebaseStorage.ref().child('images/$fileName').putFile(file);
    // var downloadUrl = await snapshot.ref.getDownloadURL();
  } else {
    print('No Image Path Received');
  }
}
