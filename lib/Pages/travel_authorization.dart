import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TravelAuthorization extends StatefulWidget {
  const TravelAuthorization({super.key});

  @override
  State<TravelAuthorization> createState() => _TravelAuthorizationState();
}

class _TravelAuthorizationState extends State<TravelAuthorization> {
  bool _isExpanded = true;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;
  bool depExpanded = true;
  bool retExpanded = false;
  String? _selectedRadio;
  String? _selectedRadio2;
  String? _selectedRadio3;
  //String? _selectedItem = "Departing";

  //      ------- Personal Information --------
  TextEditingController _folioController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  //      ------- Traveller Information --------
  TextEditingController cnicController = TextEditingController();
  TextEditingController travelFirstNameController = TextEditingController();
  TextEditingController travelLastNameController = TextEditingController();
  TextEditingController passportNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  //      ------- Trip Information --------
  TextEditingController tripRemarksController = TextEditingController();
  TextEditingController tripDepartingFlyingFromController =
      TextEditingController();
  TextEditingController tripDepartingFlyingToController =
      TextEditingController();
  TextEditingController departingTripDateController = TextEditingController();
  TextEditingController departingTripTimeController = TextEditingController();
  TextEditingController tripDepartingFlightNoController =
      TextEditingController();

  TextEditingController tripReturningFlyingFromController =
      TextEditingController();
  TextEditingController tripReturningFlyingToController =
      TextEditingController();
  TextEditingController returningTripDateController = TextEditingController();
  TextEditingController returningTripTimeController = TextEditingController();
  TextEditingController tripReturningFlightNoController =
      TextEditingController();

  String formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());

  var folio;
  var name;
  var account;
  String firstName = "";
  String lastName = "";
  String? prefixValue;
  String? relationValue;
  var tripType;
  var itinerary;
  var travelReqId;
  var tripReqId;

  bool _isloading = false;

  Future fetchTripInfo(travelReqId) async {
    final response = await http.get(
      Uri.parse(
          'https://erm.scarletsystems.com:2030/Api/TicketRequest/GetTripdtl?reqid= '),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future fetchTravellerInfo(travelReqId) async {
    final response = await http.get(
      Uri.parse(
          'https://erm.scarletsystems.com:2030/Api/TicketRequest/GetTicketPass?reqid= '),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Current date
      firstDate: DateTime(1960), // Start date
      lastDate: DateTime(2050), // End date
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        dateOfBirthController.text =
            "${picked.month}-${picked.day}-${picked.year}";
      });
  }

  Future<void> _selectDepartingTripDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Current date
      firstDate: DateTime(1960), // Start date
      lastDate: DateTime(2050), // End date
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        departingTripDateController.text =
            "${picked.month}-${picked.day}-${picked.year}";
      });
  }

  Future<void> _selectDepartingTripTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Set the initial time to the current time
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00460e), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        departingTripTimeController.text = formattedTime;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _box = GetStorage();
    folio = _box.read('folio');
    _folioController.text = folio;
    account = _box.read("account");
    name = _box.read("shname");
    _selectedRadio = account;
    dateController.text = formattedDate;
    List<String> nameParts = name.split(' ');

    // Check if we have at least two parts
    if (nameParts.length >= 2) {
      firstName = nameParts[0];
      lastName = nameParts[1];
      firstNameController.text = firstName;
      lastNameController.text = lastName;
      debugPrint('First Name: $firstName');
      debugPrint('Last Name: $lastName');
    } else {
      firstNameController.text = name;
      lastNameController.text = lastName;
      debugPrint('Invalid name format');
    }
  }

  Future<void> savePersonalInformation(
      String? selectedRadio, String? selectedRadio2, folio) async {
    final url = Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/TicketRequest/TicketMaster');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (selectedRadio == "D") {
      final Map<String, dynamic> body = {
        'REQTYPE': '$selectedRadio', // Director or Shareholder
        'TICKETTYPE': '$selectedRadio2', // SDF or Discounted
        'FKDIREC': '$folio' // For Director
      };
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          setState(() {
            _isloading = !_isloading;
          });
          Fluttertoast.showToast(
              msg: "Record Saved Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          debugPrint('Request successful');
          debugPrint('Response body: ${response.body}');
          travelReqId = response.body.toString();
          debugPrint('Traveller Request Id : ${travelReqId}');
        } else {
          setState(() {
            _isloading = !_isloading;
          });
          Fluttertoast.showToast(
              msg: "Failed To Save Record",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          debugPrint('Request failed with status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred: $e');
      }
    } else {
      final Map<String, dynamic> body = {
        'REQTYPE': '$selectedRadio', // Director or Shareholder
        'FOLNO': '$folio', // For Shareholder
        'TICKETTYPE': '$selectedRadio2', // SDF or Discounted
      };
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          setState(() {
            _isloading = !_isloading;
          });
          Fluttertoast.showToast(
              msg: "Record Saved Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          debugPrint('Request successful');
          debugPrint('Response body: ${response.body}');
          travelReqId = response.body.toString();
          debugPrint('Traveller Request Id : ${travelReqId}');
        } else {
          setState(() {
            _isloading = !_isloading;
          });
          Fluttertoast.showToast(
              msg: "Failed To Save Record",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          debugPrint('Request failed with status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred: $e');
      }
    }
  }

  Future<void> saveTravellerInformation(
      String? prefixValue, String? relationValue) async {
    final url = Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/TicketRequest/TicketPassanger');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'REQID': '$travelReqId',
      'PFIX': '$prefixValue',
      'FIRSTNAME': '${firstNameController.text}',
      'LASTNAME': '${lastNameController.text}',
      'CNIC': '${cnicController.text}',
      'RELATION': '$relationValue',
      'DOB': '${dateOfBirthController.text}'
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        setState(() {
          _isloading = !_isloading;
        });
        Fluttertoast.showToast(
            msg: "Record Saved Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        debugPrint('Request successful');
        debugPrint('Response body: ${response.body}');
      } else {
        setState(() {
          _isloading = !_isloading;
        });
        Fluttertoast.showToast(
            msg: "Failed To Save Record",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        debugPrint('Request failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  Future<void> saveTripInformation(BuildContext context) async {
    final url = Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/TicketRequest/TicketTripDtl');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      "REQID": "$travelReqId",
      "TTYPE": "", // One-Way or Round
      "FRDSTN": "", // Flying From
      "TODSTN": "", // Flying To
      "FLIGHTNO": "",
      "RMKS": "",
      "TRIPDATE": "",
      "TRVLTYPE": "$tripType" // Domestic or International
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        setState(() {
          _isloading = !_isloading;
        });
        Fluttertoast.showToast(
            msg: "Record Saved Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        debugPrint('Request successful');
        debugPrint('Response body: ${response.body}');
      } else {
        setState(() {
          _isloading = !_isloading;
        });
        Fluttertoast.showToast(
            msg: "Failed To Save Record",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        debugPrint('Request failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text("Travel Form"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/airSial.png"),
            Center(
                child: Text(
              "Air Travel Authorization Form",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 10),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(border: Border.all()),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                          _isExpanded2 = false;
                          _isExpanded3 = false;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: 40,
                        decoration: BoxDecoration(
                            color: _isExpanded == true
                                ? Color(0xFFc0995b)
                                : Color(0xFF00460e),
                            border: Border.all()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                                _isExpanded == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded == false
                                    ? Colors.white
                                    : Colors.black),
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Icon(
                                _isExpanded == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded == false
                                    ? Colors.white
                                    : Colors.black),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: Container(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Category"),
                                  SizedBox(width: 30),
                                  Radio<String>(
                                    activeColor: Colors.green,
                                    value: 'D',
                                    groupValue: _selectedRadio,
                                    onChanged: (String? value) {},
                                  ),
                                  Text('Director'),
                                  SizedBox(width: 8),
                                  Radio<String>(
                                    activeColor: Colors.green,
                                    value: 'S',
                                    groupValue: _selectedRadio,
                                    onChanged: (String? value) {},
                                  ),
                                  Text('Shareholder'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Ticket Type"),
                                  SizedBox(width: 15),
                                  Radio<String>(
                                    activeColor: Colors.green,
                                    value: 'S',
                                    groupValue: _selectedRadio2,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedRadio2 = value;
                                      });
                                    },
                                  ),
                                  Text('SDF'),
                                  SizedBox(width: 32),
                                  Radio<String>(
                                    activeColor: Colors.green,
                                    value: 'D',
                                    groupValue: _selectedRadio2,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedRadio2 = value;
                                      });
                                    },
                                  ),
                                  Text('Discounted'),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: Text("Folio No.")),
                                  Expanded(child: Text("  Date")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: _folioController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal:
                                                  10.0), // Adjust padding as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: dateController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal:
                                                  10.0), // Adjust padding as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("First Name")),
                                  Expanded(child: Text("  Last Name")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: firstNameController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: lastNameController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("Contact No")),
                                  Expanded(child: Text("  Email Address")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: contactController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal:
                                                  10.0), // Adjust padding as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isloading = !_isloading;
                                    });
                                    savePersonalInformation(
                                        _selectedRadio, _selectedRadio2, folio);
                                  },
                                  child: _isloading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          "   Save   ",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(6.0),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.grey;
                                      }
                                      return Colors.green;
                                    }),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shadowColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10)
                            ]),
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(border: Border.all()),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded2 = !_isExpanded2;
                          _isExpanded = false;
                          _isExpanded3 = false;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: 40,
                        decoration: BoxDecoration(
                            color: _isExpanded2 == true
                                ? Color(0xFFc0995b)
                                : Color(0xFF00460e),
                            border: Border.all()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                                _isExpanded2 == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded2 == false
                                    ? Colors.white
                                    : Colors.black),
                            Text(
                              "Traveller Information",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Icon(
                                _isExpanded2 == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded2 == false
                                    ? Colors.white
                                    : Colors.black),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: Container(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text("Prefix")),
                                  Expanded(child: Text(" CNIC")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40, // Spe
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.blueGrey.shade300,
                                        hint: Text("Select"),
                                        value: prefixValue,
                                        isExpanded: true,
                                        items: ["Mr", "Ms", "Mrs"]
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            prefixValue = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: cnicController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal:
                                                  10.0), // Adjust padding as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("First Name")),
                                  Expanded(child: Text(" Last Name")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: travelFirstNameController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: travelLastNameController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("Passport#")),
                                  Expanded(child: Text(" Expiry Date")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: passportNumberController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: expiryDateController,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                              icon: Icon(
                                                Icons.calendar_month_outlined,
                                                color: Colors.green,
                                              )),
                                          hintText: 'MM-DD-YYYY',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("Relationship")),
                                  Expanded(child: Text(" Date Of Birth")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40, // Spe
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.blueGrey.shade300,
                                        menuMaxHeight: 250.0,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        hint: Text("Select"),
                                        value: relationValue,
                                        isExpanded: true,
                                        items: [
                                          "Self",
                                          "Spouse",
                                          "Children",
                                          "Parents",
                                          "Grandson",
                                          "GrandDaughter",
                                          "Son-in-Law",
                                          "Daughter-in-Law",
                                          "Brother",
                                          "Sister",
                                          "Nephew",
                                          "Niece",
                                          "Father-in-Law",
                                          "Mother-in-Law"
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            relationValue = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40, // Specify the desired height
                                      child: TextFormField(
                                        controller: dateOfBirthController,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                              icon: Icon(
                                                Icons.calendar_month_outlined,
                                                color: Colors.green,
                                              )),
                                          hintText: 'MM-DD-YYYY',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isloading = !_isloading;
                                    });
                                    saveTravellerInformation(
                                        prefixValue, relationValue);
                                  },
                                  child: _isloading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          "   Save   ",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(6.0),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.grey;
                                      }
                                      return Colors.green;
                                    }),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shadowColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            border: Border.symmetric(
                                                horizontal: BorderSide())),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(" Prefix")),
                                            Expanded(child: Text("Name")),
                                            Expanded(child: Text("Relation")),
                                            Expanded(child: Text("DOB")),
                                          ],
                                        ),
                                      ),
                                      FutureBuilder(
                                        future: fetchTravellerInfo(travelReqId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(child: Container());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child:
                                                    Text('No data to display'));
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return Center(
                                                child:
                                                    Text('No data available'));
                                          } else {
                                            final items = snapshot.data!;
                                            debugPrint("Item : ${items}");
                                            debugPrint(
                                                "Items : ${items.length}");
                                            return LayoutBuilder(
                                              builder: (context, constraints) {
                                                return ListView.separated(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: items.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container();
                                                  },
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return Divider();
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      crossFadeState: _isExpanded2
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(border: Border.all()),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded3 = !_isExpanded3;
                          _isExpanded2 = false;
                          _isExpanded = false;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: 40,
                        decoration: BoxDecoration(
                            color: _isExpanded3 == true
                                ? Color(0xFFc0995b)
                                : Color(0xFF00460e),
                            border: Border.all()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                                _isExpanded3 == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded3 == false
                                    ? Colors.white
                                    : Colors.black),
                            Text(
                              "Trip Information",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Icon(
                                _isExpanded3 == false
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_up_outlined,
                                color: _isExpanded3 == false
                                    ? Colors.white
                                    : Colors.black),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: Container(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   children: [
                              //     Text("ITINERARY"),
                              //     SizedBox(width: 30),
                              //     Radio<String>(
                              //       activeColor: Colors.green,
                              //       value: 'O',
                              //       groupValue: _selectedRadio3,
                              //       onChanged: (String? value) {
                              //         setState(() {
                              //           _selectedRadio3 = value;
                              //         });
                              //       },
                              //     ),
                              //     Text('One Way'),
                              //     SizedBox(width: 8),
                              //     Radio<String>(
                              //       activeColor: Colors.green,
                              //       value: 'R',
                              //       groupValue: _selectedRadio3,
                              //       onChanged: (String? value) {
                              //         setState(() {
                              //           _selectedRadio3 = value;
                              //         });
                              //       },
                              //     ),
                              //     Text('Round Trip'),
                              //   ],
                              // ),
                              Row(
                                children: [
                                  Expanded(child: Text("Total Tickets: ")),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: null,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade400,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("Itinerary")),
                                  Expanded(child: Text(" Trip Type")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.blueGrey.shade300,
                                        hint: Text("Select"),
                                        value:
                                            itinerary, // Make sure this value is "O" or "R"
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: "O", // "One Way"
                                            child: Text("One Way"),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "R", // "Round Trip"
                                            child: Text("Round Trip"),
                                          ),
                                        ],
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            itinerary = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.blueGrey.shade300,
                                        hint: Text("Select"),
                                        value:
                                            tripType, // Make sure this value is "D" or "I"
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: "D", // "Domestic"
                                            child: Text("Domestic"),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: "I", // "International"
                                            child: Text("International"),
                                          ),
                                        ],
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            tripType = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: Text("Remarks")),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: TextFormField(
                                        controller: tripRemarksController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              if (itinerary == 'O' || itinerary == 'R') ...[
                                Center(
                                    child: Text(
                                  "Departing",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                // SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: Text("Flying From")),
                                    Expanded(child: Text(" Flying To")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              tripDepartingFlyingFromController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              tripDepartingFlyingToController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: Text("Date")),
                                    Expanded(child: Text("  Time")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              departingTripDateController,
                                          decoration: InputDecoration(
                                            hintText: "MM-DD-YYYY",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _selectDepartingTripDate(
                                                      context);
                                                },
                                                icon: Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: Colors.green,
                                                )),
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal:
                                                    10.0), // Adjust padding as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              departingTripTimeController,
                                          decoration: InputDecoration(
                                            hintText: "__:__ __",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _selectDepartingTripTime(
                                                      context);
                                                },
                                                icon: Icon(
                                                  Icons.access_time,
                                                  color: Colors.green,
                                                )),
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal:
                                                    10.0), // Adjust padding as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: Text("Flight No.")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        child: TextFormField(
                                          controller:
                                              tripDepartingFlightNoController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (itinerary == 'R') ...[
                                SizedBox(height: 10),
                                Center(
                                    child: Text(
                                  "Returning",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text("Flying From")),
                                    Expanded(child: Text(" Flying To")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              tripReturningFlyingFromController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              tripReturningFlyingToController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: Text("Date")),
                                    Expanded(child: Text("  Time")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              returningTripDateController,
                                          decoration: InputDecoration(
                                            hintText: "MM-DD-YYYY",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _selectDepartingTripDate(
                                                      context);
                                                },
                                                icon: Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: Colors.green,
                                                )),
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal:
                                                    10.0), // Adjust padding as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        height:
                                            40, // Specify the desired height
                                        child: TextFormField(
                                          controller:
                                              returningTripTimeController,
                                          decoration: InputDecoration(
                                            hintText: "__:__ __",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _selectDepartingTripTime(
                                                      context);
                                                },
                                                icon: Icon(
                                                  Icons.access_time,
                                                  color: Colors.green,
                                                )),
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                                horizontal:
                                                    10.0), // Adjust padding as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: Text("Flight No.")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        child: TextFormField(
                                          controller:
                                              tripReturningFlightNoController,
                                          decoration: InputDecoration(
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () {
                                    saveTripInformation(context);
                                  },
                                  child: Text(
                                    "   Save   ",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(6.0),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.grey;
                                      }
                                      return Colors.green;
                                    }),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    shadowColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            border: Border.all()),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(" Flying From")),
                                            Expanded(child: Text("Flying To")),
                                            Expanded(child: Text("Flight No.")),
                                            Expanded(child: Text("Date")),
                                          ],
                                        ),
                                      ),
                                      FutureBuilder(
                                        future: fetchTripInfo(travelReqId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return Center(
                                                child:
                                                    Text('No data available'));
                                          } else {
                                            final items = snapshot.data!;
                                            debugPrint("Item : ${items}");
                                            return LayoutBuilder(
                                              builder: (context, constraints) {
                                                return ListView.separated(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: items.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container();
                                                  },
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return Divider();
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ]),
                      ),
                      crossFadeState: _isExpanded3
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}