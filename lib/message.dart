import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/main.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';

//import 'dart:io';
//import 'package:flutter/services.dart';

class MessagePage extends StatelessWidget {
  // const StorePage({super.key, required this.title});

  final String title = "GPU Store Test";

  //const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        //child: Center(

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              onPressed: () {
                // FFIBridge obj = FFIBridge();
                FFIBridge.initialize(
                    "assets/litmustest_message_passing_default.spv",
                    "assets/litmustest_message_passing_results.spv",
                    "assets/parameters_basic.txt");
              },
              child: Text('Default Explorer'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              onPressed: () {
                FFIBridge.initialize(
                    "assets/litmustest_message_passing_default.spv",
                    "assets/litmustest_message_passing_results.spv",
                    "assets/parameters_stress.txt");
              },
              child: Text('Default Stress'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
              ),
              onPressed: () {
                String outputPath = FFIBridge.getFile();

                // print("getting file");
                // print(outputPath);
                final contents = readCounter(outputPath);

                var output;

                contents.then((value) {
                  output = value;
                  // print("printing from buttons");
                  // print("yo");
                  // print(output);

                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text('Store Test Results'),
                            content: SingleChildScrollView(
                              // won't be scrollable
                              child: Text(output),
                            ),
                          ));
                });
              },
              child: Text('Result'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
              ),
              onPressed: () {
                email();
              },
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> readCounter(String path) async {
  try {
    // Read the file
    File file = await get(path);
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "";
  }
}

Future<File> get(String path) async {
  // final path = await _localPath;

  // print(path);
  return File(path);
}

void email() async {
  String outputPath = FFIBridge.getFile();

  final Email email = Email(
    body: 'Email body',
    subject: 'Test',
    recipients: ['anikam@ucsc.edu'],
    // cc: ['cc@example.com'],
    // bcc: ['bcc@example.com'],
    attachmentPaths: [outputPath],
    // isHTML: false,
  );

  await FlutterEmailSender.send(email);
}
