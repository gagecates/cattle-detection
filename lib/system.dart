import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  // listen to changes to connectivity
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  // do test check
  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}

Future<File> saveImageLocally(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final File localImage =
      File('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');

  // Optional: Compress image
  File? result = (await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    localImage.path,
    quality: 88,
  )) as File?;

  // Check if result is not null and is a File, otherwise return the original imageFile
  if (result != null && result is File) {
    // Copy the file to a new path
    return result.copy(localImage
        .path); // return compressed image if compression is successful
  } else {
    return imageFile.copy(localImage.path);
  }
}

// Access all photos to then upload to cloud. Request permission first
Future<List<AssetEntity>> fetchPhotos() async {
  // Request permission
  PermissionStatus permission = await Permission.photos.request();
  if (permission.isGranted) {
    // Fetch albums
    List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    List<AssetEntity> photos = await albums[0]
        .getAssetListPaged(page: 0, size: 100); // Adjust size as needed
    return photos;
  } else {
    PhotoManager.openSetting(); // Open settings if permission denied
    return [];
  }
}
