import 'dart:async';
import 'dart:convert';
import 'package:codeodysseyph/components/student/student_appbar.dart';
import 'package:codeodysseyph/components/student/student_drawer.dart';
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

  String? _authToken;

  final _consoleInput = TextEditingController();

  Future<void> _executeCode() async {
    _tabController.animateTo(1);
  }

  Future<void> _sendInput() async {}

  final _assistantResponseController = CodeController(
    language: java,
  );

  final chatInputController = TextEditingController();

  void _sendChat() {
    print('chat sent');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _terminal.eraseDisplay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _codeEditorController.text = script;

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
                            'Main.java',
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
                            onPressed: _sendChat,
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
