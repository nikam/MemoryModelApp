import 'dart:convert';
import 'dart:ffi';
//import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';
import 'package:path_provider/path_provider.dart';

String shader_spv = "assets/litmustest_message_passing_default.spv";
String result_spv = "assets/litmustest_message_passing_results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";
const String title = "Tuning/Conformance";

const String page =
    "This page is used to evaluate the performance of a set tuned parameters on uncovering potential violations of Vulkan memory consistency model. There will be two methods of running weak memory tests: running with single memory location and running with barriers between instructions. There will also be two methods of running coherence tests: running with single memory location and running with RMW instruction. A weak behaviour on any test represents a violation of Vulkan memory consistency model.";
const String init_state = "*x = 0, *y = 0";
const String final_state = "r0 == 1 && r1 == 0";
const String workgroup0_thread0_text1 =
    "0.1: atomic_store_explicit (x,1,memory_order_relaxed)";
const String workgroup0_thread0_text2 =
    "0.2: atomic_store_explicit (y,1,memory_order_relaxed)";
const String workgroup1_thread0_text1 =
    "1.1: r0 = atomic_load_explicit (y,memory_order_relaxed)";
const String workgroup1_thread0_text2 =
    "1.2: r1 = atomic_load_explicit (x,memory_order_relaxed)";

// create statefull widget class
class TuningPage extends StatefulWidget {
  const TuningPage({Key? key}) : super(key: key);

  @override
  State<TuningPage> createState() => _TuningPageState();
}

// extend the class
class _TuningPageState extends State<TuningPage> {
  final String _title = title;
  final _formKey = GlobalKey<FormState>();
  TextEditingController userInput = TextEditingController();

  late String _iterationMssg;
  // bool something  = true;
  late bool _visible;
  late bool _isExplorerButtonDisabled;
  late bool _isStressButtonDisabled;
  late bool _isResultButtonDisabled;
  late bool _isEmailButtonDisabled;
  late int _counter;
  final subscription = controller.stream;
  bool default_param = true;

  var pressExplorer = false;
  var pressTuning = false;
  var pressConformance = false;

  var _visibleExplorer = false;
  var _visibleTuning = false;
  //var _visibleConformance = false;

  // var isChecked = false;

  var mssgPassingCoherency = false;
  var storecoherency = false;
  var readcoherency = false;
  var storebuffer = false;
  var twoplus2writecoherency = false;
  var mssgpassingbarrier = false;
  var storebarrier = false;
  var readrmwbarrier = false;
  var loadbufferbarrier = false;
  var storebufferbarrier = false;
  var storebufferrmwbarrier = false;
  var twoplus2writermw = false;
  var twoplus2writermwbarrier = false;
  var rmwbarrier = false;
  var rr = false;
  var rrrmw = false;
  var rw = false;
  var rwrmw = false;
  var wr = false;
  var wrrmw = false;
  var ww = false;
  var wwrmw = false;

  var mssgPassing = false;
  var mssgPassingCoherency_mutant = false;
  var mssgPassingbarrier1 = false;
  var mssgPassingbarrier2 = false;
  var loadbuffer = false;
  var loadbuffercoherency = false;
  var loadbuffercoherency_mutant = false;
  var loadbufferbarrier1 = false;
  var loadbufferbarrier2 = false;
  var readrmw = false;
  var readcoherency_mutant = false;
  var readrmwbarrier1 = false;
  var readrmwbarrier2 = false;
  var store = false;
  var storecoherency_mutant = false;
  var storebarrier1 = false;
  var storebarrier2 = false;
  var storebufferrmw = false;
  var storebuffercoherency_mutant = false;
  var storebufferrmwbarrier1 = false;
  var storebufferrmwbarrier2 = false;
  var twoplus2write = false;
  var twoplus2writecoherency_mutant = false;
  var twoplus2writermwbarrier1 = false;
  var twoplus2writermwbarrier2 = false;
  var rr_mutant = false;
  var rrrmw_mutant = false;
  var rw_mutant = false;
  var rwrmw_mutant = false;
  var wr_mutant = false;
  var wrrmw_mutant = false;
  var ww_mutant = false;
  var wwrmw_mutant = false;

// explorer controllers
  TextEditingController _iter = TextEditingController(text: '100');
  TextEditingController _workgroup = TextEditingController(text: '2');
  TextEditingController _maxworkgroup = TextEditingController(text: '4');
  TextEditingController _size = TextEditingController(text: '256');
  TextEditingController _shufflepct = TextEditingController(text: '0');
  TextEditingController _barrierpct = TextEditingController(text: '0');
  TextEditingController _scratchMemSize = TextEditingController(text: '2048');
  TextEditingController _memStride = TextEditingController(text: '1');
  TextEditingController _memStressPct = TextEditingController(text: '0');
  TextEditingController _memStressIter = TextEditingController(text: '1024');
  TextEditingController _memStressStoreFirstPct =
      TextEditingController(text: '0');
  TextEditingController _memStressStoreSecondPct =
      TextEditingController(text: '100');
  TextEditingController _preStressPct = TextEditingController(text: '0');
  TextEditingController _preStressIter = TextEditingController(text: '128');
  TextEditingController _preStressStoreFirstPct =
      TextEditingController(text: '0');
  TextEditingController _preStressStoreSecondPct =
      TextEditingController(text: '0');
  TextEditingController _stressLineSize = TextEditingController(text: '64');
  TextEditingController _stressTargetLines = TextEditingController(text: '2');
  TextEditingController _stressAssignmentStrategy =
      TextEditingController(text: '100');
  TextEditingController _numMemLocations = TextEditingController(text: '2');
  TextEditingController _numOutputs = TextEditingController(text: '2');

  // tuning controllers
  TextEditingController _tIter = TextEditingController(text: '100');
  TextEditingController _tConfigNum = TextEditingController(text: '10');
  TextEditingController _tRandomSeed = TextEditingController(text: '');
  TextEditingController _tWorkgroup = TextEditingController(text: '2');
  TextEditingController _tMaxworkgroup = TextEditingController(text: '4');
  TextEditingController _tSize = TextEditingController(text: '256');

  @override
  void initState() {
    super.initState();

    _counter = 0;
    _isExplorerButtonDisabled = true;
    _isStressButtonDisabled = true;
    _isResultButtonDisabled = true;
    _isEmailButtonDisabled = true;
    _visible = false;
    _iterationMssg = "Counter is 0";
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _tuningClick() {
    print("reached here");
    FFIBridge.tuning(
        "Tuning Test",
        shader_spv,
        result_spv,
        _tConfigNum.text,
        _tIter.text,
        _tRandomSeed.text,
        _tWorkgroup.text,
        _tMaxworkgroup.text,
        _tSize.text);
  }

  void _changeStress() {
    _iter.text = '100';
    _workgroup.text = '2';
    _maxworkgroup.text = '4';
    _size.text = '256';
    _shufflepct.text = '0';
    _barrierpct.text = '0';
    _scratchMemSize.text = '2048';
    _memStride.text = '1';
    _memStressPct.text = '0';
    _memStressIter.text = '1024';
    _memStressStoreFirstPct.text = '0';
    _memStressStoreSecondPct.text = '100';
    _preStressPct.text = '0';
    _preStressIter.text = '128';
    _preStressStoreFirstPct.text = '0';
    _preStressStoreSecondPct.text = '0';
    _stressLineSize.text = '64';
    _stressTargetLines.text = '2';
    _stressAssignmentStrategy.text = '100';
  }

  void _changeDefault() {
    _iter.text = '100';
    _workgroup.text = '512';
    _maxworkgroup.text = '1024';
    _size.text = '256';
    _shufflepct.text = '100';
    _barrierpct.text = '100';
    _scratchMemSize.text = '2048';
    _memStride.text = '4';
    _memStressPct.text = '100';
    _memStressIter.text = '1024';
    _memStressStoreFirstPct.text = '0';
    _memStressStoreSecondPct.text = '100';
    _preStressPct.text = '100';
    _preStressIter.text = '128';
    _preStressStoreFirstPct.text = '0';
    _preStressStoreSecondPct.text = '100';
    _stressLineSize.text = '64';
    _stressTargetLines.text = '2';
    _stressAssignmentStrategy.text = '100';
  }

  void _compute() async {
    setState(() {
      _counter = 0;

      _isExplorerButtonDisabled = false;
      _isStressButtonDisabled = false;
      _isResultButtonDisabled = false;
      _isEmailButtonDisabled = false;

      _iterationMssg = "Computed $_counter from 100";
      _visible = true;
    });

    subscription.listen((data) {
      _counter = data;
      // print(_counter);
      setState(() {
        _iterationMssg = "Computed $_counter from 100";
      });
    });

    // print("I am here");

    writeDefault();

    setState(() {
      _isExplorerButtonDisabled = true;
      _isStressButtonDisabled = true;
      _isResultButtonDisabled = true;
      _isEmailButtonDisabled = true;
    });

    // print("when done");
  }

  void writeDefault() async {
    //print("we here");
    Map<String, dynamic> tuningParam = new Map();

    tuningParam["iterations"] = _iter.text;
    tuningParam["testingWorkgroups"] = _workgroup.text;
    tuningParam["maxWorkgroups"] = _maxworkgroup.text;
    tuningParam["workgroupSize"] = _size.text;
    tuningParam["shufflePct"] = _shufflepct.text;
    tuningParam["barrierPct"] = _barrierpct.text;
    tuningParam["scratchMemorySize"] = _scratchMemSize.text;
    tuningParam["memStride"] = _memStride.text;
    tuningParam["memStressPct"] = _memStressPct.text;
    tuningParam["preStressPct"] = _preStressPct.text;
    tuningParam["memStressIterations"] = _memStressIter.text;
    tuningParam["preStressIterations"] = _preStressIter.text;
    tuningParam["stressLineSize"] = _stressLineSize.text;
    tuningParam["stressTargetLines"] = _stressTargetLines.text;
    tuningParam["stressStrategyBalancePct"] = _stressAssignmentStrategy.text;
    tuningParam["memStressStoreFirstPct"] = _memStressStoreFirstPct.text;
    tuningParam["memStressStoreSecondPct"] = _memStressStoreSecondPct.text;
    tuningParam["preStressStoreFirstPct"] = _preStressStoreFirstPct.text;
    tuningParam["preStressStoreSecondPct"] = _preStressStoreSecondPct.text;
    tuningParam["numMemLocations"] = 2;
    tuningParam["numOutputs"] = 2;

    Directory tempDir = await getTemporaryDirectory();

    // assign the global path value
    cache = tempDir.path;

    param_tmp = "$cache/$param_tmp";

    //print(param_tmp);

    // now we write these parameters to our cache file

    // if the file exists delete it
    if (await File(param_tmp).exists()) {
      await File(param_tmp).delete();
    }

    File file = await File(param_tmp).create(recursive: true);

    tuningParam.forEach((key, value) async {
      file.writeAsStringSync("${key}=${value} \n", mode: FileMode.append);
      //print("${key} = ${value}");
    });

    print(param_tmp);

    File(param_tmp)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((l) => print('line: $l'));

    call_bridge(param_tmp, shader_spv, result_spv);
  }

  void _results() {
    String outputPath = FFIBridge.getFile();

    final contents = readCounter(outputPath);

    dynamic output;

    contents.then((value) {
      output = value;

      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Message Test Results'),
                content: SingleChildScrollView(
                  // won't be scrollable
                  child: Text(output),
                ),
              ));
    });
  }

  void _chooseConformanceTests() {
    setState(() {
      mssgPassingCoherency = true;
      storecoherency = true;
      readcoherency = true;
      storebuffer = true;
      // storebufferrmw = true;
      twoplus2writecoherency = true;
      mssgpassingbarrier = true;
      storebarrier = true;
      // storebufferrmw = true;
      readrmwbarrier = true;
      loadbufferbarrier = true;
      loadbuffercoherency = true;
      storebufferbarrier = true;
      storebufferrmwbarrier = true;
      twoplus2writermwbarrier = true;
      rmwbarrier = true;
      rr = true;
      rrrmw = true;
      rw = true;
      rwrmw = true;
      wr = true;
      wrrmw = true;
      ww = true;
      wwrmw = true;
    });
  }

  void _chooseTuning() {
    setState(() {
      mssgPassing = true;
      mssgPassingCoherency_mutant = true;
      mssgPassingbarrier1 = true;
      mssgPassingbarrier2 = true;
      loadbuffer = true;
      // loadbuffercoherency = true;
      loadbuffercoherency_mutant = true;
      loadbufferbarrier1 = true;
      loadbufferbarrier2 = true;
      readrmw = true;
      readcoherency_mutant = true;
      readrmwbarrier1 = true;
      readrmwbarrier2 = true;
      store = true;
      storecoherency_mutant = true;
      storebarrier1 = true;
      storebarrier2 = true;
      storebufferrmw = true;
      storebuffercoherency_mutant = true;
      storebufferrmwbarrier1 = true;
      storebufferrmwbarrier2 = true;
      twoplus2write = true;
      twoplus2writecoherency_mutant = true;
      twoplus2writermwbarrier1 = true;
      twoplus2writermwbarrier2 = true;
      rr_mutant = true;
      rrrmw_mutant = true;
      rw_mutant = true;
      rwrmw_mutant = true;
      wr_mutant = true;
      wrrmw_mutant = true;
      ww_mutant = true;
      wwrmw_mutant = true;
    });
  }

  void _chooseAllTests() {
    setState(() {
      mssgPassingCoherency = true;
      storecoherency = true;
      readcoherency = true;
      storebuffer = true;
      twoplus2writecoherency = true;
      mssgpassingbarrier = true;
      storebarrier = true;
      readrmwbarrier = true;
      loadbufferbarrier = true;
      storebufferbarrier = true;
      storebufferrmwbarrier = true;
      twoplus2writermw = true;
      twoplus2writermwbarrier = true;
      rmwbarrier = true;
      rr = true;
      rrrmw = true;
      rw = true;
      rwrmw = true;
      wr = true;
      wrrmw = true;
      ww = true;
      wwrmw = true;

      mssgPassing = true;
      mssgPassingCoherency_mutant = true;
      mssgPassingbarrier1 = true;
      mssgPassingbarrier2 = true;
      loadbuffer = true;
      loadbuffercoherency = true;
      loadbuffercoherency_mutant = true;
      loadbufferbarrier1 = true;
      loadbufferbarrier2 = true;
      readrmw = true;
      readcoherency_mutant = true;
      readrmwbarrier1 = true;
      readrmwbarrier2 = true;
      store = true;
      storecoherency_mutant = true;
      storebarrier1 = true;
      storebarrier2 = true;
      storebufferrmw = true;
      storebuffercoherency_mutant = true;
      storebufferrmwbarrier1 = true;
      storebufferrmwbarrier2 = true;
      twoplus2write = true;
      twoplus2writecoherency_mutant = true;
      twoplus2writermwbarrier1 = true;
      twoplus2writermwbarrier2 = true;
      rr_mutant = true;
      rrrmw_mutant = true;
      rw_mutant = true;
      rwrmw_mutant = true;
      wr_mutant = true;
      wrrmw_mutant = true;
      ww_mutant = true;
      wwrmw_mutant = true;
    });
  }

  void _chooseClearSelection() {
    setState(() {
      mssgPassingCoherency = false;
      storecoherency = false;
      readcoherency = false;
      storebuffer = false;
      twoplus2writecoherency = false;
      mssgpassingbarrier = false;
      storebarrier = false;
      readrmwbarrier = false;
      loadbufferbarrier = false;
      storebufferbarrier = false;
      storebufferrmwbarrier = false;
      twoplus2writermw = false;
      twoplus2writermwbarrier = false;
      rmwbarrier = false;
      rr = false;
      rrrmw = false;
      rw = false;
      rwrmw = false;
      wr = false;
      wrrmw = false;
      ww = false;
      wwrmw = false;

      mssgPassing = false;
      mssgPassingCoherency_mutant = false;
      mssgPassingbarrier1 = false;
      mssgPassingbarrier2 = false;
      loadbuffer = false;
      loadbuffercoherency = false;
      loadbuffercoherency_mutant = false;
      loadbufferbarrier1 = false;
      loadbufferbarrier2 = false;
      readrmw = false;
      readcoherency_mutant = false;
      readrmwbarrier1 = false;
      readrmwbarrier2 = false;
      store = false;
      storecoherency_mutant = false;
      storebarrier1 = false;
      storebarrier2 = false;
      storebufferrmw = false;
      storebuffercoherency_mutant = false;
      storebufferrmwbarrier1 = false;
      storebufferrmwbarrier2 = false;
      twoplus2write = false;
      twoplus2writecoherency_mutant = false;
      twoplus2writermwbarrier1 = false;
      twoplus2writermwbarrier2 = false;
      rr_mutant = false;
      rrrmw_mutant = false;
      rw_mutant = false;
      rwrmw_mutant = false;
      wr_mutant = false;
      wrrmw_mutant = false;
      ww_mutant = false;
      wwrmw_mutant = false;
    });
  }

  showExplorerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 10.0,
            ),
            title: Text(
              "Message Passing",
              style: TextStyle(fontSize: 24.0),
            ),
            content: Container(
              height: 400,
              //width: 400, //or whatever you want

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // child:
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Test Iteration:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _iter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Testing Workgroups',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _workgroup,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Max Workgroup:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _maxworkgroup,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Workgroup Size:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _size,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Shuffle Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _shufflepct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Barrier Perecentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _barrierpct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Scratch Memory Size:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _scratchMemSize,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stride:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStride,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Iterations',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressIter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Store First Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressStoreFirstPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Memory Stress Store Second Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _memStressStoreSecondPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Percentage:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Iterations:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressIter,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Store First Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressStoreFirstPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Pre Stress Store Second Pct:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _preStressStoreSecondPct,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Line Size:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressLineSize,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Target Lines:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressTargetLines,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Stress Assignment Strategy:',
                                    ),
                                  ),
                                  // SizedBox(width: 30),
                                  SizedBox(
                                      width: 50,
                                      child: TextField(
                                        controller: _stressAssignmentStrategy,
                                        textAlign: TextAlign.center,
                                      )),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Test Parameters Presets",
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Wrap(children: <Widget>[
                                  Container(
                                    //  width: double.infinity,
                                    height: 60,
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _changeStress();
                                        // Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.cyan,
                                        // fixedSize: Size(250, 50),
                                      ),
                                      child: const Text(
                                        "Default",
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // width: double.infinity,
                                    height: 60,
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _changeDefault();
                                        //Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                        // fixedSize: Size(250, 50),
                                      ),
                                      child: const Text(
                                        "Stress",
                                      ),
                                    ),
                                  ),
                                ]))
                          ]),
                    ),
                  ),

                  Align(
                      alignment: Alignment.center,
                      child: Wrap(children: <Widget>[
                        Container(
                          //  width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _compute();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              // fixedSize: Size(250, 50),
                            ),
                            child: Text(
                              "Start",
                            ),
                          ),
                        ),
                        Container(
                          // width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey,
                              // fixedSize: Size(250, 50),
                            ),
                            child: Text(
                              "Close",
                            ),
                          ),
                        ),
                      ]))
                ],
              ),
            ),
          );

          //),
          //);
        });
  }

  showTuningDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 10.0,
            ),
            title: Text(
              "Message Passing",
              style: TextStyle(fontSize: 24.0),
            ),
            content: Container(
              height: 400,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Test Config Number:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tConfigNum,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Test Iteration:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tIter,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Random Seed:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tRandomSeed,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Testing Workgroups:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tWorkgroup,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Max Workgroups:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tMaxworkgroup,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 160,
                            child: Text(
                              'Work Group Size:',
                            ),
                          ),
                          // SizedBox(width: 30),
                          SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _tSize,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Wrap(children: <Widget>[
                          Container(
                            //  width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _tuningClick();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                // fixedSize: Size(250, 50),
                              ),
                              child: Text(
                                "Start",
                              ),
                            ),
                          ),
                          Container(
                            // width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                // fixedSize: Size(250, 50),
                              ),
                              child: Text(
                                "Close",
                              ),
                            ),
                          ),
                        ]))
                  ],
                ),
              ),
            ),
          );
        });
  }

  // print("controller is active");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        child: Container(
          //  height: 800,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.all(24),
          child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  page,
                  // textAlign: TextAlign.center,
                  //overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Test List',
                  // style: TextStyle(fontSize: 18.0),
                  //  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Conformance Test',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                //  Row(mainAxisSize: MainAxisSize.min,
                Wrap(children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgPassingCoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          mssgPassingCoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Passing Coherency',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgpassingbarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          mssgpassingbarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Barrier',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rr,
                      onChanged: (bool? value) {
                        setState(() {
                          rr = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: Text(
                        'RR',
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                  //    ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storecoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          storecoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Coherency',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          storebarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Barrier',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rrrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          rrrmw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'RR RMW',
                      ),
                    ),
                  ]),

                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readcoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          readcoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read Coherency',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readrmwbarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          readrmwbarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read RMW Barrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rw,
                      onChanged: (bool? value) {
                        setState(() {
                          rw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'RW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbuffercoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbuffercoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer Coherency',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbufferbarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbufferbarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer Barrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rwrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          rwrmw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'RW RMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebuffer,
                      onChanged: (bool? value) {
                        setState(() {
                          storebuffer = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Buffer',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebufferrmwbarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          storebufferrmwbarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Buffer RMW Barrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wr,
                      onChanged: (bool? value) {
                        setState(() {
                          wr = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'WR',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writecoherency,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writecoherency = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        '2+2 Write Coherency',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writermwbarrier,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writermwbarrier = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        '2+2 Write RMW Barrier',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wwrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          wwrmw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'WW RMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: ww,
                      onChanged: (bool? value) {
                        setState(() {
                          ww = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WW',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wwrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          wwrmw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WW RMW',
                      ),
                    ),
                  ]),
                ]),

                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Tuning Tests',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                Wrap(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgPassing,
                      onChanged: (bool? value) {
                        setState(() {
                          mssgPassing = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Passing',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readrmwbarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          readrmwbarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read RMW Barrier 1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writermw,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writermw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        '2+2 Write RMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgPassingCoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          mssgPassingCoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Passing Coherency (mutant)',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readrmwbarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          readrmwbarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read RMW Barrier 2',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writecoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writecoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        '2+2 Write Coherency (Mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgPassingbarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          mssgPassingbarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Passing Barrier 1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: store,
                      onChanged: (bool? value) {
                        setState(() {
                          store = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storecoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          storecoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'Store Coherency (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writermwbarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writermwbarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        '2+2 Write RMW Barrier 1',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: mssgPassingbarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbuffer = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Message Passing Barrier 2',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          storebarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'Store Barrier 1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: twoplus2writermwbarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          twoplus2writermwbarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        '2 + 2 Write RMW Barrier 2',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbuffer,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbuffer = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          storebarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'Store Barrier 2',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rr_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rr_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'RR (mutant)',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbuffercoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbuffercoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer Coherency (mutant)',
                      ),
                    ),
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebufferrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          storebufferrmw = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,

                      child: const Text(
                        'Store Buffer RMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing')R,
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rrrmw_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rrrmw_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'RR RMW (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbufferbarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbufferbarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer Barrier 1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebuffercoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          storebuffercoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Buffer Coherency (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: rw_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          rw_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'RW (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: loadbufferbarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbufferbarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Load Buffer Barrier 2',
                      ),
                    ),
                  ]),

                  //more8
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebufferrmwbarrier1,
                      onChanged: (bool? value) {
                        setState(() {
                          storebufferrmwbarrier1 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Buffer RMW Barrier 1',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wr_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          wr_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WR (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readrmw,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbufferbarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read RMW',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: storebufferrmwbarrier2,
                      onChanged: (bool? value) {
                        setState(() {
                          loadbufferbarrier2 = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Store Buffer RMW Barrier 2',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wrrmw_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          wrrmw_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WR RMW (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: readcoherency_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          readcoherency_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'Read Coherency (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: ww_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          ww_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WW (mutant)',
                      ),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Checkbox(
                      // title: Text('Message Passing'),
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: wwrmw_mutant,
                      onChanged: (bool? value) {
                        setState(() {
                          wwrmw_mutant = value!;
                        });
                      },
                    ),
                    Container(
                      // width: double.infinity,
                      width: 75,
                      child: const Text(
                        'WW RMW (mutant)',
                      ),
                    ),
                  ]),
                ]),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Presets',
                    style: TextStyle(
                      color: Colors.grey,

                      //   overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 180, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseConformanceTests,
                          child: const Text('Conformance Tests'),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),

                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseTuning,
                          child: const Text('Tuning Tests'),
                        ),
                      ),
                    ),
                    //  const SizedBox(height: 30),

                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseAllTests,
                          child: Text('All Tests'),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 160, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.cyan),
                          ),
                          onPressed: _chooseClearSelection,
                          child: const Text('Clear Selection'),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Test Type',
                    style: TextStyle(fontSize: 18.0),
                    //   overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressExplorer
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressExplorer = true;
                              pressTuning = false;
                              pressConformance = false;
                              _visibleExplorer = true;
                              _visibleTuning = false;
                            });
                          },
                          child: const Text('Explorer'),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),

                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressTuning
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressTuning = true;
                              pressExplorer = false;
                              pressConformance = false;
                              _visibleExplorer = false;
                              _visibleTuning = true;
                            });
                          },
                          child: const Text('Tuning'),
                        ),
                      ),
                    ),
                    //  const SizedBox(height: 30),

                    SizedBox(
                      width: 140, // <-- Your width
                      height: 50, // <-- Your height
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: pressConformance
                                ? MaterialStatePropertyAll<Color>(Colors.green)
                                : MaterialStatePropertyAll<Color>(Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              pressTuning = false;
                              pressExplorer = false;
                              pressConformance = true;
                              _visibleExplorer = false;
                              _visibleTuning = true;
                            });
                          },
                          child: Text('Tune/Conform'),
                        ),
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: _visibleExplorer,
                  child: Container(
                    height: 400,
                    //width: 400, //or whatever you want

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // child:
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Test Iteration:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _iter,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Testing Workgroups',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _workgroup,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Max Workgroup:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _maxworkgroup,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Workgroup Size:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _size,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Shuffle Percentage:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _shufflepct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Barrier Perecentage:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _barrierpct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Scratch Memory Size:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _scratchMemSize,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Memory Stride:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _memStride,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Memory Stress Percentage:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _memStressPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Memory Stress Iterations',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _memStressIter,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Memory Stress Store First Pct:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller:
                                                  _memStressStoreFirstPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Memory Stress Store Second Pct:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller:
                                                  _memStressStoreSecondPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Pre Stress Percentage:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _preStressPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Pre Stress Iterations:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _preStressIter,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Pre Stress Store First Pct:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller:
                                                  _preStressStoreFirstPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Pre Stress Store Second Pct:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller:
                                                  _preStressStoreSecondPct,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Stress Line Size:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _stressLineSize,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Stress Target Lines:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: _stressTargetLines,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 160,
                                          child: Text(
                                            'Stress Assignment Strategy:',
                                          ),
                                        ),
                                        // SizedBox(width: 30),
                                        SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller:
                                                  _stressAssignmentStrategy,
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Test Parameters Presets",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Wrap(children: <Widget>[
                                        Container(
                                          //  width: double.infinity,
                                          height: 60,
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _changeStress();
                                              // Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.cyan,
                                              // fixedSize: Size(250, 50),
                                            ),
                                            child: const Text(
                                              "Default",
                                            ),
                                          ),
                                        ),
                                        Container(
                                          // width: double.infinity,
                                          height: 60,
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _changeDefault();
                                              //Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.grey,
                                              // fixedSize: Size(250, 50),
                                            ),
                                            child: const Text(
                                              "Stress",
                                            ),
                                          ),
                                        ),
                                      ]))
                                ]),
                          ),
                        ),

                        Align(
                            alignment: Alignment.center,
                            child: Wrap(children: <Widget>[
                              Container(
                                //  width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _compute();
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    // fixedSize: Size(250, 50),
                                  ),
                                  child: Text(
                                    "Start",
                                  ),
                                ),
                              ),
                              Container(
                                // width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blueGrey,
                                    // fixedSize: Size(250, 50),
                                  ),
                                  child: Text(
                                    "Close",
                                  ),
                                ),
                              ),
                            ]))
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: _visibleTuning,
                  child: Container(
                    height: 400,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Test Config Number:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tConfigNum,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Test Iteration:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tIter,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Random Seed:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tRandomSeed,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Testing Workgroups:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tWorkgroup,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Max Workgroups:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tMaxworkgroup,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 160,
                                  child: Text(
                                    'Work Group Size:',
                                  ),
                                ),
                                // SizedBox(width: 30),
                                SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _tSize,
                                      textAlign: TextAlign.center,
                                    )),
                              ],
                            ),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Wrap(children: <Widget>[
                                Container(
                                  //  width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _tuningClick();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      // fixedSize: Size(250, 50),
                                    ),
                                    child: Text(
                                      "Start",
                                    ),
                                  ),
                                ),
                                Container(
                                  // width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      // fixedSize: Size(250, 50),
                                    ),
                                    child: Text(
                                      "Close",
                                    ),
                                  ),
                                ),
                              ]))
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  child: Text(_iterationMssg),
                  visible: _visible,
                ),
              ]),
        ),
      ),
    );
  }
}
