import 'package:flutter/material.dart';
//import 'package:gpuiosbundle/forms.dart';
import 'package:gpuiosbundle/utilities.dart';

String shader_spv = "assets/litmustest_message_passing_default.spv";
String result_spv = "assets/litmustest_message_passing_results.spv";
String param_basic = "assets/parameters_basic.txt";
String param_stress = "assets/parameters_stress.txt";

// create statefull widget class
class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

// extend the class
class _MessagePageState extends State<MessagePage> {
  final String _title = "GPU Message Passing Test";
  final _formKey = GlobalKey<FormState>();
  TextEditingController userInput = TextEditingController();

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
      body: Container(
        //child: Center(

        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(24),
        child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'The message passing litmus test checks to see if two stores in one thread can be re-ordered according to loads on a second thread',
                // textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Row(
                  mainAxisSize: MainAxisSize.min,
                  //  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Initial State:',
                      //  textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '*x = 0, *y = 0',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Color.fromARGB(255, 203, 198, 198)),
                      // textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
              const SizedBox(height: 10),
              const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text(
                  'Final State:',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'r0 == 1 && r1 == 0',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Color.fromARGB(255, 203, 198, 198)),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
              const SizedBox(height: 15),
              Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Workgroup 0 Thread 0:',
                      //  textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      color: Colors.grey,
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '0.1: atomic_store_explicit(x,1,memory_order_relaxed)',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '0.2: atomic_store_explicit(y,1,memory_order_relaxed)',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ]),
              const SizedBox(height: 15),
              Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Workgroup 1 Thread 0',
                      //  textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      color: Colors.grey,
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '1.1: r0 = atomic_load_explicit(y,memory_order_relaxed)',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '1.2: r1 = atomic_load_explicit(x,memory_order_relaxed)',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ]),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.green),
                    ),
                    onPressed: () {},
                    // _isExplorerButtonDisabled
                    //     ? () => _compute(param_basic, shader_spv, result_spv)
                    //     : null,
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
