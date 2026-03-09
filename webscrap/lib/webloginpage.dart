import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebLoginPage extends StatefulWidget {
  @override
  _WebLoginPageState createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage> {
  late final WebViewController _controller;
  TextEditingController loginusername = TextEditingController();
  TextEditingController loginpassword = TextEditingController();

  String username = "BBAu";
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'getprofile',
        onMessageReceived: (msg) {
          print("Got profile: ${msg.message}");
          setState(() {
            username = msg.message;
          });
        },
      )
      ..loadRequest(
        Uri.parse('https://bbau.samarth.edu.in/index.php/site/login'),
      );
  }

  void _injectJS() async {
    await _controller.runJavaScript('''
      document.querySelector('input[name="LoginForm[username]"]').value = "${loginusername.text}";
      document.querySelector('input[name="LoginForm[password]"]').value = "${loginpassword.text}";
      var loginbutton = document.querySelector('#login-form button[type="submit"]').click();
    ''');
  }

  void gotoprofile() async {
    await _controller.runJavaScript('''
window.location.href = 'https://bbau.samarth.edu.in/index.php/vidhyarthi/profile/index';
''');
  }

  void gotologin() async {
    await _controller.runJavaScript('''
 document.querySelector("body > div.be-wrapper.be-fixed-sidebar > nav > div > div.be-right-navbar > ul > li > div > a > span").click();


''');
    setState(() {
      username = "BBAU login";
    });
  }

  void extractprofileinfo() async {
    String username1 =
        await _controller.runJavaScriptReturningResult('''
  (() => {
    var elem = document.querySelector("body > div.be-wrapper.be-fixed-sidebar > div.be-content > div > div:nth-child(3) > div > div > div:nth-child(1) > div > div.col-md-9.col-sm-12 > strong");
    return elem ? elem.textContent.trim() : "Not Found";
  })();
''')
            as String;
    print(username1);
    setState(() {
      username = username1;
    });
    //     await _controller.runJavaScript("""
    //   var elem = document.querySelector("body > div.be-wrapper.be-fixed-sidebar > div.be-content > div > div:nth-child(3) > div > div > div:nth-child(1) > div > div.col-md-9.col-sm-12 > strong");
    //   if (elem) {
    //   console.log("elementfound")
    //       window.getprofile.postMessage(elem.textContent.trim());
    //     } else {
    //      console.log("elementnotfound")
    //       getprofile.postMessage('Username not found');
    //     }
    // """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        leading: IconButton(
          onPressed: () {
            gotoprofile();
            extractprofileinfo();
          },
          icon: Icon(Icons.verified_user),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: 0,
            height: 0,
            child: WebViewWidget(controller: _controller),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(10),
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),

                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('User Name'),
                        SizedBox(height: 10),
                        TextField(
                          controller: loginusername,
                          decoration: InputDecoration(
                            hintText: 'User Name ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        Text('Password'),
                        SizedBox(height: 10),
                        TextField(
                          controller: loginpassword,
                          decoration: InputDecoration(
                            hintText: 'Password ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      gotologin();
                      _injectJS();
                    },
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      gotologin();
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
              // Container(
              //   height: 500,
              //   child: WebViewWidget(controller: _controller),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
