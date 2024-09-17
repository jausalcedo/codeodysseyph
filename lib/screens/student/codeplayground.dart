import 'dart:async';
import 'dart:convert';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:gap/gap.dart';
import 'package:highlight/languages/java.dart';
import 'package:http/http.dart' as http;
import 'package:xterm/core.dart';

import 'package:xterm/ui.dart';

// ignore: must_be_immutable
class CodePlayground extends StatefulWidget {
  const CodePlayground({super.key});

  @override
  State<CodePlayground> createState() => _CodePlaygroundState();
}

class _CodePlaygroundState extends State<CodePlayground> {
  String script = """
    public class Main {
      public static void main(String[] args) {
        System.out.println("Hello World");
      }
    }
    """;

  final _codeEditorController = CodeController(
    language: java,
  );

  final _terminal = Terminal();

  final _proxyUrl = 'http://localhost:3000';

  Timer? _pollingTimer;

  String? _authToken;

  final _consoleInput = TextEditingController();

  Future<void> _executeCode() async {
    final response = await http.post(Uri.parse("$_proxyUrl/api/get-token"));

    if (response.statusCode == 200) {
      _authToken = json.decode(response.body)['token'];
      print(_authToken);
      _establishWebSocketConnection(_authToken!);

      final executionResponse = await http.post(
        Uri.parse('$_proxyUrl/api/execute-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'script': _codeEditorController.fullText,
          'language': 'java',
          'versionIndex': 5,
        }),
      );

      if (executionResponse.statusCode == 200) {
        _startPollingForOutput();
      } else {
        _terminal.write('Error executing code: ${executionResponse.body}\r\n');
      }
    } else {
      _terminal.write('Error fetching token: ${response.body}\r\n');
    }
  }

  Future<void> _establishWebSocketConnection(String token) async {
    final websocketResponse = await http.post(
      Uri.parse('$_proxyUrl/api/establish-websocket'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    if (websocketResponse.statusCode == 200) {
      _terminal.write('WebSocket connection established\r\n');
    } else {
      _terminal.write('Error establishing WebSocket: ${websocketResponse.body}\r\n');
    }
  }

  Future<void> _sendInput() async {
    if (_consoleInput.text.isEmpty || _consoleInput.text == '') {
      return;
    }

    final response = await http.post(
      Uri.parse('$_proxyUrl/api/send-input'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'input': _consoleInput.text,
      }),
    );

    if (response.statusCode == 200) {
      _terminal.write('Input: ${_consoleInput.text}\r\n');
      _consoleInput.clear();
    } else {
      _terminal.write('Error sending input: ${response.body}\r\n');
    }
  }

  void _startPollingForOutput() {
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      final response = await http.post(Uri.parse('$_proxyUrl/api/get-output'));

      if (response.statusCode == 200) {
        final output = json.decode(response.body)['output'];
        _terminal.write(output + "\r\n");
      } else {
        _terminal.write('Error fetching output: ${response.body}\r\n');
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _terminal.eraseDisplay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _codeEditorController.text = script;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CodePlayground'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // TABS
              const TabBar(
                tabs: <Widget>[
                  Tab(
                    text: 'Main.java',
                  ),
                  Tab(
                    text: 'Console',
                  ),
                  Tab(
                    text: 'AI Assistant Response',
                  ),
                ],
              ),

              // TAB CONTENT
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    // MAIN.JAVA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // CODE EDITOR
                        Expanded(
                          child: CodeTheme(
                            data: CodeThemeData(styles: vsTheme),
                            child: SingleChildScrollView(
                              child: CodeField(
                                controller: _codeEditorController,
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),

                        // RUN BUTTON
                        TextButton.icon(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(primary),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                          ),
                          onPressed: _executeCode,
                          label: const Text('Execute Code'),
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                        const Gap(10),
                      ],
                    ),

                    // CONSOLE
                    Column(
                      children: [
                        Expanded(
                          child: TerminalView(
                            _terminal,
                            readOnly: true,
                            autofocus: true,
                          ),
                        ),
                        TextField(
                          controller: _consoleInput,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: _sendInput,
                                icon: const Icon(Icons.send_rounded),
                              )),
                        )
                      ],
                    ),

                    //
                    Text('AI Response'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
