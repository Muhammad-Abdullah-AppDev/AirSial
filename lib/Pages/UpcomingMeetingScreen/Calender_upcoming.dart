import 'package:flutter/material.dart';
import 'package:airsial_app/model/Meeting.dart';
import 'package:airsial_app/model/Meeting_data_source.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:timezone/data/latest.dart' as tz;

import '../../services/base_url.dart';

class CalenderWidget extends StatefulWidget {
  const CalenderWidget({Key? key}) : super(key: key);

  @override
  State<CalenderWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalenderWidget> {
  final folio = GetStorage().read('folio');

  Future<List<Meeting>> _getDataSource() async {
    final url = Uri.parse(
        '${APIConstants.baseURL}UPComAgenda/GetAll?folno=$folio');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final meetings = data.map((item) {
        final mdate = DateTime.parse(item['MDATE']);
        final mtime = item['MTIME']; // Extract the time value without parsing
        final committe =
            item['COMMITTE']; // Extract the time value without parsing
        final venue = item['VENUE']; // Extract the time value without parsing
        final meettime =
            item['MDATE']; // Extract the time value without parsing
        // Check if the time string is in 'h:mm a' format or 'HH:mm' format
        final is24HourFormat =
            mtime.length == 5; // 'HH:mm' format is 5 characters long

        final parsedTime = is24HourFormat
            ? DateFormat('HH:mm')
                .parse(mtime) // Use 'HH:mm' pattern for 24-hour format
            : DateFormat('h:mm a').parse(
                mtime); // Use 'h:mm a' pattern for 12-hour format// Parse the time separately
        final meetingStartTime = DateTime(mdate.year, mdate.month, mdate.day,
            parsedTime.hour, parsedTime.minute);
        final meetingEndTime = meetingStartTime.add(Duration(hours: 2));
        // debugPrint("Items:  ${item['TID'] + item['MEETING'] + meetingStartTime + meetingEndTime + mtime
        // + committe + venue + meettime}");
        return Meeting(
            item['TID'],
            item['COMMITTE'],
            meetingStartTime,
            meetingEndTime,
            Color.fromARGB(255, 28, 44, 92),
            false,
            mtime,
            committe,
            venue,
            meettime);
      }).toList();

      return meetings;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _getDataSource();
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
      body: FutureBuilder<List<Meeting>>(
        future: _getDataSource(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfCalendar(
              appointmentBuilder:
                  (context, CalendarAppointmentDetails details) {
                List<Meeting> meetings = details.appointments
                    .map((appointment) => appointment as Meeting)
                    .toList();
                final String comName =
                    meetings.isNotEmpty ? meetings[0].comName : '';

                final String venue =
                    meetings.isNotEmpty ? meetings[0].venue : '';

                final String startTime =
                    meetings.isNotEmpty ? meetings[0].mtime.toString() : '';

                final String endTime =
                    meetings.isNotEmpty ? meetings[0].to.toString() : '';
                final String meetTime =
                    meetings.isNotEmpty ? meetings[0].meettime : '';

                return Container(
                  height: MediaQuery.of(context).size.height * 1,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  color: Theme.of(context).colorScheme.primary,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Committee: $comName',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Venue: $venue',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Time: $startTime',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              appointmentTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              todayHighlightColor: Theme.of(context).colorScheme.primary,
              view: CalendarView.month,
              cellBorderColor: Colors.transparent,
              dataSource: MeetingDataSource(snapshot.data!),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode:
                    MonthAppointmentDisplayMode.indicator,
                showAgenda: true,
              ),
            );
          } else if (snapshot.hasError) {

            debugPrint(snapshot.error.toString());
            return Center(child: Text('Something went wrong Try later!'));
          } else {
            return Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ));
          }
        },
      ),
    );
  }
}