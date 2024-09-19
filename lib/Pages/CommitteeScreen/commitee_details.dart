import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../services/base_url.dart';

// ignore: must_be_immutable
class CommitteeDetailsScreen extends StatefulWidget {
  CommitteeDetailsScreen({super.key, required this.tid, required this.name});
  int? tid;
  String? name;

  @override
  State<CommitteeDetailsScreen> createState() => _CommitteeDetailsScreenState();
}

class _CommitteeDetailsScreenState extends State<CommitteeDetailsScreen> {
  var committeeType = {};
  bool isLoading = false;

  var committeeMember = [];

  //// committeeMember api
  fetchCommitteMember() async {
    // print("fetching...");
    isLoading = true;
    var request = await http.Request(
        'GET',
        Uri.parse(
            '${APIConstants.baseURL}ComMem/GetById?pkcode=${widget.tid}'));
    debugPrint('pkcode: ${widget.tid}');
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('hit committee member api ');
      setState(() {
        isLoading = false;
        committeeMember = items;
        debugPrint('Total Member: ${committeeMember.length}');
        //debugPrint(committeeMember);
      });
    } else {
      setState(() {
        isLoading = false;
        committeeMember = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.fetchCommitteMember();
  }

/////////////////////////////
  // Define a custom sorting function to order the member types
  int getMemberTypePriority(String memberType) {
    switch (memberType) {
      case 'Convener':
        return 1;
      case 'Senior Deputy Convener':
        return 2;
      case 'Deputy Convener':
        return 3;
      case 'Member':
        return 4;
      default:
        return 5;
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
            )))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Container(
                  // height: 700,
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
                                  '${widget.name}',
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
                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: committeeMember.length,
                            itemBuilder: (context, index) {
                              committeeMember.sort((a, b) {

                                // Sort the committee members based on their member type priority
                                final int priorityA =
                                    getMemberTypePriority(a['mtype']);
                                final int priorityB =
                                    getMemberTypePriority(b['mtype']);
                                return priorityA.compareTo(priorityB);
                              });
                              final names = committeeMember[index]['shname'];
                              final type = committeeMember[index]['mtype'];
                              debugPrint('Member name: ${committeeMember[index]['shname']}');
                              debugPrint('Member type: ${committeeMember[index]['mtype']}');
                              debugPrint('Member fkcode: ${committeeMember[index]['fkcode']}');
                              return Card(
                                color: Theme.of(context).colorScheme.tertiary,
                                child: Padding(
                                  padding: EdgeInsets.all(0.2.h),
                                  child: ListTile(
                                    title: Text(
                                      "$names",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                        color: type == 'Member'
                                            ? Colors.black
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                    trailing: Text(
                                      "$type",
                                      style: TextStyle(
                                        color: type == 'Member'
                                            ? Colors.black
                                            : Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
