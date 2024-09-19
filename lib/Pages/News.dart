import 'dart:convert';

import 'package:airsial_app/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';

import '../model/news_model.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  late Future<List<NewsModel>> futureNews;

  Future<List<NewsModel>> fetchNews() async {
    final response = await http.get(
        Uri.parse("https://erm.scarletsystems.com:2030/Api/News/GetallNews"));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<NewsModel> news =
          body.map((dynamic item) => NewsModel.fromJson(item)).toList();
      return news;
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureNews = fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("News"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NewsModel>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load news'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          } else {
            // Get the length of the list
            int newsLength = snapshot.data!.length;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: newsLength,
                      itemBuilder: (context, index) {
                        final news = snapshot.data![index];
                        return Container(
                          padding: EdgeInsets.all(12.0),
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey.shade700,
                                    Colors.greenAccent,
                                  ])),
                          child: Column(
                            children: [
                              Text(
                                "${news.tITILE}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              ReadMoreText(
                                textAlign: TextAlign.justify,
                                '${news.mSG} Hi Hello Hi Hello Hi Hello Testing Test Testing Test Testing Length Length Value',
                                trimMode: TrimMode.Line,
                                trimLines: 3,
                                colorClickableText: Colors.pink,
                                trimCollapsedText: 'Show more',
                                trimExpandedText: ' Show less',
                                lessStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                                moreStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
