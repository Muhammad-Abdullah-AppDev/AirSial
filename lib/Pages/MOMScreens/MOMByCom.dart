import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:airsial_app/Pages/MOMScreens/mom_dtl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../model/momByComModel.dart';
import '../../services/base_url.dart';

class MOMByCommittee extends StatefulWidget {
  String? pkcode;
  MOMByCommittee({
    Key? key,
    required this.pkcode,
  }) : super(key: key);
  @override
  State<MOMByCommittee> createState() => _AgendaMeetingPageState();
}

class _AgendaMeetingPageState extends State<MOMByCommittee> {
  List<MOMByComModel> agendaList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.fetchAgenda();
  }

  fetchAgenda() async {
    try {
      isLoading = true;
      var response = await http.get(Uri.parse(
          '${APIConstants.baseURL}MOM/GetAllMOMByCom?fkcmt=' +
              widget.pkcode!));
      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);

        // Convert List<dynamic> to List<AgendaMeetingByComModel>
        List<dynamic> dataList = decodedData as List<dynamic>;
        agendaList =
            dataList.map((json) => MOMByComModel.fromJson(json)).toList();

        // print("xxx${decodedData}");
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching agenda: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              )),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.only()),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(1.5.h),
                                child: Text(
                                  'Minutes of Meeting',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        getList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget getList() {
    // Create a map to group AgendaMeetimgModel items by tid and mdate
    Map<String, List<MOMByComModel>> groupedAgendaData = {};

    for (var agenda in agendaList) {
      final key = '${agenda.tid}_${agenda.mdate}';
      if (!groupedAgendaData.containsKey(key)) {
        groupedAgendaData[key] = [agenda];
      } else {
        groupedAgendaData[key]!.add(agenda);
      }
    }

    // Create a list to store the combined AgendaMeetimgModel items
    List<MOMByComModel> combinedAgendaData = [];

    // Combine the committe names for each group
    groupedAgendaData.forEach((key, value) {
      String committeeNames =
          value.map((agenda) => agenda.commite).toSet().join(', ');

      // Get the first AgendaMeetimgModel from the group and update its "committe" value
      var firstAgenda = value.first;
      firstAgenda.commite = committeeNames;
      combinedAgendaData.add(firstAgenda);
    });
    //// sort data
    combinedAgendaData.sort((a, b) {
      DateTime dateTimeA = DateTime.tryParse(a.mdate!) ?? DateTime(0);
      DateTime dateTimeB = DateTime.tryParse(b.mdate!) ?? DateTime(0);
      return dateTimeB.compareTo(dateTimeA);
    });

    return Expanded(
      child: combinedAgendaData.isEmpty
          ? Center(
              child: Text(
                'No Data Found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: combinedAgendaData.length,
              itemBuilder: (context, index) {
                return getCard(combinedAgendaData[index]);
              },
            ),
    );
  }

  Widget getCard(MOMByComModel agenda) {
    var committeeName = agenda.meeting;
    var agendaName = agenda.agenda;
    int tid = agenda.tid!;
    var mdate = agenda.mdate;
    DateTime dateTime = DateTime.parse(mdate!);

    String formatdate = DateFormat.yMMMEd().format(dateTime);
    var committe = agenda.commite;

    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: EdgeInsets.all(0.2.h),
        child: ListTile(
          onTap: () {
            // Navigate to Next Details
            Get.to(
              () => MintuesOfMeetingDetails(
                tid: tid,
                agendaName: committeeName!,
              ),
              transition: Transition.leftToRightWithFade,
            );
          },
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$committe',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Date : $formatdate   Time : ${agenda.mtime}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Text(
                    //   'Agenda : $agendaName',
                    //   style: TextStyle(
                    //     color: Theme.of(context).colorScheme.onPrimaryContainer,
                    //     fontSize: 10.sp,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    //   // overflow: TextOverflow.ellipsis,
                    //   maxLines: 3,
                    // ),
                    Text(
                      'Venue : ${agenda.venue}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      // overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 0.w),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 201, 203, 242),
                  borderRadius: BorderRadius.circular(0.8.h),
                ),
                child: Center(child: Icon(Icons.arrow_forward_ios)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
