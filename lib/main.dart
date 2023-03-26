import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:path_provider/path_provider.dart';
//import 'package:platform/platform.dart';

import 'dart:io';

class FFIBridge {
  static const platformMethodChannel =
      MethodChannel('com.flutter.gpuiosbundle/getPath');

  static Future<String> printy(String arg) async {
    // String value = "";

    var tmp;

    try {
      tmp = await platformMethodChannel.invokeMethod<String>('printy', arg);
    } catch (e) {
      print(e);
    }

    return tmp;
  }

  static void call() async {
    // print("inside aysnc");

    var shaderComp = await printy("assets/litmustest_store_default.spv");
    var shaderRes = await printy("assets/litmustest_store_results.spv");
    var para = await printy("assets/parameters_basic.txt");

    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path;

    DynamicLibrary nativeApiLib = DynamicLibrary.process();
    // final runPointer = nativeApiLib.lookup<NativeFunction<run_test>>('runTest');

    final int Function(Pointer<Utf8> a, Pointer<Utf8> b, Pointer<Utf8> c,
            Pointer<Utf8> d, Pointer<Utf8> e) run =
        nativeApiLib
            .lookup<
                NativeFunction<
                    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
                        Pointer<Utf8>, Pointer<Utf8>)>>('runTest')
            .asFunction();

    String test = "Store";
    run(test.toNativeUtf8(), shaderComp.toNativeUtf8(),
        shaderRes.toNativeUtf8(), para.toNativeUtf8(), path.toNativeUtf8());
  }

  static bool initialize() {
    call();
    return true;
  }
}

void main() {
  runApp(const MyApp());
  FFIBridge.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('My Page!'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
