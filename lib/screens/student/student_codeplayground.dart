import 'dart:async';
import 'dart:convert';
import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
import 'package:codeodysseyph/constants/colors.dart';
import 'package:codeodysseyph/services/ai_chat_service.dart';
import 'package:codeodysseyph/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:gap/gap.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:highlight/languages/java.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:xterm/core.dart';

import 'package:xterm/ui.dart';

// ignore: must_be_immutable
class StudentCodePlayground extends StatefulWidget {
  const StudentCodePlayground({super.key, required this.userId});

  final String userId;

  @override
  State<StudentCodePlayground> createState() => _StudentCodePlaygroundState();
}

class _StudentCodePlaygroundState extends State<StudentCodePlayground>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  // String? _authToken;

  final _consoleInput = TextEditingController();

  Future<void> _executeCode() async {
    // CHECK IF SCRIPT IS EMPTY
    if (script == '' || script.isEmpty) {
      return;
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Compiling',
      text: 'Your code is being compiled...',
    );

    script = _codeEditorController.fullText;

    final url = Uri.parse('$_proxyUrl/execute');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'script': script,
      }),
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      final result = jsonDecode(response.body);
      String output = result['output'];
      final outputList = output.split('\n');
      for (var output in outputList) {
        _terminal.write('$output\r\n');
      }

      _terminal.write('Program Terminated.\r\n');
      _terminal.write('Executed in ${result['cpuTime']}s.\r\n\n');
    } else {
      _terminal.write("Error ${response.statusCode}\r\n");
    }

    // AUTO NAVIGATE TO CONSOLE
    _tabController.animateTo(1);
  }

  Future<void> _sendInput() async {
    _terminal.write('Hello\r\n');
  }

  final _assistantResponseController = CodeController(
    language: java,
  );

  // GENERATIVE AI THINGS

  // CHAT SERVICES
  final _authService = AuthService();
  final _aiChatService = AiChatService();

  final focusNode = FocusNode();
  final scrollController = ScrollController();

  final apiKey = () {
    const apiKey = String.fromEnvironment(
      'API_KEY',
      defaultValue: 'fallback_api_key',
    );

    return apiKey;
  }();

  Future<void> _sendPrompt() async {
    sendMessage(true);
    final schema = Schema.object(properties: {
      'success': Schema.boolean(
        description: 'Indicates whether the request was successful or not.',
      ),
      'explanation': Schema.string(
        description:
            'A simple explanation of the response, addressing the user\'s query in paragraph format.',
      ),
      'codeResponse': Schema.string(
        description:
            'The actual code generated in response to the user\'s request.',
      ),
      'error': Schema.string(
        description:
            'An error message if the request was unsuccessful; otherwise, this will be null.',
      ),
    }, requiredProperties: [
      'success',
      'explanation',
      'codeResponse'
    ]);

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final prompt =
        "${chatInputController.text} ${_codeEditorController.fullText}";

    try {
      // Send the request to the Gemini API
      await model.generateContent([Content.text(prompt)]).then((value) {
        final responseData = value.text;

        final parsedResponse = jsonDecode(responseData!);

        if (parsedResponse['success']) {
          // Handle successful response
          sendMessage(false, responseFromAIChat: parsedResponse['explanation']);
          setState(() {
            _assistantResponseController.fullText =
                parsedResponse['codeResponse'];
          });
          _tabController.animateTo(2);
        } else {
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.error,
            title: 'An Error Occured',
            text: parsedResponse['error'],
          );
        }
      });
    } catch (e) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'An Error Occured',
        text: '$e',
      );
    }
  }

  final chatInputController = TextEditingController();

  void sendMessage(bool fromUser, {String? responseFromAIChat}) async {
    if (!fromUser) {
      await _aiChatService.sendMessage(
        false,
        responseFromAIChat!,
      );
    } else {
      // VALIDATE IF THERE IS A MESSAGE TO SEND
      if (chatInputController.text == '' || chatInputController.text.isEmpty) {
        return;
      }

      await _aiChatService.sendMessage(
        true,
        chatInputController.text,
      );
    }

    chatInputController.clear();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _codeEditorController.text = script;

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          scrollDown,
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
      scrollDown,
    );
  }

  @override
  void dispose() {
    _terminal.eraseDisplay();
    chatInputController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: StudentDrawer(
        userId: widget.userId,
      ),
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 75),
        child: StudentAppbar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // TABS
                    TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 3,
                      tabs: const <Widget>[
                        Tab(
                          child: Text(
                            'Code Editor',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Console',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'AI Assistant Response',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    // TAB CONTENT
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          // MAIN.JAVA BODY
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 175,
                                  child: TextButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(primary),
                                      foregroundColor:
                                          WidgetStatePropertyAll(Colors.white),
                                    ),
                                    onPressed: _executeCode,
                                    label: const Text('Execute Code'),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                  ),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),

                          // CONSOLE BODY
                          Column(
                            children: [
                              Expanded(
                                child: TerminalView(
                                  _terminal,
                                  readOnly: true,
                                  autofocus: true,
                                  textStyle: const TerminalStyle(fontSize: 16),
                                ),
                              ),
                              TextField(
                                controller: _consoleInput,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _sendInput,
                                    icon: const Icon(Icons.send_rounded),
                                  ),
                                ),
                              )
                            ],
                          ),

                          // AI RESPONSE BODY
                          CodeTheme(
                            data: CodeThemeData(styles: vsTheme),
                            child: SingleChildScrollView(
                              child: CodeField(
                                controller: _assistantResponseController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Gap(15),
            Card(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AI ASSISTANT CHAT HEADER
                    Container(
                      color: secondary,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/Logo - Standalone.png',
                              height: 30,
                            ),
                          ),
                          const Gap(15),
                          const Text(
                            'AI Assistant Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // MESSAGES
                    Expanded(
                      child: StreamBuilder(
                        stream: _aiChatService
                            .getChat(_authService.getCurrentUser()!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error fetching messages'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListView(
                              controller: scrollController,
                              children: snapshot.data!.docs.map((doc) {
                                Map<String, dynamic> data =
                                    doc.data() as Map<String, dynamic>;

                                bool fromUser = data['fromUser'];

                                var alignment = fromUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft;

                                DateTime dateTime = data['timestamp'].toDate();

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  alignment: alignment,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      fromUser
                                          ? const SizedBox.shrink()
                                          : ClipRRect(
                                              clipBehavior: Clip.antiAlias,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                'assets/images/Logo - Standalone.png',
                                                height: 35,
                                              ),
                                            ),
                                      const Gap(5),
                                      Container(
                                        constraints: data['message'].length > 30
                                            ? const BoxConstraints.tightFor(
                                                width: 350 - 150,
                                              )
                                            : BoxConstraints.loose(
                                                const Size(
                                                  350,
                                                  double.infinity,
                                                ),
                                              ),
                                        decoration: BoxDecoration(
                                          color: fromUser
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: fromUser
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['message'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: fromUser
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                            Text(
                                              DateFormat.EEEE()
                                                  .add_jm()
                                                  .format(dateTime),
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: fromUser
                                                    ? Colors.grey[600]
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),

                    // USER INPUT
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: chatInputController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _sendPrompt,
                            icon: const Icon(
                              Icons.send_rounded,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
