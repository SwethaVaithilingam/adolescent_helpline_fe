import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/api_config.dart';

class Phq9Page extends StatefulWidget {
  const Phq9Page({super.key});

  @override
  State<Phq9Page> createState() => _Phq9PageState();
}

class _Phq9PageState extends State<Phq9Page> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  final Map<int, int?> answers = {};
  final storage = const FlutterSecureStorage();

  bool isSubmitting = false;
  bool _submitted = false; // controls validation UI

  final List<Map<String, String>> questions = [
  {
    'en': 'Little interest or pleasure in doing things',
    'ta': 'விஷயங்களைச் செய்வதில் குறைந்த ஆர்வம் அல்லது மகிழ்ச்சி'
  },
  {
    'en': 'Feeling down, depressed, or hopeless',
    'ta': 'மனச்சோர்வு அல்லது நம்பிக்கையற்ற உணர்வு'
  },
  {
    'en': 'Trouble falling or staying asleep, or sleeping too much',
    'ta': 'தூங்குவதில் சிக்கல் அல்லது அதிகமாக தூங்குதல்'
  },
  {
    'en': 'Feeling tired or having little energy',
    'ta': 'சோர்வாக உணருதல் அல்லது சக்தி குறைவாக இருத்தல்'
  },
  {
    'en': 'Poor appetite or overeating',
    'ta': 'பசியின்மை அல்லது அதிகமாக சாப்பிடுதல்'
  },
  {
    'en': 'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
    'ta': 'உங்களைப் பற்றி மோசமாக உணருதல் அல்லது நீங்கள் ஒரு தோல்வி என்று நினைத்தல்'
  },
  {
    'en': 'Trouble concentrating on things, such as reading or watching television',
    'ta': 'கவனம் செலுத்துவதில் சிக்கல் (படித்தல் அல்லது தொலைக்காட்சி பார்ப்பது போன்றவை)'
  },
  {
    'en': 'Moving or speaking slowly that other people could notice, or being very restless',
    'ta': 'மெதுவாக நகர்வது அல்லது பேசுவது, அல்லது மிகவும் அமைதியற்றதாக இருப்பது'
  },
  {
    'en': 'Thoughts that you would be better off dead or of hurting yourself in some way',
    'ta': 'நீங்கள் இறந்துவிட்டால் நல்லது அல்லது உங்களை காயப்படுத்திக் கொள்ள வேண்டும் என்ற எண்ணங்கள்'
  },
];


  @override
  void initState() {
    super.initState();
    for (int i = 0; i < questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PHQ-9 Questionnaire')),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            ...List.generate(
              questions.length,
              (index) => _buildQuestion(index),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitForm,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int index) {
    bool hasError = _submitted && answers[index] == null;

    return Container(
      key: _questionKeys[index],
      child: Card(
        color: hasError ? Colors.red.shade50 : null,
        shape: RoundedRectangleBorder(
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${questions[index]['en']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(questions[index]['ta']!),
              const SizedBox(height: 8),

              ...List.generate(4, (score) {
                return RadioListTile<int>(
                  value: score,
                  groupValue: answers[index],
                  title: Text(_scaleText(score)),
                  onChanged: (value) {
                    setState(() {
                      answers[index] = value;
                    });
                  },
                );
              }),

              if (hasError)
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'Please select an option',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

String _scaleText(int score) {
  switch (score) {
    case 0:
      return '0 – Not at all / இல்லை';
    case 1:
      return '1 – Several days / சில நாட்கள்';
    case 2:
      return '2 – More than half the days / பாதிக்கு மேற்பட்ட நாட்கள்';
    case 3:
      return '3 – Nearly every day / கிட்டத்தட்ட தினமும்';
    default:
      return '';
  }
}

 

// Future<void> _submitForm() async {
//   setState(() {
//     _submitted = true;
//   });

//   int? firstMissingIndex;

//   // Find first unanswered question
//   for (int i = 0; i < questions.length; i++) {
//     if (answers[i] == null) {
//       firstMissingIndex = i;
//       break;
//     }
//   }

//   // Scroll to first unanswered
//   if (firstMissingIndex != null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(content: Text("Please answer all questions")),
//     );


//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final keyContext =
//           _questionKeys[firstMissingIndex!]!.currentContext;

//       if (keyContext != null) {
//         final box = keyContext.findRenderObject() as RenderBox;
//         final position = box.localToGlobal(Offset.zero);

//         // current scroll + position of widget
//         final offset = _scrollController.offset + position.dy - 120;

//         _scrollController.animateTo(
//           offset,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });

//     return;
//   }

//   // Submit API if all answered
//   setState(() => isSubmitting = true);

// try {
//   String? token = await storage.read(key: "access_token");
//   String? phone = await storage.read(key: "phone");

// if (phone == null || phone.isEmpty) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Phone not found. Please login again.")),
//   );
//   setState(() => isSubmitting = false);
//   return;
// }

//   List<int> answersList =
//       List.generate(questions.length, (i) => answers[i]!);

//   final response = await http.post(
//     Uri.parse("${ApiConfig.baseUrl}/phq9/submit"),
//     headers: {
//       "Authorization": "Bearer $token",
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode({
//       "phone": phone,       
//       "answers": answersList
//     }),
//   );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("phq9 submitted successfully")),
//       );

//       await Future.delayed(const Duration(seconds: 1));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Submission failed: ${response.body}")),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   }

//   setState(() => isSubmitting = false);
// }


Future<void> _submitForm() async {
  setState(() {
    _submitted = true;
  });

  for (int i = 0; i < questions.length; i++) {
    if (answers[i] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }
  }

  setState(() => isSubmitting = true);

  try {
    String? token = await storage.read(key: "access_token");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    List<int> answersList =
        List.generate(questions.length, (i) => answers[i]!);

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/phq9/submit"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "answers": answersList
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PHQ-9 submitted successfully")),
      );

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

  setState(() => isSubmitting = false);
}

}
