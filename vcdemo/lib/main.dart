import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

SpeechToText _speech = SpeechToText();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Check your throts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "text will apprer here";
  String direction = " ";
  Color buttoncolor = Colors.amberAccent;
  String aboutswitching = "try to speak then it will appear";

  void initSpeech() async {
    bool available = await _speech.initialize();

    if (available) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(result.recognizedWords),
                duration: Duration(milliseconds: 1000),
              ),
            );
            callGeminiApi(result.recognizedWords).then((value) {
              Map<String, dynamic> jsonData = jsonDecode(
                "{${value.split("{")[1].split("}")[0]}}",
              );
              setState(() {
                aboutswitching =
                    " we will go ${jsonData["pages_count"]} pages ${jsonData["direction"]} ";
              });
              getpageto(jsonData["pages_count"], jsonData["direction"]);
              print(jsonData);
            });
          }
        },
      );
    }
  }

  Future<String> callGeminiApi(String words) async {
    const apiKey =
        'AIzaSyC5erK-vNbsCa8tqwFkeZK58e5aHzDCNYg'; // Replace with your actual API key
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  """When the input string relates to page navigation (e.g., "next page", "go back 5 pages", "scroll forward", etc.), it is analyzed to determine two key things: the direction of movement and the number of pages to move. The result is always returned as a JSON string in the following format:
{"direction": "Direction", "pages_count": number}

Here, "Direction" can be one of three values:

"forward" used for commands like "next page", "turn the page", or "scroll forward"

"backward"  used for commands like "go back", "previous page", or "scroll up"

null  used when the command is to go directly to a specific page number, such as "go to page 7" or "open page 10"

In all cases, "pages_count" is an integer. If the number of pages is not specified in the input, it defaults to 1. However, when "direction" is null, "pages_count" represents the exact page number to jump to instead of a relative movement.

For example:

"next page" → {"direction": "forward", "pages_count": 1}

"go back 5 pages" → {"direction": "backward", "pages_count": 5}

"go to page 8" → {"direction": "null", "pages_count": 8}

This is the input string - " $words "


                  """,
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the generated text
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null) {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];
          return generatedText.toString();
        } else {
          return 'not a good speach';
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error making API request: $e');
    }
    return "pata nahi kya hua hai";
  }

  void getpageto(int number, String direction) {
    int? pagenum;
    if (direction == "null") {
      pagenum = number;
    } else if (direction == "forward") {
      pagenum = _pdfController.pageNumber! + number;
    } else if (direction == "backward") {
      pagenum = _pdfController.pageNumber! - number;
    } else {
      pagenum = _pdfController.pageNumber!;
    }
    jumpToPage(pagenum);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("opening page $pagenum"),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  // https://pub.dev/documentation/pdfrx/latest/pdfrx/PdfViewer-class.html
  final _pdfController = PdfViewerController();
  void jumpToPage(int pageNum) {
    _pdfController.goToPage(pageNumber: pageNum);
  }

  void handleVoiceCommand(String result) {
    String command = result;

    setState(() {
      buttoncolor = const Color.fromARGB(255, 8, 7, 0);
      _counter = command;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextField(
          onSubmitted: (value) {
            final page = int.tryParse(value);
            if (page != null) {
              jumpToPage(page - 1); // user types 1-based, we convert to 0-based
            }
          },
        ),
      ),
      body: PdfViewer.asset(
        "assets/pdf_document.pdf",
        controller: _pdfController,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => initSpeech(),
        tooltip: 'speak',
        child: Icon(Icons.mic, color: buttoncolor),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
