import 'dart:async';
import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:airsial_app/Pages/News.dart';
import 'package:airsial_app/Pages/ticketing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:airsial_app/Pages/AgendaScreen/Agenda_Meeting.dart';
import 'package:airsial_app/Pages/CommitteeScreen/CommitteListScreen.dart';
import 'package:airsial_app/Pages/MOMScreens/Mintues_of_Meeting.dart';
import 'package:airsial_app/Pages/UpcomingMeetingScreen/Calender_upcoming.dart';
import 'package:airsial_app/Pages/UpcomingMeetingScreen/Upcoming_Meetings.dart';
import 'package:airsial_app/Pages/zoom_screen.dart';
import 'package:airsial_app/widgets/drawer.dart';
import 'package:airsial_app/widgets/greeting.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/news_model.dart';
import '../model/upcomming_meeting_model.dart';
import 'package:http/http.dart' as http;

import '../services/noti_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UpComingMeetingModel>? upcomingMeetings;
  bool dataLoaded = false;
  int timeDifference = 0;
  Timer? timer;

  var mId;
  var mFormatDate;
  var mTime;
  var mTitle;
  var mRmks;
  var mVenue;
  var mTotal;
  bool eventAdded = false;

  final folio = GetStorage().read('folio');
  var _box = GetStorage();

  List<NewsModel> _newsList = [];

  getUpcomingMeetings() async {
    try {
      final response = await http.get(Uri.parse(
          'https://erm.scarletsystems.com:2030/Api/UPComAgenda/GetAll?folno=$folio'));

      if (response.statusCode == 200) {
        debugPrint("API hit successfully: ${response.statusCode}");
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert JSON data to UpComingMeetingModel objects
        List<UpComingMeetingModel> meetings = jsonList
            .map((json) => UpComingMeetingModel.fromJson(json))
            .toList();

        debugPrint('Total Meetings: ${meetings.length}');
        if (meetings.length > 0) {
          List<dynamic> addedEventsCheck =
              await _box.read('addedEvents') ?? ['-1'];
          debugPrint('Event Check Values: ${addedEventsCheck}');
          List<UpComingMeetingModel>? eventFilter = [];

          for (var meeting in meetings) {
            if (!addedEventsCheck.contains(meeting.tid)) {
              // If the meeting tid is not in addedEventsCheck, add it to the eventFilter list
              eventFilter.add(meeting);
              debugPrint('Printttttttttt---------------: ${meeting.tid}');
            }
          }
          debugPrint('Event Filter Value: ${eventFilter}');
          if (eventFilter == null || eventFilter.isEmpty) {
          } else {
            debugPrint('Event Ongoing Value: ${eventFilter.map((e) => e.tid)}');
            buildCalendarDialog(eventFilter);
          }
        }
        // Sort the meetings based on the mdate property
        meetings.sort((a, b) => a.mdate!.compareTo(b.mdate!));
        // Print each meeting's mdate
        for (var meeting in meetings) {
          debugPrint('Meeting Date: ${meeting.mdate}');
        }
        setState(() {
          upcomingMeetings = meetings;
          dataLoaded = true;
        });
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

// isMeetingToday method
  bool isMeetingToday(UpComingMeetingModel meeting) {
    if (meeting.mdate == null) {
      return false; // Return false if mdate is null (no meeting date available)
    }

    // Get the current date without the time part
    DateTime currentDate = DateTime.now();
    DateTime currentOnlyDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Parse the mDate string to a DateTime object and extract the date part
    DateTime meetingDate = DateTime.parse(meeting.mdate!).toLocal();
    DateTime meetingOnlyDate =
        DateTime(meetingDate.year, meetingDate.month, meetingDate.day);

    // Print the dates for debugging
    debugPrint('Current Date: $currentOnlyDate');
    debugPrint('Meeting Date: $meetingOnlyDate');

    // Compare the dates without the time part
    return currentOnlyDate == meetingOnlyDate;
  }

// buildAlertMethod
  Widget buildTodayMeetingAlert(List<UpComingMeetingModel> upcomingMeetings) {
    debugPrint('Upcoming Meetings: $upcomingMeetings');
    bool hasTodayMeeting = upcomingMeetings.any(isMeetingToday);
    debugPrint('Has Today Meeting: $hasTodayMeeting');

    if (hasTodayMeeting) {
      int todayMeetingIndex = upcomingMeetings.indexWhere(isMeetingToday);
      UpComingMeetingModel todayMeeting = upcomingMeetings[todayMeetingIndex];

      final currentTime = DateTime.now();
      final formatter = DateFormat("h:mm");

      // Check the length of mtime to determine the time format
      bool is24HourFormat = todayMeeting.mtime!.length ==
          5; // 'HH:mm' format is 5 characters long

      // Parse the mtime string using the appropriate pattern
      final formatedmtime = is24HourFormat
          ? DateFormat("HH:mm").parse(todayMeeting.mtime!)
          : formatter.parse(todayMeeting.mtime!);

      debugPrint("Current time: ${formatter.format(currentTime)}");
      debugPrint("Mtime formatted: ${formatter.format(formatedmtime)}");

      // Create a DateTime object for the current day with the time from formatedmtime
      DateTime currentTimeWithMtime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        formatedmtime.hour,
        formatedmtime.minute,
      );

      // Calculate the time difference in minutes
      timeDifference = currentTimeWithMtime.difference(currentTime).inMinutes;
      debugPrint('Time Difference Value: $timeDifference');
      final meetTime = todayMeeting.meettime;
      final timePart = meetTime
          ?.split(" ")[1]; // Split the string by space and get the second part

      debugPrint(
          "Meeting Time: ${meetTime?.replaceAll(timePart!, '').trim()} [${timePart}]");
      debugPrint("Meeting Time: ${todayMeeting.meettime.toString()}");

      // Check if the meeting is within 15 minutes from the current time
      if (timeDifference >= 0 || timeDifference <= 180) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 3.5,
                  blurRadius: 6.0,
                )
              ],
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 7.5.h,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today Meeting Alert',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          "Meeting Time: ${meetTime?.replaceAll(timePart!, '').trim()}  [${timePart}]",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //debugPrint(todayMeeting.tid);
                      debugPrint(" zoomLink:${todayMeeting.zM_LINK}");
                      Get.to(
                        () => ZoomScreen(
                          tid: todayMeeting.tid,
                          zoomLink: todayMeeting.zM_LINK,
                        ),
                        transition: Transition.leftToRightWithFade,
                      );
                    },
                    child: Text(
                      "Join Now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Return an empty container if there are no meetings today or the meeting is not within 15 minutes from the current time
    return Container();
  }

  Future<void> addEventToCalendar(
      List<UpComingMeetingModel> meetings, int i) async {
    List<dynamic> addedEvents = await _box.read('addedEvents') ?? ['-1'];
    debugPrint("Added Event Stored Values: ${_box.read("addedEvents")}");
    PermissionStatus status = await Permission.calendar.request();

    mId = meetings[i].tid;
    mTime = meetings[i].mtime;
    mTitle = meetings[i].committe;
    mVenue = meetings[i].venue;
    mRmks = meetings[i].rmks;
    String? dateTimeString = meetings[i].mdate;
    DateTime dateTime = DateTime.parse(dateTimeString!);
    mFormatDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    if (mId != null &&
        mFormatDate != null &&
        mTime != null &&
        mTitle != null &&
        mVenue != null &&
        mRmks != null) {
      DateTime startDate = DateTime.parse(mFormatDate + ' ' + mTime);

      if (status == PermissionStatus.granted) {
        //await checkEventAddedStatus(mId);
        // final bool isEventAdded = _prefs.getBool(mId.toString()) ?? false;
        if (addedEvents.contains(mId)) {
          Fluttertoast.showToast(
              msg: "Event ${i + 1} Already Added To Calendar",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Event event = Event(
            title: '$mTitle',
            description: '$mRmks',
            location: '$mVenue',
            startDate: startDate,
            endDate: startDate.add(Duration(hours: 3)),
            timeZone: DateTime.now().timeZoneName,
          );
          bool success = await Add2Calendar.addEvent2Cal(event);
          if (success) {
            debugPrint('Event added to calendar!');
            _box.write('addedEvents', [..._box.read('addedEvents'), mId]);
            debugPrint("Event Value: ${_box.read("addedEvents")}");
          } else {
            debugPrint('Failed to add event to calendar.');
          }
        }
        // } else {
        //   debugPrint("Event Aready Added");
        //   Fluttertoast.showToast(
        //       msg: "Event ${i+1} Already Added To Calendar",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.green,
        //       textColor: Colors.white,
        //       fontSize: 16.0
        //   );
        // }
      } else {
        debugPrint("Calendar Permission not granted");
        //await checkEventAddedStatus(mId);
        // final bool isEventAdded = await _prefs.getBool(mId.toString()) ?? false;
        // if (!isEventAdded) {
        if (addedEvents.contains(mId)) {
          Fluttertoast.showToast(
              msg: "Event ${i + 1} Already Added To Calendar",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Event event = Event(
            title: '$mTitle',
            description: '$mRmks',
            location: '$mVenue',
            startDate: startDate,
            endDate: startDate.add(Duration(hours: 3)),
            timeZone: DateTime.now().timeZoneName,
          );
          bool success = await Add2Calendar.addEvent2Cal(event);
          if (success) {
            debugPrint('Event added to calendar!');
            _box.write('addedEvents', [..._box.read('addedEvents'), mId]);
            debugPrint("Event Value: ${_box.read("addedEvents")}");
          } else {
            debugPrint('Failed to add event to calendar.');
          }
        }
        //});
        // } else {
        //   debugPrint("Aready Added");
        //   Fluttertoast.showToast(
        //       msg: "Event ${i+1} Already Added To Calendar",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.green,
        //       textColor: Colors.white,
        //       fontSize: 16.0
        //   );
        //}
      }
    } else {
      debugPrint("Some Values are Empty");
    }
  }

  Future<void> buildCalendarDialog(List<UpComingMeetingModel> meetings) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20,
          shadowColor: Colors.indigo,
          //title: Text('${meetings.length} Meeting UpComing'),
          title: Column(
            children: [
              Text('Click Meeting Detail You Want To Add On Calendar',
                  style: TextStyle(fontSize: 18)),
              Divider(
                color: Colors.grey,
                indent: 10,
                endIndent: 10,
              )
            ],
          ),
          //content: Text('Add Them To Calendar'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              physics: ScrollPhysics(),
              itemCount: meetings.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.transparent),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    addEventToCalendar(meetings, index);
                  },
                  child: Stack(children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                spreadRadius: 1,
                                blurRadius: 4)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${meetings[index].committe}"),
                            Text("${meetings[index].venue}"),
                            Text(
                              "${meetings[index].meettime}",
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // AnimatedSwitcher(
                    //   duration: Duration(seconds: 1),
                    //   child: Image.asset(
                    //     imagePaths[currentIndex],
                    //     key: Key(imagePaths[currentIndex]),
                    //     height: 20,
                    //     width: 10,
                    //   ),
                    //   transitionBuilder: (child, animation) {
                    //     return FadeTransition(
                    //       opacity: animation,
                    //       child: SlideTransition(
                    //         position: Tween<Offset>(
                    //           begin: Offset(-0.1, 0.0),
                    //           end: Offset.zero,
                    //         ).animate(animation),
                    //         child: child,
                    //       ),
                    //     );
                    //   },
                    // ),
                    Positioned(
                      right: 35,
                      bottom: 20,
                      child: Image.asset(
                        "assets/images/ad_click.png",
                        height: 30,
                        width: 20,
                        color: Colors.indigo,
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, // Background color
                foregroundColor: Colors.white, // Foreground color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
            // TextButton(
            //   onPressed: () {
            //   for (int i = 0; i < meetings.length; i++ ) {
            //     Timer(Duration(seconds: i==0 ? 0 : 5), () async {
            //       await addEventToCalendar(meetings, i);
            //     });
            //   }
            //   Navigator.pop(context);
            //   },
            //   child: Text(' Add Event '),
            // ),
          ],
        );
      },
    );
  }

  String? name;
  late List<String> nameParts;
  NotificationService notificationService = NotificationService();

  var news;
  var newsBadgeCount;

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://erm.scarletsystems.com:2030/Api/News/GetallNews'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() async {
          _newsList = jsonResponse
              .map((item) => NewsModel.fromJson(item))
              .toList();

          news = _newsList[_newsList.length -1];
          // if (news.tRNO == 4) {
          //   await _box.write('newsList', 2);
          // }
          var newsListCount = _box.read("newsList");
          debugPrint("News Title : ${news.tRNO}");
          if (news.tRNO != newsListCount) {
            setState(() {
              newsBadgeCount = news.tRNO - newsListCount;
            });
            debugPrint("News Length : ${newsBadgeCount}");
          }
        });
      } else {
      }
    } catch (e) {
     throw Exception("Error: $e");
    }
  }

  @override
  void initState() {
    final _box = GetStorage();
    _fetchNews();
    _determinePosition();
    getUpcomingMeetings().then((_) {
      // Check if there are no meetings today and update the UI
      bool hasTodayMeeting = upcomingMeetings!.any(isMeetingToday);
      if (!hasTodayMeeting) {
        setState(() {
          dataLoaded = true;
        });
      }
    });
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      updateUI();
    });

    name = _box.read('shname');
    nameParts = name!.split(' ');
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.foregroundMessage();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.getDeviceToken().then((value) {
      debugPrint('Device Token: ');
      debugPrint(value);
      updateDeviceToken(folio.toString(), value);
    });
  }

  Future<void> updateDeviceToken(String folno, String deviceToken) async {
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://erm.scarletsystems.com:2030/Api/Login/UpdateByid?folno=$folno&token=$deviceToken'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      debugPrint(await response.stream.bytesToString());
      debugPrint('Response success');
    } else {
      debugPrint(response.reasonPhrase);
      debugPrint('Response not/...');
    }
  }

  void updateUI() {
    setState(() {
      // Check if there are no meetings today, or the meeting is not within 15 minutes from the current time, or the meeting time has passed (timeDifference > 15).
      dataLoaded =
          !upcomingMeetings!.any(isMeetingToday) || timeDifference > 15;
    });
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    timer!.cancel();
    super.dispose();
  }

  DateTime? _lastTapTime;

  // Function to show the exit confirmation dialog
  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exit App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        );
      },
    );
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    DateTime currentTime = DateTime.now();
    // If _lastTapTime is null or the difference between currentTime and _lastTapTime is greater than 2 seconds, reset the timer
    if (_lastTapTime == null ||
        currentTime.difference(_lastTapTime!) > Duration(seconds: 2)) {
      _lastTapTime = currentTime;
      _showExitDialog(context);
      return false;
    } else {
      // Exiting the app using SystemNavigator.pop()
      SystemNavigator.pop();
      return true; // Returning true will exit the app
    }
  }

  String _location = '...';
  String _temperature = '__°C';

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   setState(() {
    //     _location = 'Location services are disabled.';
    //   });
    //   return;
    // }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    debugPrint("Location: ${position.latitude}, ${position.longitude}");
    await _fetchWeatherData(position.latitude, position.longitude);
    setState(() {
      _location =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final url =
        'https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=8xmrUrqDDAXhUf4fPWxs9JpVZllIa1N6';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timelines = data['timelines'];
        final daily = timelines['daily'];
        if (daily.isNotEmpty) {
          final lastEntry = daily.last;
          final temperature = lastEntry['values']['temperatureAvg'];
          setState(() {
            _temperature = '$temperature °C';
            debugPrint("Temperature: $_temperature");
          });
        } else {
          setState(() {
            _temperature = 'No daily data available';
          });
        }
      } else {
        setState(() {
          _temperature =
              'Failed to load weather data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 'Failed to load weather data. Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   foregroundColor: Color(0xFFc0995b),
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 170,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/home_bg.png"),
                    fit: BoxFit.fitWidth,
                    opacity: 0.9),
                    //color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Builder(
                          builder: (context) => InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Icon(Icons.menu, size: 30, color: Color(0xFFc0995b),)
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  // radius: 20,
                                  backgroundImage: GetStorage()
                                              .read('profileImage') !=
                                          null
                                      ? MemoryImage(base64Decode(GetStorage().read(
                                          'profileImage')!)) // Convert back to Uint8List
                                      : AssetImage("assets/images/user.png")
                                          as ImageProvider<Object>,
                                ),
                                Text(
                                  "WELCOME\n${nameParts[0] ?? ''}",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/airSial.png",
                                  height: 60,
                                ),
                                GreetingWidget(),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  // radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/weather.png"),
                                ),
                                Text(
                                  "\n${_temperature}",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: MediaQuery.of(context).size.width * 1,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Meetings Data")),
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => UpComingAgendaMeeting(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/DueAgenda.png",
                                  height: 50,
                                ),
                                Text("Upcoming"),
                                Text("Meetings"),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => AgendaMeeting(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/agenda.png",
                                  height: 60,
                                ),
                                Text("Agenda"),
                                Text("Meetings"),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => MofMeeting(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/DueAgenda.png",
                                  height: 50,
                                ),
                                Text("Minutes"),
                                Text("Of Meeting"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 10, width: MediaQuery.of(context).size.width,
                color: Colors.white,),
                //SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => CommitteeeListScreen(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/Committee.png",
                                  height: 50,
                                ),
                                Text("List Of"),
                                Text("Committees"),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => AgendaMeeting(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/meeting.png",
                                  height: 50,
                                ),
                                Text("Total Meetings"),
                                Text("Over (Yearly)"),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => Ticketing(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/ticket2.png",
                                  height: 50,
                                ),
                                Text("Ticketing"),
                                Text(""),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: MediaQuery.of(context).size.width * 1,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: Align(
                      alignment: Alignment.centerLeft, child: Text("Quik Links")),
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,
                        vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => CalenderWidget(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 34,
                                  color: Color(0xFFc0995b),
                                ),
                                Text("Meetings"),
                                Text("Calendar Sched."),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (await canLaunch("https://www.airsial.com/")) {
                              await launch("https://www.airsial.com/");
                            } else {
                              await launch("https://www.airsial.com/");
                            }
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/website.png",
                                  height: 40,
                                ),
                                Text("AIR SIAL"),
                                Text("Website"),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _box.write("newsList", news.tRNO);
                            Get.to(() => News(),
                                transition: Transition.leftToRightWithFade);
                          },
                          child: Badge.count(
                            count: newsBadgeCount == null ? 0 : newsBadgeCount,
                            largeSize: 20,
                            isLabelVisible: true,
                            backgroundColor: Colors.green.shade800,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/news1.png",
                                    height: 45,
                                  ),
                                  //Icon(Icons.newspaper_rounded, size: 34, color: Colors.green,),
                                  Text("News"),
                                  Text(""),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                // margin: EdgeInsets.zero,
                // padding: EdgeInsets.zero,
                // //height: double.infinity,
                // decoration: BoxDecoration(
                //     color: Theme.of(context).colorScheme.onPrimary,
                //     // borderRadius: BorderRadius.only(
                //     //     topLeft: Radius.circular(30),
                //     //     topRight: Radius.circular(30))
                // ),
                // child: Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: SingleChildScrollView(
                //     child: Column(
                //       children: [
                //         SizedBox(height: 1.h),
                //         Container(
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Container(
                //                 margin: EdgeInsets.zero,
                //                 padding: EdgeInsets.zero,
                //                 child: TextButton(
                //                   onPressed: () {
                //                     Get.to(() => CalenderWidget(),
                //                         transition:
                //                         Transition.leftToRightWithFade);
                //                   },
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                         borderRadius:
                //                         BorderRadius.circular(12.0),
                //                         boxShadow: [
                //                           BoxShadow(
                //                               spreadRadius: 3,
                //                               blurRadius: 8,
                //                               color: Colors.black)
                //                         ]),
                //                     height: 7.4.h,
                //                     width: double.infinity,
                //                     child: _selectedAgend(
                //                         Color(0xFFc0995b),
                //                         "Upcoming Meetings",
                //                         "Calender Wise",
                //                         context),
                //                   ),
                //                 ),
                //               ),
                //               //SizedBox(height: 0.5.h),
                //               Container(
                //                 margin: EdgeInsets.zero,
                //                 padding: EdgeInsets.zero,
                //                 child: TextButton(
                //                   onPressed: () {
                //                     Get.to(() => AgendaMeeting(),
                //                         transition:
                //                         Transition.leftToRightWithFade);
                //                   },
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                         borderRadius:
                //                         BorderRadius.circular(12.0),
                //                         boxShadow: [
                //                           BoxShadow(
                //                               spreadRadius: 3,
                //                               blurRadius: 8,
                //                               color: Colors.black)
                //                         ]),
                //                     height: 7.4.h,
                //                     width: double.infinity,
                //                     child: _selectedAgend(
                //                         Color(0xFFc0995b),
                //                         "Total Meetings Over",
                //                         " Years",
                //                         context),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Divider(
                //           thickness: 1,
                //           indent: 40,
                //           endIndent: 40,
                //           color: Colors.black,
                //         ),
                //         Align(
                //           alignment: Alignment.centerLeft,
                //           child: Container(
                //             padding: EdgeInsets.symmetric(horizontal: 15),
                //             margin: EdgeInsets.only(left: 10),
                //             width: MediaQuery.of(context).size.width * 0.8,
                //             height: 70,
                //             decoration: BoxDecoration(
                //               color: Colors.red,
                //               boxShadow: [BoxShadow(
                //                 color: Colors.black,
                //                 spreadRadius: 2,
                //                 blurRadius: 7
                //               )],
                //               borderRadius: BorderRadius.only(topRight: Radius.circular(30.0),
                //               bottomRight: Radius.circular(30.0))
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [Text("Upcoming Meetings",
                //                 style: TextStyle(color: Colors.white, fontSize: 18),),
                //               Image.asset("assets/images/DueAgenda.png")],
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 15,),
                //         Align(
                //           alignment: Alignment.centerRight,
                //           child: Container(
                //             padding: EdgeInsets.symmetric(horizontal: 15),
                //             margin: EdgeInsets.only(right: 10),
                //             width: MediaQuery.of(context).size.width * 0.8,
                //             height: 70,
                //             decoration: BoxDecoration(
                //               color: Color(0xFF94924e),
                //               boxShadow: [BoxShadow(
                //                 color: Colors.black,
                //                 spreadRadius: 2,
                //                 blurRadius: 7
                //               )],
                //               borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),
                //               bottomLeft: Radius.circular(30.0))
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //               Image.asset("assets/images/agenda.png"),
                //                 Text("Agenda Meetings",
                //                   style: TextStyle(color: Colors.white,
                //                   fontSize: 18),),],
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 15,),
                //         Align(
                //           alignment: Alignment.centerLeft,
                //           child: Container(
                //             padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                //             margin: EdgeInsets.only(left: 10),
                //             width: MediaQuery.of(context).size.width * 0.8,
                //             height: 70,
                //             decoration: BoxDecoration(
                //                 color: Color(0xFF068a44),
                //                 boxShadow: [BoxShadow(
                //                     color: Colors.black,
                //                     spreadRadius: 2,
                //                     blurRadius: 7
                //                 )],
                //                 borderRadius: BorderRadius.only(topRight: Radius.circular(30.0),
                //                     bottomRight: Radius.circular(30.0))
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [Text("Minutes Of Meeting",
                //                 style: TextStyle(color: Colors.white, fontSize: 18),),
                //                 Image.asset("assets/images/Minutes-of-Meeting.png")],
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 15,),
                //         Align(
                //           alignment: Alignment.centerRight,
                //           child: Container(
                //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                //             margin: EdgeInsets.only(right: 10),
                //             width: MediaQuery.of(context).size.width * 0.8,
                //             height: 70,
                //             decoration: BoxDecoration(
                //                 color: Color(0xFF94924e),
                //                 boxShadow: [BoxShadow(
                //                     color: Colors.black,
                //                     spreadRadius: 2,
                //                     blurRadius: 7
                //                 )],
                //                 borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),
                //                     bottomLeft: Radius.circular(30.0))
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Image.asset("assets/images/Committee.png"),
                //                 Text("Committees",
                //                   style: TextStyle(color: Colors.white,
                //                       fontSize: 18),),],
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 15,),
                //         Align(
                //           alignment: Alignment.centerLeft,
                //           child: Container(
                //             padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                //             margin: EdgeInsets.only(left: 10),
                //             width: MediaQuery.of(context).size.width * 0.8,
                //             height: 70,
                //             decoration: BoxDecoration(
                //                 color: Color(0xFF068a44),
                //                 boxShadow: [BoxShadow(
                //                     color: Colors.black,
                //                     spreadRadius: 2,
                //                     blurRadius: 7
                //                 )],
                //                 borderRadius: BorderRadius.only(topRight: Radius.circular(30.0),
                //                     bottomRight: Radius.circular(30.0))
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [Text("AIR SIAL Website",
                //                 style: TextStyle(color: Colors.white, fontSize: 18),),
                //                 Image.asset("assets/images/website.png")],
                //             ),
                //           ),
                //         ),
                //         // Row(
                //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //   children: [
                //         //     Container(
                //         //       width: MediaQuery.of(context).size.width * 0.46,
                //         //       height: MediaQuery.of(context).size.height * 0.19,
                //         //       color: Theme.of(context).colorScheme.onPrimary,
                //         //       child: TextButton(
                //         //         onPressed: () {
                //         //           Get.to(() => UpComingAgendaMeeting(),
                //         //               transition:
                //         //               Transition.leftToRightWithFade);
                //         //         },
                //         //         // padding: const EdgeInsets.all(8.0),
                //         //         child: _selectedExtras(
                //         //             'assets/images/DueAgenda.png',
                //         //             'Upcoming\nMeetings',
                //         //             Theme.of(context).colorScheme.error,
                //         //             context),
                //         //       ),
                //         //     ),
                //         //     Container(
                //         //       width: MediaQuery.of(context).size.width * 0.46,
                //         //       height: MediaQuery.of(context).size.height * 0.19,
                //         //       color: Theme.of(context).colorScheme.onPrimary,
                //         //       child: TextButton(
                //         //         onPressed: () {
                //         //           Get.to(() => AgendaMeeting(),
                //         //               transition:
                //         //               Transition.leftToRightWithFade);
                //         //         },
                //         //         // padding: const EdgeInsets.all(8.0),
                //         //         child: _selectedExtras(
                //         //             'assets/images/agenda.png',
                //         //             ' Agenda\nMeetings',
                //         //             Theme.of(context).colorScheme.primaryContainer,
                //         //             context),
                //         //       ),
                //         //     ),
                //         //   ],
                //         // ),
                //         // Row(
                //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         //   children: [
                //         //     Container(
                //         //       width: MediaQuery.of(context).size.width * 0.46,
                //         //       height: MediaQuery.of(context).size.height * 0.19,
                //         //       color: Theme.of(context).colorScheme.onPrimary,
                //         //       child: TextButton(
                //         //         onPressed: () {
                //         //           Get.to(() => MofMeeting(),
                //         //               transition:
                //         //               Transition.leftToRightWithFade);
                //         //         },
                //         //         // padding: const EdgeInsets.all(8.0),
                //         //         child: _selectedExtras(
                //         //             'assets/images/Minutes-of-Meeting.png',
                //         //             'Minutes of\n  Meeting',
                //         //             Color(0xFF006831),
                //         //             context),
                //         //       ),
                //         //     ),
                //         //     Container(
                //         //       width: MediaQuery.of(context).size.width * 0.46,
                //         //       height: MediaQuery.of(context).size.height * 0.19,
                //         //       color: Theme.of(context).colorScheme.onPrimary,
                //         //       child: TextButton(
                //         //         onPressed: () {
                //         //           Get.to(() => CommitteeeListScreen(),
                //         //               transition:
                //         //               Transition.leftToRightWithFade);
                //         //         },
                //         //         // padding: const EdgeInsets.all(8.0),
                //         //         child: _selectedExtras(
                //         //             'assets/images/Committee.png',
                //         //             'Committees',
                //         //             Color(0xFF006831),
                //         //             context),
                //         //       ),
                //         //     ),
                //         //   ],
                //         // ),
                //         // Container(
                //         //   height: MediaQuery.of(context).size.height * 0.17,
                //         //   child: TextButton(
                //         //     onPressed: () async {
                //         //       await Future.delayed(Duration(milliseconds: 1));
                //         //       if (await canLaunch("")) {
                //         //         await launch("");
                //         //       }
                //         //     },
                //         //     //padding: const EdgeInsets.all(8.0),
                //         //     child: _selectedExtras(
                //         //         'assets/images/website.png',
                //         //         'AIR SIAL Website',
                //         //         Color(0xFF3c593f),
                //         //         context),
                //         //   ),
                //         // ),
                //         SizedBox(height: 20),
                //         upcomingMeetings != null && dataLoaded
                //             ? buildTodayMeetingAlert(upcomingMeetings!)
                //             : Container(),
                //       ],
                //     ),
                //   ),
                // ),
                //             ),
              ],
            ),
          ),
        ),
        drawer: MyDrawer(),
      ),
    );
  }

  Widget _selectedAgend(Color color, String title, String subtitle, context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 3.w),

      //height: 100,
      //  width: 260,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0.5.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF00460e),
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: Color(0xFF00460e),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectedExtras(String image, String name, Color color, context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 3,
              blurRadius: 6,
            )
          ],
          color: color,
          borderRadius: BorderRadius.circular(1.h),
          border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary, width: 1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 7.h,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(image)),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onPrimary),
          ),
          //Color(Colors.green),
        ],
      ),
    );
  }
}
