import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:airsial_app/controllor/zoom_controller.dart';
import 'package:airsial_app/widgets/roundbutton.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../services/base_url.dart';

class ZoomScreen extends StatefulWidget {
  ZoomScreen({super.key, required this.zoomLink, required this.tid});
  int? tid;
  String? zoomLink;

  @override
  State<ZoomScreen> createState() => _ZoomScreenState();
}

class _ZoomScreenState extends State<ZoomScreen> {
  final controller = Get.find<ZoomController>();
  String? folio;
  CameraController? cameraController;
  bool isRecording = false;
  XFile? recordedVideo;
  Timer? recordingTimer;
  var loading = false;

  void checkVideoFormat() {
    if (recordedVideo != null) {
      String videoPath = recordedVideo!.path;
      String videoExtension = path.extension(videoPath).toLowerCase();
      debugPrint('Video format: $videoExtension');
    }
  }

  @override
  void initState() {
    folio = GetStorage().read('folio');
    debugPrint(folio);
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    recordingTimer?.cancel();
    checkVideoFormat();
    super.dispose();
  }

  // void startRecording() async {
  //   final cameras = await availableCameras();
  //   // Find the front camera
  //   final frontCamera = cameras.firstWhere(
  //     (camera) => camera.lensDirection == CameraLensDirection.front,
  //     orElse: () =>
  //         cameras[0], // Use the first camera if front camera is not available
  //   );

  //   cameraController = CameraController(frontCamera, ResolutionPreset.max);
  //   await cameraController?.initialize();

  //   if (!cameraController!.value.isInitialized) {
  //     return;
  //   }

  //   if (cameraController!.value.isRecordingVideo) {
  //     // A recording is already started, do nothing.
  //     return;
  //   }

  //   try {
  //     await cameraController!.startVideoRecording();
  //     setState(() {
  //       isRecording = true;
  //       controller.cameraLodaing.value = true;
  //     });
  //     controller.isVisible.value = false;

  //     print("Recording started");
  //     // Set a timer to stop recording after 5 seconds
  //     // Set a timer to stop recording after 5 seconds
  //     recordingTimer = Timer(Duration(seconds: 4), () {
  //       stopRecording();

  //       controller.pickImage(ImageSource.camera);
  //     });
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //   }
  // }
  void startRecording() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras[0],
    );

    cameraController = CameraController(frontCamera, ResolutionPreset.max);
    await cameraController?.initialize();

    if (!cameraController!.value.isInitialized) {
      return;
    }

    if (cameraController!.value.isRecordingVideo) {
      return;
    }

    // Check if camera permission is granted
    var status = await Permission.camera.status;

    if (status.isGranted) {
      try {
        await cameraController!.startVideoRecording();
        setState(() {
          isRecording = true;
          controller.cameraLodaing.value = true;
        });
        controller.isVisible.value = false;

        recordingTimer = Timer(Duration(seconds: 4), () {
          stopRecording();
          controller.pickImage(ImageSource.camera);
        });
      } catch (e) {
        debugPrint(e.toString());
        // mysnackbar(context, '$e');
      }
    } else if (status.isDenied || status.isRestricted) {
      // Display a dialog or message to the user explaining why the camera permission is required
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Camera Permission Required'),
          content: Text(
            'This app requires access to the camera to record videos. Please grant the camera permission in the app settings.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Open the app settings
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    } else {
      // The user has permanently denied the camera permission or the device does not support it
      debugPrint('Camera access permission denied');
    }
  }

  void stopRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.stopVideoRecording().then((value) {
        recordedVideo = value;
        setState(() {
          isRecording = false;
        });
        controller.isVisible.value = false;
        debugPrint("Recording stopped");

        if (recordedVideo != null) {
          debugPrint("xx ${recordedVideo!.path}");
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       'Video recorded successfully. Path: ${recordedVideo!.path}',
          //     ),
          //   ),
          // );
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    // Cancel the timer if it is still active
    recordingTimer?.cancel();
    controller.isVisible.value = true;
  }

  //// uploadimage api method

  Future<void> uploadImage() async {
    setState(() {
      loading = true;
    });

    if (controller.imagePath.value.isNotEmpty) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${APIConstants.baseURL}FileUploader/UploadImg'),
        );

        request.fields['FileName'] = controller.imageName.value;
        request.fields['FkAgenda'] = widget.tid.toString();
        request.fields['FOLNO'] = folio ?? '';
        request.fields['VideoName'] = "video.mp4";

        var imageFile = await http.MultipartFile.fromPath(
          'file',
          controller.imagePath.value,
        );
        request.files.add(imageFile);

        if (recordedVideo != null) {
          // var compressedVideo = await VideoCompress.compressVideo(
          //   recordedVideo!.path,
          //   quality: VideoQuality.DefaultQuality,
          //   deleteOrigin: false,
          //   includeAudio: false,
          // );

          var videoFile = await http.MultipartFile.fromPath(
            'videofile',
            recordedVideo!.path,
            //compressedVideo!.path!,
            filename: 'video.mp4',
          );
          request.files.add(videoFile);
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            loading = false;
          });

          debugPrint('Image and video uploaded successfully!');

          // Handle Zoom launch
          if (await canLaunch(widget.zoomLink!)) {
            await launch(widget.zoomLink!);
            debugPrint("=======${widget.zoomLink}");
          } else {
            mysnackbar(context, "Could not launch Zoom");
            debugPrint("Failed to launch Zoom web client");
            debugPrint("=======${widget.zoomLink}");

            throw "Could not launch Zoom";
          }
        } else {
          setState(() {
            loading = false;
          });

          // Print response body
          var responseBody = await response.stream.bytesToString();
          debugPrint('Response body: $responseBody');

          debugPrint(
              'Image and video upload failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error uploading image and video: $e');

        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'AIR SIAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(1.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 0),
              Container(
                height: 15.h,
                width: double.infinity,
                color: Colors.grey.withOpacity(0.3),
                child: Center(
                    child: Text(
                  'Attend Meeting By Zoom',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary),
                )),
              ),
              SizedBox(height: 8.h),
              Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      controller.cameraLodaing.value
                          ? Center(
                              child: Container(
                                height: 400,
                                width: double.infinity,
                                color: Colors.black,
                                child: Center(
                                  child: Text(
                                    "Camera being ready plz wait...",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                controller.imagePath.value == ""
                                    ? CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        radius: 80.sp,
                                        child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            radius: 78.sp,
                                            child: Icon(
                                              Icons.camera_alt_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              size: 6.h,
                                            )),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        radius: 80.sp,
                                        child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            radius: 78.sp,
                                            child: ClipOval(
                                                child: Image.file(
                                              File(controller.imagePath.value),
                                              fit: BoxFit.cover,
                                              width: 30.h,
                                              height: 30.h,
                                            )))),
                              ],
                            ),
                    ],
                  )),
              SizedBox(height: 7.h),
              Visibility(
                visible: controller.isVisible.value,
                child: RoundButton(
                  title: "Capture Image",
                  onTap: () async {
                    startRecording();
                  },
                  width: double.infinity,
                  // height: 5.h,
                  textFontSize: 10.sp,
                  backgroundColor: Colors.teal,
                ),
              ),
              SizedBox(height: 2.h),
              Visibility(
                visible: controller.isVisible.value,
                child: RoundButton(
                  loading: loading,
                  title: "Join Meeting",
                  onTap: () async {
                    if (controller.imagePath != '' ||
                        controller.imagePath.value.isNotEmpty) {
                      await uploadImage();
                    } else {
                      mysnackbar(context, "Please capture image first");
                    }
                    // uploadImage();
                    // Get.to(() => VideoPlayerScreen(File(recordedVideo!.path)));
                  },
                  width: double.infinity,
                  // height: 5.h,
                  textFontSize: 12.sp,
                  backgroundColor: Colors.yellow.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackbarController mysnackbar(BuildContext context, String message) {
    return Get.snackbar(
      "Alert", message,
      colorText: Theme.of(context).colorScheme.onPrimary,
      // titleText: Text("Second title"),
      // messageText: Text("Second Messsage"),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      animationDuration: Duration(seconds: 2),
      duration: Duration(seconds: 3),
      borderRadius: 40,
      icon: Icon(
        Icons.notifications,
        size: 20.sp,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      dismissDirection: DismissDirection.horizontal,
      isDismissible: false,
      mainButton: TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          "Done",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      margin: EdgeInsets.all(10),
    );
  }
}
