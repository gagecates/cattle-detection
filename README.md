# Cattle or Not?

This is a Flutter application that allows users to choose a photo from their camera roll and determine if there is
Cattle present in the photo

---

## Technologies

- Flutter
- YOLOV5

---

## Run Locally

1. If you do not have flutter installed, [install it](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=download) for your system requirements

## Step by step https://www.youtube.com/watch?v=GRtgLlwxpc4

- Install Flutter[coco128.yaml](..%2Fcoco128.yaml)
- Download pre-trained YOLO model (Show instructions)

3. Gather images and labels for cattle (Show instructions)

- Images from google. Save for both train and val data folders > dataset/images/train | dataset/images/val etc..
- Use [makesense.ai](https://www.makesense.ai/) to create labels and bounding boxes for all images
- Use YOLOV5 colab to train model https://github.com/ultralytics/yolov5 https://colab.research.google.com/github/ultralytics/yolov5/blob/master/tutorial.ipynb
- Edit yolov5 > data > coco128.yaml to change # of classes, class names, and file paths to dataset
- Train model (50 epochs) saved in yolov5 > runs > train > {exp_train_version}
- Test model (detect) with test image folder/files.

4. Once tested, convert the .pt (pytorch) > .pb model (tensorflow) > .tflite model to use in device
5. Test again with converted model
6. Download the yolo5 foler
7. copy the new best-fp16.tflite model into project > assets > models
8. Add to pubspec.yaml assets
9. Add tflite_flutter to dependencies
10. Run flutter pub get to install depts
11.

### Train YOLOv5s on COCO128 for 3 epochs

```
!python train.py --img 640 --batch 16 --epochs 50 --data custom-data.yaml --weights yolov5s.pt --cache
```

### Test model

```
!python detect.py --weights runs/train/exp3/weights/best.pt --img 640 --conf 0.25 --source ../dataset/images/train
```
