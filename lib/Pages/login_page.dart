import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:airsial_app/utils/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../services/base_url.dart';
import '../widgets/roundbutton.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _text1Animation;
  late Animation<Offset> _text2Animation;

  String name = "";
  String Message = "";
  bool isLoadding = false;
  final _formKey = GlobalKey<FormState>();
  final _box = GetStorage();

  final FocusNode cnicFocusNode = FocusNode();
  TextEditingController folioController = TextEditingController();
  TextEditingController cnicController = TextEditingController();

  signIn(String folno, String cnic, String? selectedRadio) async {
    setState(() {
      isLoadding = true;
    });

    final response = await http.get(Uri.parse(
        "https://erm.scarletsystems.com:2030/Api/Login/GetById?folno=$folno&cnic=$cnic&REQTYPE=$selectedRadio"));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      debugPrint("Response:   ${jsonResponse['SHNAME']}");
      // Save the 'shname' value to storage
      if (jsonResponse['SHNAME'] != null) {
        await _box.write('shname', jsonResponse['SHNAME']);
      }
      var fol = selectedRadio == "D" ? jsonResponse['PKCODE'] : jsonResponse['FOLNO'];
      fetchImage(fol);

      await _box.write('cnic', cnic);
      await _box.write('folio', folno);
      await _box.write('account', selectedRadio);
      await _box.write('addedEvents', [-1]);

      await Get.offAllNamed(MyRoutes.homeRout);

      setState(() {
        isLoadding = false;
      });
    } else {
      setState(() {
        isLoadding = false;
        Message = "";
      });
      Alert(
              style: AlertStyle(),
              context: context,
              title: "Error",
              desc: "Invalid Credentials")
          .show();
      debugPrint(response.reasonPhrase);
    }
  }

  bool? isObscurText = true;
  String? _selectedRadio;

  final List<String> imagePaths = [
    'assets/images/bg1.png',
    'assets/images/bg2.png',
    'assets/images/bg3.png',
    'assets/images/bg4.png',
  ];

  int currentIndex = 0;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % imagePaths.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    cnicFocusNode.addListener(_onFocusChange);
    _startTimer();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _text1Animation = Tween<Offset>(
      begin: Offset(1, 0), // Start from the right
      end: Offset.zero, // Slide to the left
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5), // You can adjust the start and end times
      ),
    );

    _text2Animation = Tween<Offset>(
      begin: Offset(1, 0), // Start from the right
      end: Offset.zero, // Slide to the left
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0), // You can adjust the start and end times
      ),
    );
    _animationController.forward();

    final cnic = _box.read('cnic');
    final folio = _box.read('folio');
    if (cnic != null) {
      cnicController.text = cnic;
    }
    if (folio != null) {
      folioController.text = folio;
    }
  }

  String? apiResponse;

  void _onFocusChange() {
    if (!cnicFocusNode.hasFocus) {
      _callApi(cnicController.text);
      debugPrint("Okkkk Value");
    }
  }

  Future<void> _callApi(String cnic) async {
    final url = Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/Login/GetDetailAgainstCNIC?cnic=$cnic');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          apiResponse = response.body;
          _selectedRadio = apiResponse![1];
          debugPrint('Value: $_selectedRadio');
        });
        debugPrint('API Response: ${apiResponse![1]}');
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    cnicFocusNode.removeListener(_onFocusChange);
    cnicFocusNode.dispose();
    cnicController.dispose();
    folioController.dispose();
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchImage(String folio) async {
    GetStorage _box = GetStorage();
    try {
      final response = await http.get(Uri.parse(
          '${APIConstants.baseURL}Login/GetImage?folno=' + folio.toString()));
      if (response.statusCode == 200) {
        String imageDataString = base64Encode(response.bodyBytes);
        _box.write("profileImage", imageDataString);
      } else {
        debugPrint('Failed to load image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Color(0xFFc0995b),
        title: Image.asset("assets/images/airSial.png"),
        centerTitle: true,
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(children: [
          AnimatedSwitcher(
            duration: Duration(seconds: 3),
            child: Image.asset(
              imagePaths[currentIndex],
              key: Key(imagePaths[currentIndex]),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-0.1, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 1.h, right: 1.h),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/airsial_plane.png",
                      ),
                    ],
                  ),
                ),
                Stack(children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "   CNIC No: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )),
                            TextFormField(
                              focusNode: cnicFocusNode,
                              controller: cnicController,
                              maxLength: 13,
                              decoration: InputDecoration(
                                hintText: "Enter CNIC No.",
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                filled: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    )),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        width: 2.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        width: 2.0)),
                              ),
                              onSaved: (value) {
                                debugPrint("Value:");
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "CNIC cannot be empty";
                                }
                                return null;
                              },
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "   Folio No: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )),
                            TextFormField(
                              controller: folioController,
                              obscureText: isObscurText!,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  color: Theme.of(context).colorScheme.outline,
                                  icon: Icon(
                                      size: 24,
                                      isObscurText!
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      isObscurText = !isObscurText!;
                                    });
                                  },
                                ),
                                hintText: "Enter Folio No.",
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                filled: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        width: 2.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        width: 2.0)),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Folio cannot be empty";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Radio<String>(
                                  activeColor: Colors.green,
                                  value: 'D',
                                  groupValue: _selectedRadio,
                                  onChanged: (String? value) {
                                    if (apiResponse![1] == "B") {
                                      setState(() {
                                        _selectedRadio = value;
                                        debugPrint("Value: $_selectedRadio");
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  'Director',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Spacer(),
                                Radio<String>(
                                  activeColor: Colors.green,
                                  value: 'S',
                                  groupValue: _selectedRadio,
                                  onChanged: (String? value) {
                                    if (apiResponse![1] == "B") {
                                      setState(() {
                                        _selectedRadio = value;
                                        debugPrint("Value: $_selectedRadio");
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  'Shareholder  ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            RoundButton(
                              backgroundColor: Color(0xFF006831),
                              onTap: () {
                                final form = _formKey.currentState;
                                if (form != null && form.validate()) {
                                  if (_selectedRadio == "S" ||
                                      _selectedRadio == "D") {
                                    signIn(
                                        folioController.text.toString(),
                                        cnicController.text.toString(),
                                        _selectedRadio
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please Select Account Type",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                  }
                                }
                              },
                              title: 'Login',
                              loading: isLoadding,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 50,
                    right: 50,
                    child: Image.asset(
                      "assets/images/account.png",
                      height: 130,
                    ),
                  ),
                ])
              ],
            ),
          ),
        ]);
      }),
    );
  }
}
