# Cattle Detection

This is a Flutter application that allows users to choose a photo from their camera roll and determine if there is Cattle present in the photo.

It uses a trained YOLOv5 model to detect the cattle in the image with bounding boxes.

![Alt text](<Screenshot 2024-04-19 at 3.02.31 PM.png>)

## Technologies

- Flutter
- YOLOV5
- Firebase

---

## Overview

Once logged in, users may choose from their camera roles images of their choice. If there is an image of a cattle, it will show the bounding box and predictions.

The app monitors online connectivity, if connection is restored or available, all photos are synced to Firebase cloud storage. Otherwise they are saved and kept on the device to allow full offline functionality.

## Run Locally

1. If you do not have flutter installed, [install it](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download) for your system requirements

2. Clone repository
3. Install dependencies

```
flutter pub get
```

4. Run the app

```
flutter run
```

5. Run on emulator or physical device in preferred IDE of Android Studio/Xcode

## Auth

Firebase authentication is used. To run locally, you will need to set up the app to use your firebase project.

[Instructions for flutter](https://firebase.google.com/docs/flutter/setup?platform=ios)

## Train YOLO model

Use Google Colab to easily train model or clone the repo and follow instructions

[YOLO Repo](https://github.com/ultralytics/yolov5)

Use [makesense.ai](https://www.makesense.ai/) to create labels and bounding boxes for all images

YOLO model then converted to torchlite to use with flutter_pytorch plugin. (Follow instructions in convert.py file to change output of model type).

#### Train YOLOv5s on dataset for 50 epochs

\*\*\* edit the custom .yaml file to contain the train/val data file paths as well as class names

```
!python train.py --img 640 --batch 16 --epochs 50 --data custom-data.yaml --weights yolov5s.pt --cache
```

#### Test model

```
!python detect.py --weights runs/train/exp3/weights/best.pt --img 640 --conf 0.25 --source ../dataset/images/train
```

## Build

### Create APK for android release

```
flutter build apk --release
```

### Create IPA (IOS)

```
flutter build ipa
```

## Examples

![Alt text](<Screenshot 2024-04-19 at 5.04.53 PM.png>)

![Alt text](<Screenshot 2024-04-19 at 5.05.03 PM.png>)

![Alt text](<Screenshot 2024-04-19 at 5.04.44 PM.png>)

![Alt text](<Screenshot 2024-04-19 at 3.02.31 PM-1.png>)
