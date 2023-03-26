import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:gpuiosbundle/store.dart';
import 'package:gpuiosbundle/message.dart';

import 'package:path_provider/path_provider.dart';
//import 'package:platform/platform.dart';

import 'dart:io';

class FFIBridge {
  static String outputFile = "";

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

  static void call(String spv, String res, String param) async {
    var shaderComp = await printy(spv);
    var shaderRes = await printy(res);
    // var para = await printy("assets/parameters_basic.txt");
    var para = await printy(param);

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

    outputFile = path + "/output.txt";
  }

  static String getFile() {
    return outputFile;
  }

  static bool initialize(String spv, String res, String param) {
    call(spv, res, param);
    return true;
  }
}

void main() {
  runApp(const MyApp());
  // FFIBridge.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'GPU Memory Model Tests';

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
        //child: Center(
        child: Text(
          'This app uses litmus test to showcase the allowed behavious of GPU memory model. This app is required to be run with Android 8.0+ and IOS 8.0+, and GPU that supports Vulkan 1.1',
          // textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              // <-- SEE HERE
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(
                "Team GPU Harbor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                "InsertgpuHarbor@email.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: FlutterLogo(),
            ),
            ListTile(
              title: const Text('Introduction'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Running Multiple Test'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            Divider(), //here is a divider
            Text(
              "Weak Memory Test",
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            ListTile(
              title: const Text('Message Passing'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MessagePage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Store'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StorePage();
                  }),
                );
                // Navigator.pop(context);
              },
            ),
            const AboutListTile(
              // <-- SEE HERE
              icon: Icon(
                Icons.info,
              ),
              child: Text('About app'),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'Memory Models Testing App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2023 GPU Harbor UCSC Team',
              aboutBoxChildren: [
                ///Content goes here...
              ],
            ),
          ],
        ),
      ),
    );
  }
}
