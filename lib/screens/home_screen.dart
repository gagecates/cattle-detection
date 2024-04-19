import 'package:cattle_detection/firebase_setup.dart';
import 'package:cattle_detection/system.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:cattle_detection/ui/loader.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true; // Should show choose photo text
  String connectionStatus = '';
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;

  @override
  void initState() {
    super.initState();
    loadModel();
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      // Determine connection status and provider to update appBar
      ConnectivityResult status = _source.keys.toList()[0];
      if (status != ConnectivityResult.none) {
        // If connection is restored, sync with cloud
        syncPhotosWithCloud();
      }
      print("Connection status changed: $status");
      switch (status) {
        case ConnectivityResult.mobile:
          connectionStatus =
              _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          break;
        case ConnectivityResult.wifi:
          connectionStatus =
              _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          break;
        case ConnectivityResult.none:
        default:
          connectionStatus = 'Offline';
      }
      setState(() {});
    });
  }

  // load model from assets
  Future loadModel() async {
    String pathObjectDetectionModel = "assets/best.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 1, 640, 640, // 1 = only one class 'cattle'
          labelPath: "assets/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  void handleTimeout() {
    // callback function to revert back to original state
    setState(() {
      firststate = true;
    });
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  // running detections on image
  Future runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });
    // pick an image from gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // if user cancels, return to displaying select image text
    if (image == null) {
      setState(() {
        message = true;
      });
      return;
    }

    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);
    objDetect.forEach((element) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    });
    // 5 second timeout if not loading
    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cattle Detection",
            style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(connectionStatus,
                  style: TextStyle(fontSize: 16)), // Text on the right side
            ),
          ),
        ],
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          !firststate
              ? !message
                  ? LoaderState()
                  : Text("Select the icon to detect some cattle!",
                      style: TextStyle(fontWeight: FontWeight.bold))
              : Expanded(
                  child: Container(
                      child:
                          _objectModel.renderBoxesOnImage(_image!, objDetect)),
                ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          runObjectDetection();
        },
        child: Icon(Icons.image),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
