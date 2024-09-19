import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import '../../services/base_url.dart';
import '../zoom_screen.dart';

class UpCommingAgendaMeetingDetail extends StatefulWidget {
  UpCommingAgendaMeetingDetail(
      {super.key,
      required this.tid,
      required this.zoomlink,
      required this.agendaName,
      required this.mdate});
  final int tid;
  final String? zoomlink;
  final String? agendaName;
  String? mdate;
  @override
  State<UpCommingAgendaMeetingDetail> createState() =>
      _AgendaMeetingDetail(tid: this.tid, agendaName: this.agendaName);
}

class _AgendaMeetingDetail extends State<UpCommingAgendaMeetingDetail> {
  int tid;
  String? agendaName;
  _AgendaMeetingDetail({required this.tid, required this.agendaName});
  @override
  List Agendadtl = [];
  bool isLoading = false;

  void initState() {
    debugPrint("ZoomLink :${widget.zoomlink}");
    debugPrint("mDate :${widget.mdate}");
    debugPrint("Tid :${widget.tid}");
    super.initState();
    this.fetchAgenda();
  }

  fetchAgenda() async {
    // print("fetching...");
    isLoading = true;

    var request = await http.Request(
        'GET', Uri.parse('${APIConstants.baseURL}CAAgendaDtl/Getbyid?tid=$tid'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());

      setState(() {
        isLoading = false;

        Agendadtl = items;
      });
    } else {
      setState(() {
        isLoading = false;

        Agendadtl = [];
      });
    }
  }

  bool isMeetingToday() {
    if (widget.mdate == null) {
      return false; // Return false if mdate is null (no meeting date available)
    }

    // Get the current date without the time part
    DateTime currentDate = DateTime.now();
    DateTime currentOnlyDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Parse the mDate string to a DateTime object
    DateTime meetingDateTime = DateTime.parse(widget.mdate!);

    // Extract the date part of the meeting date without the time
    DateTime meetingOnlyDate = DateTime(
        meetingDateTime.year, meetingDateTime.month, meetingDateTime.day);

    // Compare the dates without the time part
    return currentOnlyDate == meetingOnlyDate;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('isTodayMeeting:${isMeetingToday()}');
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )))
          : Column(
              children: [
                Container(
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          // color: Color.fromARGB(255, 151, 151, 156),
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(30),
                              // topRight: Radius.circular(30),
                              )),
                      child: Column(
                        children: [
                          Container(
                            height: 20.h,
                            width: double.infinity,
                            child: Image.asset("assets/images/agenda.jpg",
                                fit: BoxFit.cover),
                          ),
                          SizedBox(height: 1.h),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Theme.of(context).colorScheme.primary,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(" DETAIL",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Expanded(child: getList()),
                          SizedBox(height: 1.h),

                          // Show the "Attend Meeting" button only if the meeting is today
                          if (isMeetingToday())
                            GestureDetector(
                              onTap: () {
                                //debugPrint(tid);
                                Get.to(
                                  () => ZoomScreen(
                                      tid: tid, zoomLink: widget.zoomlink),
                                  transition: Transition.leftToRightWithFade,
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: Theme.of(context).colorScheme.primary,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Attend Meeting",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 1.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      // drawer: MyDrawer(),
    );
  }

  Widget getList() {
    return ListView.builder(
      itemCount: Agendadtl.length,
      itemBuilder: (context, index) {
        return getCard(Agendadtl[index]);
      },
    );
  }

  Widget getCard(index) {
    // var agendaName = index['meeting'];
    int tid = index['tid'];
    var htmlContent = index["adtl"];
    var trno = index["trno"];

    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: EdgeInsets.all(0.8.h),
        child: ListTile(
          title: HtmlWidget(
            htmlContent, // Display HTML content
          ),
          trailing: Text(
            trno.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ),
      ),
    );
  }
}
