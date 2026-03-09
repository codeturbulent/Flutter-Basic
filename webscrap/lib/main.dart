import 'package:flutter/material.dart';

import 'package:webscrap/webloginpage.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

void main() {
  runApp(const WebScraper());
}

class WebScraper extends StatefulWidget {
  const WebScraper({super.key});

  @override
  State<WebScraper> createState() => _WebScraperState();
}

class _WebScraperState extends State<WebScraper> {
  void login() async {
    print('Login');
    var url = 'https://bbau.samarth.edu.in/index.php/site/login';
    var response = await http.get(Uri.parse(url));
    var body = response.body;
    var document = html.parse(body.toString());
    var crsfToken = document
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
    print(crsfToken);
    final requrl = Uri.parse(
      'https://bbau.samarth.edu.in/index.php/site/login',
    );

    // Define the headers
    final reqheaders = {'Content-Type': 'application/x-www-form-urlencoded'};
    // Define the body
    final reqbody = {
      '_csrf': '$crsfToken',
      'LoginForm[username]': '1796/24',
      'LoginForm[password]': 'Hy@1740343',
    };

    // Send the POST request
    final reqresponse = await http.post(
      requrl,
      headers: reqheaders,
      body: reqbody.toString(),
    );

    // Check the response
    if (reqresponse.statusCode == 200) {
      print('Request successful: ${reqresponse.body}');
    } else {
      print('Request failed with status: ${reqresponse.statusCode}');
      print('Request failed with status: ${reqresponse.body}');
    }
  }

  void trythis() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: WebLoginPage(),
      // home: Scaffold(
      //   appBar: AppBar(title: Text('Web Scraper')),
      //   body:
      // ),
    );
  }
}
