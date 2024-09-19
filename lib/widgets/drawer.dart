import 'dart:convert';

import 'package:airsial_app/Pages/travel_authorization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:airsial_app/Pages/AgendaScreen/Agenda_Meeting.dart';
import 'package:airsial_app/Pages/UpcomingMeetingScreen/Calender_upcoming.dart';
import 'package:airsial_app/Pages/MOMScreens/Mintues_of_Meeting.dart';
import 'package:airsial_app/Pages/about.dart';
import 'package:airsial_app/Pages/home_page.dart';
import 'package:airsial_app/Pages/send_notification.dart';
import 'package:airsial_app/Pages/setting.dart';
import 'package:airsial_app/Pages/update_profile.dart';
import 'package:airsial_app/utils/routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  var cnic = '';
  var folio = '';

  String? name;
  void logout() {
    // Remove the stored CNIC and Folio number
    final _box = GetStorage();
    _box.remove('cnic');
    _box.remove('folio');
    _box.remove('shname');
    _box.remove('profileImage');

    // Navigate to the login screen
    Get.offAllNamed(MyRoutes.LoginRout);
  }

  @override
  void initState() {
    final _box = GetStorage();

    folio = _box.read('folio');
    cnic = _box.read('cnic');
    name = _box.read('shname');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00460e),
              Colors.black45,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                currentAccountPictureSize: Size.square(80),
                decoration:
                    BoxDecoration(color:  Color(0xFF00460e),),
                margin: EdgeInsets.zero,
                accountName: Text(
                  "WELCOME ${name ?? ""}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                accountEmail: Text(
                  "Folio No: $folio",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                // currentAccountPicture: Image.network(imageUrl),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 51, 80, 165),
                  // radius: 20,
                  backgroundImage: GetStorage().read('profileImage') != null
                      ? MemoryImage(base64Decode(GetStorage()
                          .read('profileImage')!)) // Convert back to Uint8List
                      : AssetImage("assets/images/user.png")
                          as ImageProvider<Object>,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 1));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              leading: Icon(
                CupertinoIcons.home,
                color: Color(0xFFc0995b),
              ),
              title: Text(
                "Home",
                textScaleFactor: 1.1,
                style: TextStyle(color: Color(0xFFc0995b), fontSize: 11.sp),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UpdateProfile()));
              },
              leading: Icon(
                CupertinoIcons.profile_circled,
                color: Colors.white
              ),
              title: Text(
                "Update Profile",
                textScaleFactor: 1.1,
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 1));
                Get.to(() => AgendaMeeting(),
                    transition: Transition.leftToRightWithFade);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AgendaMeeting()));
              },
              leading: Icon(
                CupertinoIcons.map_pin_slash,
                color: Colors.white,
              ),
              title: Text(
                "Agenda of Meetings",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 1));
                Get.to(() => MofMeeting(),
                    transition: Transition.leftToRightWithFade);
              },
              leading: Icon(
                CupertinoIcons.plus_circle_fill,
                color: Colors.white,
              ),
              title: Text(
                "Minutes of Meetings",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 1));
                Get.to(() => CalenderWidget(),
                    transition: Transition.leftToRightWithFade);
              },
              leading: Icon(
                CupertinoIcons.calendar,
                color: Colors.white,
              ),
              title: Text(
                "Calendar Schedule",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            Visibility(
              visible: folio == '000' && name == 'ADMIN',
              child: ListTile(
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(Duration(milliseconds: 1));
                  Get.to(() => SendNotification(),
                      transition: Transition.leftToRightWithFade);
                },
                leading: Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  "Send Notification",
                  textScaleFactor: 1.1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                if (await canLaunch("https://www.airsial.com/")) {
                  await launch("https://www.airsial.com/");
                } else {
                  await launch("https://www.airsial.com/");
                }
              },
              leading: Icon(
                CupertinoIcons.globe,
                color: Colors.white,
              ),
              title: Text(
                "AIR SIAL Website",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                Get.to(() => Settings(),
                    transition: Transition.leftToRightWithFade);
              },
              leading: Icon(
                CupertinoIcons.gear_solid,
                color: Colors.white,
              ),
              title: Text(
                "Setting",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 1));
                Get.to(() => About(),
                    transition: Transition.leftToRightWithFade);
              },
              leading: Icon(
                CupertinoIcons.ant_circle,
                color: Colors.white,
              ),
              title: Text(
                "About",
                textScaleFactor: 1.1,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                logout();
              },
              leading: Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: Text(
                "Logout",
                textScaleFactor: 1.1,
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}