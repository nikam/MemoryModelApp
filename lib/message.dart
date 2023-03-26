import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpuiosbundle/main.dart';

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
                    "assets/litmustest_store_default.spv",
                    "assets/litmustest_store_results.spv",
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
                    "assets/litmustest_store_default.spv",
                    "assets/litmustest_store_results.spv",
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
