import 'dart:convert';

import 'package:airsial_app/model/profile_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController folioController = TextEditingController();
  TextEditingController shareholderController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController shareholdingController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController ntnController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  TextEditingController memorandumController = TextEditingController();

  var cnic = '';
  var folio = '';
  var fkunit;
  String? name;
  bool isLoading = false;

  Future updateProfileData() async {
    try {
      var url = Uri.parse(
          'https://erm.scarletsystems.com:2030/Api/Login/UpdateShareholder');

      Map<String, dynamic> body = {
        "FOLNO": "$folio",
        "FKUNIT": "$fkunit",
        "SHNAME": "${shareholderController.text}",
        "SHFNAME": "${nameController.text}",
        "HOLDING": "${shareholdingController.text}",
        "ADRS": "${addressController.text}",
        "CNIC": "${cnicController.text}",
        "MOBILE_NO": "${mobileController.text}",
        "NTN": "${mobileController.text}",
        "TAX": "${taxController.text}",
        "EMAIL_ID": "${emailController.text}",
        "MEMORANDUM": "${memorandumController.text}"
      };

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        // setState(() {
        //   isLoading = !isLoading;
        // });
        Fluttertoast.showToast(
            msg: "Data Saved Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
        debugPrint('Request status code: ${response.statusCode}');
      } else {
        setState(() {
          isLoading = !isLoading;
        });
        debugPrint('Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        Fluttertoast.showToast(
            msg: "Failed To Save Record",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
      }
    } catch (e) {
      debugPrint("Error: $e");
      throw e;
    }
  }

  Future<ProfileModel> fetchShareholderData(String folioNumber) async {
    final response = await http.get(Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/Login/GetByIdSH?folno=$folioNumber'));

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    final _box = GetStorage();
    folio = _box.read('folio');
    cnic = _box.read('cnic');
    name = _box.read('shname');
    fetchShareholderData(folio);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text("Profile Update"),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding:
              const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 30),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Colors.white70,
                Color(0xFFc0995b),
                Colors.orange.shade200,
                Color(0xFFc0995b),
              ])),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 51, 80, 165),
                      // radius: 20,
                      backgroundImage: GetStorage().read('profileImage') != null
                          ? MemoryImage(
                              base64Decode(GetStorage().read('profileImage')!))
                          : AssetImage("assets/images/user.png")
                              as ImageProvider<Object>,
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          "$name",
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("CNIC: $cnic"),
                      ],
                    )
                  ],
                ),
                Divider(
                  endIndent: 20,
                  indent: 20,
                ),
                SizedBox(height: 10),
                FutureBuilder<ProfileModel>(
                    future: fetchShareholderData(folio),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data found'));
                      } else {
                        final data = snapshot.data!;
                        fkunit = data.fKUNIT;
                        folioController.text = data.fOLNO!;
                        shareholderController.text =
                            data.sHNAME == null ? '' : data.sHNAME!;
                        nameController.text =
                            data.sHFNAME == null ? '' : data.sHFNAME!;
                        shareholdingController.text = data.hOLDING == null
                            ? ''
                            : data.hOLDING!.toString();
                        addressController.text =
                            data.aDRS == null ? '' : data.aDRS!;
                        cityController.text =
                            data.fKCITY == null ? '' : data.fKCITY!;
                        cnicController.text =
                            data.cNIC == null ? '' : data.cNIC!;
                        mobileController.text =
                            data.mOBILENO == null ? '' : data.mOBILENO!;
                        ntnController.text = data.nTN == null ? '' : data.nTN!;
                        taxController.text = data.tAX == null ? '' : data.tAX!;
                        emailController.text =
                            data.eMAILID == null ? '' : data.eMAILID!;
                        memorandumController.text =
                            data.mANDATE == null ? '' : data.mANDATE!;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(" Folio Number"),
                                    TextFormField(
                                      controller: folioController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade300,
                                          filled: true,
                                          hintText: "${data.fOLNO}",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Father/Husband Name"),
                                    TextFormField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                    )
                                  ],
                                )),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(" Shareholder Name"),
                                    TextFormField(
                                      controller: shareholderController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade300,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Shareholding"),
                                    TextFormField(
                                      controller: shareholdingController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade300,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    )
                                  ],
                                )),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(" Address"),
                            TextFormField(
                              controller: addressController,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(" City"),
                                    TextFormField(
                                      controller: cityController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Mobile"),
                                    TextFormField(
                                      controller: mobileController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Tax"),
                                    TextFormField(
                                      controller: taxController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Category"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "Category",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Joint Holders"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "--Select--",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Occupation"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "Business",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Nationality"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "Pakistani",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Reference Name"),
                                    TextFormField(
                                      controller: referenceController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                  ],
                                )),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(" CNIC Number"),
                                    TextFormField(
                                      controller: cnicController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" N.T.N"),
                                    TextFormField(
                                      controller: ntnController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Exempted Upto"),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "DD-MM-YYYY",
                                          suffixIcon:
                                              Icon(Icons.calendar_month),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Email Id"),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Filer"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "Filer",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Resident"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "---Select---",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Zakat"),
                                    DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSelectedItems: true,
                                        //disabledItemFn: (String s) => s.startsWith('I'),
                                      ),
                                      items: [
                                        "Category1",
                                        "Category2",
                                        "Category3"
                                      ],
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                // labelText: "Menu mode",
                                                hintText:
                                                    "country in menu mode",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                      ),
                                      onChanged: print,
                                      selectedItem: "Applicable",
                                    ),
                                    SizedBox(height: 10),
                                    Text(" Memorandum"),
                                    TextFormField(
                                      controller: memorandumController,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {
                                  // setState(() {
                                  //   isLoading = !isLoading;
                                  // });
                                  updateProfileData();
                                },
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "   Save   ",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.all<double>(6.0),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.grey;
                                    }
                                    return Colors.green;
                                  }),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
