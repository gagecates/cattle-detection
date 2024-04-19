import 'package:cattle_detection/firebase_actions.dart';
import 'package:cattle_detection/screens/login.dart';
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
import 'package:permission_handler/permission_handler.dart';

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
    // ask for photo permission on page load
    Permission.photos.request();
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
    String pathObjectDetectionModel = "assets/newest.torchscript";
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
    if (_image == null) {
      showAlertDialog(
          context, 'Woops!', 'Taking longer than expected. Please try again.');
      setState(() {
        message = true;
      });
    }
  }

  Timer scheduleTimeout(int milliseconds) =>
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
    // 30 second timeout if not loading
    scheduleTimeout(30000);

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

    setState(() {
      _image = File(image.path);
      firststate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Align items on each side of the AppBar
          children: <Widget>[
            Text(
              "Cattle Detection", // Centered text
              style: TextStyle(color: Colors.white),
            ),
            Text(
              connectionStatus, // Text on the right
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      // side menu drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.logout), // Icon to display
              title: Text('Log out'),
              onTap: () {
                AuthHelper.logout(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          !firststate
              ? !message
                  ? LoaderState()
                  : Column(
                      children: [
                        Text("Select the icon to detect some cattle!",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // set the cow to complete right side
                          children: [
                            Image.asset(
                              'assets/hiding-cow.webp',
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      ],
                    )
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
