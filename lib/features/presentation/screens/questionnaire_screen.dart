import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/api_config.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  List sections = [];
  int currentSectionIndex = 0;
  Map<int, dynamic> answers = {};
  bool isLoading = true;
  String errorMessage = "";
  Set<int> unansweredQuestions = {};
  final storage = const FlutterSecureStorage();

  final String baseUrl = ApiConfig.baseUrl; // Android emulator backend

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/questionnaire.json');

      final data = json.decode(response);

      setState(() {
        sections = data["sections"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Questionnaire")),
        body: Center(
          child: Text(
            errorMessage.isEmpty
                ? "No questions found."
                : "Error loading questionnaire:\n$errorMessage",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentSection = sections[currentSectionIndex];
    final questions = currentSection["questions"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Questionnaire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            LinearProgressIndicator(
              value: (currentSectionIndex + 1) / sections.length,
            ),

            const SizedBox(height: 12),

            Text(
              currentSection["title_en"],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(currentSection["title_ta"]),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return buildQuestion(questions[index]);
                },
              ),
            ),

            buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildQuestion(dynamic question) {
    int id = question["id"];
    String type = question["type"];
    bool isUnanswered = unansweredQuestions.contains(id);

    return Card(
      color: isUnanswered ? Colors.red.shade50 : null,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isUnanswered ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "$id. ${question["question_en"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(question["question_ta"]),

            const SizedBox(height: 8),

            if (type == "mcq")
              ...question["options"].map<Widget>((option) {
                return RadioListTile(
                  value: option["en"],
                  groupValue: answers[id],
                  title: Text("${option["en"]} — ${option["ta"]}"),
                  onChanged: (value) {
                    setState(() {
                      answers[id] = value;
                      unansweredQuestions.remove(id);
                    });
                  },
                );
              }).toList(),

            if (type == "text")
              TextField(
                onChanged: (value) {
                  answers[id] = value;
                  unansweredQuestions.remove(id);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

            if (isUnanswered)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "This question is required",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        if (currentSectionIndex > 0)
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentSectionIndex--;
              });
            },
            child: const Text("Previous"),
          ),

        ElevatedButton(
          onPressed: validateAndProceed,
          child: Text(
              currentSectionIndex < sections.length - 1 ? "Next" : "Submit"),
        )
      ],
    );
  }

  void validateAndProceed() {
    final currentSection = sections[currentSectionIndex];
    final questions = currentSection["questions"];

    unansweredQuestions.clear();

    for (var q in questions) {
      int id = q["id"];
      if (!answers.containsKey(id) ||
          answers[id] == null ||
          answers[id].toString().trim().isEmpty) {
        unansweredQuestions.add(id);
      }
    }

    setState(() {});

    if (unansweredQuestions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all the questions"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentSectionIndex < sections.length - 1) {
      setState(() {
        currentSectionIndex++;
      });
    } else {
      submitQuestionnaire();
    }
  }

Future<void> submitQuestionnaire() async {
  try {
    final token = await storage.read(key: "access_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    List<String> answersList = List.generate(
      38,
      (index) => answers[index + 1].toString(),
    );

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/questionnaire/submit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "answers": answersList,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questionnaire submitted successfully")),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}


}
