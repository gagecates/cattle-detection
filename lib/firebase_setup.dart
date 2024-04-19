import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> syncPhotosWithCloud() async {
  print("Syncing photos to cloud storage...");

  final directory = await getApplicationDocumentsDirectory();
  final imageDirectory = Directory(directory.path);
  List<File> images =
      imageDirectory.listSync().map((item) => File(item.path)).toList();

  for (File image in images) {
    print("image file $image");
    try {
      String fileName = image.path.split('/').last;
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child('images/$fileName')
          .putFile(image);

      if (snapshot.state == TaskState.success) {
        print("Photo successfully uploaded to firebase storage");
        // Optionally delete the image locally or mark as uploaded
        await image.delete();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

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
