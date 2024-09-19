import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../model/upcomming_meeting_model.dart';
import '../services/base_url.dart';

class SendNotification extends StatefulWidget {
  const SendNotification({super.key});

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {

  List<String> deviceTokenListData = [];
  List<String> memberNameListData = [];
  List commiteeList = [];
  var committeeMember = [];
  var folno;
  var selectedValue;
  var bodytext;
  var pkcoddeValue;
  bool isLoading = false;
  //NotificationService notificationService = NotificationService();
  TextEditingController titleController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  // @pragma('vm:entry-point')
  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  //   await Firebase.initializeApp();
  //   debugPrint(message.notification!.title.toString());
  //   debugPrint(message.notification!.body.toString());
  //   debugPrint(message.data.toString());
  // }

  void initState() {

    folno = GetStorage().read('folio');

    super.initState();

    // notificationService.firebaseInit(context);
    // notificationService.setupInteractMessage(context);
    // notificationService.getDeviceToken().then((value) {
    //   debugPrint('Device Token : ');
    //   debugPrint(value);
    // });
  }

  fetchCommitteMember(pkcoddeValue) async {
    var request = await http.Request(
        'GET',
        Uri.parse(
            '${APIConstants.baseURL}ComMem/GetById?pkcode=$pkcoddeValue'));
    debugPrint('FKCODE: $pkcoddeValue');
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('hit committee member api ');
      setState(() {
        committeeMember = items;
        debugPrint('Total Member: ${committeeMember.length}');
        debugPrint('Total Member: ${committeeMember[0]['SHNAME']}');
      });
      for(int i = 0; i < committeeMember.length; i ++) {

        debugPrint('Committee Member Detail:  ${committeeMember[i]['DTOKEN'].toString()}');

        String dToken = committeeMember[i]['DTOKEN'].toString();
        debugPrint('Device Tokens:  ${dToken}');
        deviceTokenListData.add(dToken);
      }
      debugPrint('Device Tokens:  ${deviceTokenListData}');
    } else {
      setState(() {
        committeeMember = [];
      });
    }
  }

  Future<List<UpComingMeetingModel>> getAgendaMeetings() async {
    try {
      final response = await http.get(Uri.parse(
          '${APIConstants.baseURL}UPComAgenda/GetAll?folno=$folno'));
      debugPrint('folio no is: $folno');
      final body = json.decode(response.body) as List;
      if(response.statusCode == 200){
        setState(() {
          commiteeList = body;
          //debugPrint("listReturned:$commiteeList");
        });
        return body.map((e){
          final map = e as Map<String, dynamic>;
          return UpComingMeetingModel(
              fkcmt:    map['FKCMT'],
              committe: map['COMMITTE'],
              venue:    map['VENUE'],
              meettime: map['MTIME'],
          );
        }).toList();
      }
      else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  int _selectedIndex = 0;

  Future notificationRequest(String title, String msg) async {
    final String apiUrl =
        'https://erm.scarletsystems.com:2030/Api/NotificationData/InsertNotification?title="$title"&msg="$msg"';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'title': title,
          'msg': msg,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Post request successful');
        return true;
        //debugPrint(response.body);
      } else {
        debugPrint('Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        // Handle the error or show an error message
        return null;
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  // fetchDeviceTokens() async {
  //   var request = await http.Request(
  //       'GET',
  //       Uri.parse(
  //           'https://erm.scarletsystems.com:2030/Api/NotificationData/GetAllToken'));
  //   debugPrint('pkcode: $pkcoddeValue');
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     var items = json.decode(await response.stream.bytesToString());
  //     debugPrint('hit committee member api ');
  //     setState(() {
  //       committeeMember = items;
  //       commiteeList = items;
  //       debugPrint('Total Member: ${committeeMember.length}');
  //     });
  //     for (int i = 0; i < committeeMember.length; i++) {
  //       String dToken = committeeMember[i]['dtoken'].toString();
  //       debugPrint('Device Tokens:  ${dToken}');
  //       deviceTokenListData.add(dToken);
  //
  //       String mName = committeeMember[i]['shname'].toString();
  //       debugPrint('Member Names:  ${mName}');
  //       memberNameListData.add(mName);
  //     }
  //     debugPrint('Device Tokens:  ${deviceTokenListData}');
  //   } else {
  //     setState(() {
  //       committeeMember = [];
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Types'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: _selectedIndex == 0 ? CrossAxisAlignment.center :CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0 ? Colors.greenAccent : Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    padding: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Center(
                        child: _selectedIndex == 0
                            ? Text(
                            '--- Send Meeting Notification ---',
                            style: TextStyle(color: Colors.black, fontSize: 18))
                                :Text(
                          'Send Meeting Notification',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                        color: _selectedIndex == 1 ? Colors.greenAccent : Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Center(
                        child: _selectedIndex == 1
                            ? Text(
                            '--- Send Custom Notification ---',
                            style: TextStyle(color: Colors.black, fontSize: 18))
                        : Text(
                          'Send Custom Notification',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(indent: 60, endIndent: 60, color: Colors.grey,),
              if (_selectedIndex == 0) ...[
                Image.asset('assets/images/app_icon.png', height: 300,),
                FutureBuilder(
                    future: getAgendaMeetings(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10), // Add padding here as needed
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade200, // Change the background color here
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 3,
                                  blurRadius: 4
                              )]
                          ),
                          child: DropdownButton(
                            dropdownColor: Colors.blueAccent,
                            hint: Text("Select Committee"),
                            isExpanded: true,
                            itemHeight: 50.0,
                            value: selectedValue,
                            items: snapshot.data!.map((e) {
                              return DropdownMenuItem(
                                value: e.fkcmt.toString() + " , " + e.committe.toString()+" Meeting on: "+e.meettime.toString(),
                                child: Text("${e.committe.toString()} [ ${e.meettime.toString()} ]"),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedValue = value;
                              List<String> values = selectedValue.split(',');

                              if (values.length == 2) {
                                pkcoddeValue = values[0];
                                bodytext = values[1];

                                debugPrint('pkCode Value: $pkcoddeValue');
                                debugPrint('Second Value: $bodytext');
                              } else {
                                debugPrint('Invalid format: $selectedValue');
                              }
                              debugPrint('Selected Value is: $selectedValue');
                              setState(() {
                                fetchCommitteMember(pkcoddeValue);
                              });
                            },
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                ),
                SizedBox(height: 35,),
                InkWell(
                  onTap: (){
                    debugPrint('Tokens Amount: ${deviceTokenListData[3]}');

                    for(int i = 0; i < deviceTokenListData.length; i ++) {
                      debugPrint('Notification sent to Device Token: ${deviceTokenListData[i]}');
                      sendNotification(deviceTokenListData[i]);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(25.0)
                    ),
                    child: Center(
                      child: Text('Send Notification',
                        style: TextStyle(fontSize: 18,
                            color: Colors.white),),
                    ),
                  ),
                )
              ] else ...[
                SizedBox(height: 20),
                Text(
                  'Title',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue, spreadRadius: 0.5, blurRadius: 4)
                    ],
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: titleController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: ' Enter Notification Title',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Title cannot be Empty";
                      }
                      // else if (value.length < 6) {
                      //   return "CNIC length should be at least 6";
                      // }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  ' Description',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue, spreadRadius: 0.5, blurRadius: 4)
                    ],
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: detailController,
                    maxLines: 5,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: ' Enter Description',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Title cannot be Empty";
                      }
                      // else if (value.length < 6) {
                      //   return "CNIC length should be at least 6";
                      // }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 35),
                InkWell(
                  onTap: () {
                    debugPrint('Tokens Amount: ${deviceTokenListData}');
                    _showMyDialog(context, titleController.text.toString(),
                        detailController.text.toString(), isLoading);
                  },
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Center(
                        child: Text(
                          'Send Notification',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ]

            ],
          ),
        ),
      ),
    );
  }

  void sendNotification(deviceToken) async {
    var data = {
      'to': deviceToken,
      'priority': 'high',
      'notification': {
        'title': 'Meeting Reminder',
        'body': bodytext.toString(),
        'description': 'Open the app to see details'
      },
      'data': {
        'type': 'msg',
      }
    };
    await http.post(Uri.parse(
        'https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAPuzVVT8:APA91bH1W2AYYu5s5wD_TVnvZaw-8dwX_GOH_kcqv3XrrWrOkyWGd8LC5PKdP2Fd7bCBa5LYlcUH40Tr_TcVyu_EZCkzZoBWmpZwMqMP5mZfVt4oD9sH-Y9QbhSrOzT1HkD_3OlN0Azo',
        }
    );
    debugPrint('Notification send to: $deviceToken');
    debugPrint('Notification detail: ');
  }

  void sendCustomNotification(deviceToken, String memberNameListData) async {
    var data = {
      'to': deviceToken,
      'priority': 'high',
      'notification': {
        'title': 'Hello ${memberNameListData.toString()}',
        'body': titleController.text.toString(),
        'description': 'Open the app to see details'
      },
      'data': {
        'type': 'msg',
      }
    };
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
          'key=AAAAPuzVVT8:APA91bH1W2AYYu5s5wD_TVnvZaw-8dwX_GOH_kcqv3XrrWrOkyWGd8LC5PKdP2Fd7bCBa5LYlcUH40Tr_TcVyu_EZCkzZoBWmpZwMqMP5mZfVt4oD9sH-Y9QbhSrOzT1HkD_3OlN0Azo',
        });
    //debugPrint('Notification send to: $deviceToken');
    debugPrint('Notification detail: $data');
  }

  Future _showMyDialog(
      BuildContext context, String title, String body, bool isLoading) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Detail'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                createRichText('Title: ', '$title'),
                createRichText('Body: ', '$body'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(5.0),
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blueAccent; // Color when button is pressed
                    }
                    return Colors.redAccent; // Default color
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shadowColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = !isLoading;
                });
                var responseBody = await notificationRequest(title, body);
                debugPrint("Response: $responseBody");
                if (responseBody != null) {
                  setState(() {
                    isLoading = !isLoading;

                    for (int i = 0; i < deviceTokenListData.length; i++) {
                      debugPrint(
                          'Notification sent to Device Token: ${deviceTokenListData[i]}');
                      sendCustomNotification(
                          deviceTokenListData[i], memberNameListData[i]);
                    }
                  });
                  Fluttertoast.showToast(
                    msg: "Notification Send Successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  setState(() {
                    isLoading = !isLoading;
                  });
                  Fluttertoast.showToast(
                    msg: "Failed to Send Notification",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(6.0),
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.grey;
                    }
                    return isLoading ? Colors.grey : Colors.green;
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shadowColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  createRichText(String title, String body) {
    return RichText(
      text: TextSpan(
        //style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: '$title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              backgroundColor: Colors.transparent,
              color: Colors.black, // You can customize the color if needed
            ),
          ),
          TextSpan(
            text: '$body',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black, // You can customize the color if needed
            ),
          ),
        ],
      ),
    );
  }
}
