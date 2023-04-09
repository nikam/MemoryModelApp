import 'package:flutter/material.dart';
import 'package:gpuiosbundle/utilities.dart';

String shader_spv = "assets/store/litmustest_store_default.spv";
String result_spv = "assets/store/litmustest_store_results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";

// create statefull widget class
class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

// extend the class
class _StorePageState extends State<StorePage> {
  final String _title = "GPU Store Test";

  late String _iterationMssg;
  late bool _visible;
  late bool _isExplorerButtonDisabled;
  late bool _isStressButtonDisabled;
  late bool _isResultButtonDisabled;
  late bool _isEmailButtonDisabled;
  late int _counter;
  final subscription = controller.stream;

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

  void _compute(String param, String shader, String result) async {
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

    await call_bridge(param, shader, result);

    setState(() {
      _isExplorerButtonDisabled = true;
      _isStressButtonDisabled = true;
      _isResultButtonDisabled = true;
      _isEmailButtonDisabled = true;
    });

    // print("when done");
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
                title: const Text('Store Test Results'),
                content: SingleChildScrollView(
                  // won't be scrollable
                  child: Text(output),
                ),
              ));
    });
  }

  // print("controller is active");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Center(
        //child: Center(

        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.green),
                    ),
                    onPressed: _isExplorerButtonDisabled
                        ? () => _compute(param_basic, shader_spv, result_spv)
                        : null,
                    child: const Text('Default Explorer'),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.green),
                    ),
                    onPressed: _isStressButtonDisabled
                        ? () => _compute(param_stress, shader_spv, result_spv)
                        : null,
                    child: const Text('Default Stress'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.red),
                    ),
                    onPressed: _isResultButtonDisabled ? _results : null,
                    child: Text('Result'),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.blue),
                    ),
                    onPressed: _isEmailButtonDisabled ? email : null,
                    child: const Text('Send Email'),
                  ),
                ],
              ),
              Visibility(
                child: Text(_iterationMssg),
                visible: _visible,
              ),
            ]),
      ),
    );
  }
}
