import 'dart:convert';

import 'package:airsial_app/Pages/travel_authorization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Ticketing extends StatefulWidget {
  const Ticketing({super.key});

  @override
  State<Ticketing> createState() => _TicketingState();
}

class _TicketingState extends State<Ticketing> {
  Widget customContainer({
    required String title,
    required String number,
    required String description,
    required Color containerColor,
    required width,
  }) {
    return Container(
      padding: EdgeInsets.all(10.0),
      height: 120,
      width: width,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 5),
          Divider(color: Colors.white),
          SizedBox(height: 5),
          Text(
            number,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  var account;
  var folio;
  var apiResponse;
  var Dbal;
  var Ibal;
  var Tbal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetStorage _box = GetStorage();
    account = _box.read("account");
    folio = _box.read("folio");
    getTickets(folio, account);
  }

  Future<void> getTickets(String cnic, account) async {
    debugPrint("Folio : $folio");
    debugPrint("Account : ${account.toString()}");
    final url = Uri.parse(
        'https://erm.scarletsystems.com:2030/Api/SHInfo/GetTicketBal?folno=$folio&STYPE=$account');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          apiResponse = json.decode(response.body);
          if(account == "S") {
            Dbal = apiResponse!["DOMBalance"].toInt();
            Ibal = apiResponse!["INTBalance"].toInt();
          } else {
            Tbal = apiResponse["TBALANCE"].toInt();
          }
        });
        debugPrint('Domestic Tickets : ${apiResponse["TBALANCE"].toInt()}');
        // debugPrint('International Tickets : ${apiResponse!["INTBalance"]}');
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text("AirSial"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Icon(
                  Icons.library_books_outlined,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ticketing Dashboard",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("View and manage your ticket balances"),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              Get.to(() => TravelAuthorization(),
                  transition: Transition.leftToRightWithFade);
            },
            child: Container(
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Icon(
                    Icons.add,
                    size: 28,
                    color: Colors.blueAccent,
                  ),
                  Text(
                    " Create New Ticket Request",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          if (account == "S") ...[
            customContainer(
              width: MediaQuery.of(context).size.width * 0.92,
              title: "International Tickets",
              number: Ibal == null ? "__" : "$Ibal",
              description: "Number of International Tickets Available",
              containerColor: Colors.blueAccent,
            ),
            SizedBox(height: 20),
            customContainer(
              width: MediaQuery.of(context).size.width * 0.92,
              title: "Domestic Tickets",
              number: Dbal == null ? "__" : "$Dbal",
              description: "Number of Domestic Tickets Available",
              containerColor: Colors.green,
            ),
          ],
          if (account == "D") ...[
            Container(
              padding: EdgeInsets.all(10.0),
              height: 120,
              width: MediaQuery.of(context).size.width * 0.92,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blueAccent, Colors.green]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Tickets",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.white),
                  SizedBox(height: 5),
                  Text(
                    Tbal == null ? "__" : "$Tbal",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Number of tickets available",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
