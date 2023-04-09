import 'dart:async';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_isolate/flutter_isolate.dart';

typedef Native_Dart_InitializeApiDL = Int32 Function(Pointer<Void> data);
typedef FFI_Dart_InitializeApiDL = int Function(Pointer<Void> data);
typedef StartWorkType = Void Function(Int64 port);
typedef StartWorkFunc = void Function(int port);

const platformMethodChannel = MethodChannel('com.flutter.gpuiosbundle/getPath');

final controller = StreamController.broadcast();

var iter = 0;
String outputFile = "";

/////// message passer c++ to dart//////////
void mssg_init(SendPort port) {
  DynamicLibrary nativeApi = DynamicLibrary.process();

  // Dart_InitializeApiDL defined in Dart SDK (implemented in dart_api_dl.c)
  FFI_Dart_InitializeApiDL initializeFunc = nativeApi.lookupFunction<
      Native_Dart_InitializeApiDL, FFI_Dart_InitializeApiDL>("initDartApiDL");

  if (initializeFunc(NativeApi.initializeApiDLData) != 0) {
    throw "Failed to initialize Dart API";
  }

  final StartWorkFunc startWork =
      nativeApi.lookup<NativeFunction<StartWorkType>>("startWork").asFunction();

  final interactiveCppRequests = ReceivePort();

  interactiveCppRequests.listen((data) {
    iter = data;
    // print('Received: $iter from C++');
    port.send(data);
    // interactiveCppRequests.close();
  });

  final int nativePort = interactiveCppRequests.sendPort.nativePort;

// first we establish the port details
  startWork(nativePort);
}

// I am platform channel code
Future<String> printy(String arg) async {
  dynamic tmp;

  //print(arg);

  try {
    tmp = await platformMethodChannel.invokeMethod<String>('printy', arg);

    //print(tmp);
  } catch (e) {
    print(e);
  }

  return tmp;
}

/// I am isolate code/////
class FFIBridge {
  static Future<void> run_isolate(
      var shaderComp, var shaderRes, var para, var path) async {
    List<String> list = [shaderComp, shaderRes, para, path];

    var rPort1 = new ReceivePort();

    rPort1.listen((data) {
      iter = data;
      controller.sink.add(data);
      // print('Received: $data from Isolate');
      // interactiveCppRequests.close();
    });

    Map<int, dynamic> map = new Map();

    map[1] = rPort1.sendPort;
    map[2] = list;

    //  try {
    await Isolate.spawn(native_call, map);
  }

//@pragma('vm:entry-point')
  static void native_call(Map<int, dynamic> map) {
    List<String> arg = map[2];
    SendPort sport = map[1];

    mssg_init(sport);

    DynamicLibrary nativeApiLib = DynamicLibrary.process();

    final int Function(Pointer<Utf8> a, Pointer<Utf8> b, Pointer<Utf8> c,
            Pointer<Utf8> d, Pointer<Utf8> e) run =
        nativeApiLib
            .lookup<
                NativeFunction<
                    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
                        Pointer<Utf8>, Pointer<Utf8>)>>('runTest')
            .asFunction();

    String test = "Store";

    //int litmus_test =
    run(test.toNativeUtf8(), arg[0].toNativeUtf8(), arg[1].toNativeUtf8(),
        arg[2].toNativeUtf8(), arg[3].toNativeUtf8());
  }

  static Future<void> call(String spv, String res, String param) async {
    var shaderComp = await printy(spv);
    var shaderRes = await printy(res);
    var para = await printy(param);

    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path;

    outputFile = "$path/output.txt";

    await run_isolate(shaderComp, shaderRes, para, path);

    //  print("after isolate kill: " + outputFile);
  }

  static String getFile() {
    return outputFile;
  }
}

Future<void> call_bridge(String param, String shader, String result) async {
  await FFIBridge.call(shader, result, param);
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
  //print(path);
  return File(path);
}
