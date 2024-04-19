import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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
