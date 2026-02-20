import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/api_config.dart';

class Dass21Page extends StatefulWidget {
  const Dass21Page({super.key});

  @override
  State<Dass21Page> createState() => _Dass21PageState();
}

class _Dass21PageState extends State<Dass21Page> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  final Map<int, int?> answers = {};
  final storage = const FlutterSecureStorage();

  bool isSubmitting = false;
  bool _submitted = false; // controls validation UI

  final List<Map<String, String>> questions = [
    {'en': 'I found it hard to wind down', 'ta': 'எனக்கு அமைதியாக இருப்பது கடினமாக இருந்தது'},
    {'en': 'I was aware of dryness of my mouth', 'ta': 'என் வாயில் உலர்ச்சி இருப்பதை உணர்ந்தேன்'},
    {'en': 'I couldn’t seem to experience any positive feeling at all', 'ta': 'எந்த நல்ல உணர்ச்சியையும் அனுபவிக்க முடியாதபடி இருந்தது'},
    {'en': 'I experienced breathing difficulty', 'ta': 'மூச்சு விடுவதில் சிரமம் ஏற்பட்டது'},
    {'en': 'I found it difficult to work up the initiative to do things', 'ta': 'எதையும் தொடங்குவதற்கு உற்சாகம் இல்லாமல் இருந்தது'},
    {'en': 'I tended to over-react to situations', 'ta': 'சூழ்நிலைகளுக்கு மிகையாக எதிர்வினை செய்தேன்'},
    {'en': 'I experienced trembling (e.g., in the hands)', 'ta': 'கைகளில் நடுக்கம் போன்றவை ஏற்பட்டன'},
    {'en': 'I felt that I was using a lot of nervous energy', 'ta': 'நான் அதிகமான நரம்பு சக்தியை பயன்படுத்துகிறேன் என்று உணர்ந்தேன்'},
    {'en': 'I was worried about situations in which I might panic', 'ta': 'பதட்டம் ஏற்படும் சூழ்நிலைகளைப் பற்றி கவலைப்பட்டேன்'},
    {'en': 'I felt that I had nothing to look forward to', 'ta': 'எதிர்பார்க்க எதுவும் இல்லை என்று உணர்ந்தேன்'},
    {'en': 'I found myself getting agitated', 'ta': 'நான் எளிதில் கலங்கிவிட்டேன்'},
    {'en': 'I found it difficult to relax', 'ta': 'தளர்வடைவது கடினமாக இருந்தது'},
    {'en': 'I felt down-hearted and blue', 'ta': 'மனம் தளர்ந்து சோகமாக இருந்தது'},
    {'en': 'I was intolerant of anything that kept me from getting on with what I was doing', 'ta': 'என் வேலைக்கு இடையூறாக இருந்த எதையும் சகிக்க முடியவில்லை'},
    {'en': 'I felt I was close to panic', 'ta': 'பதட்டத்திற்கு அருகில் இருப்பதாக உணர்ந்தேன்'},
    {'en': 'I was unable to become enthusiastic about anything', 'ta': 'எதிலும் ஆர்வம் ஏற்படவில்லை'},
    {'en': 'I felt I wasn’t worth much as a person', 'ta': 'நான் மதிப்பில்லாத மனிதன் போல உணர்ந்தேன்'},
    {'en': 'I felt that I was rather touchy', 'ta': 'நான் எளிதில் எரிச்சலடையும் நிலையில் இருந்தேன்'},
    {'en': 'I was aware of the action of my heart in the absence of physical exertion', 'ta': 'உடல் உழைப்பு இல்லாமலே இதயத் துடிப்பை உணர்ந்தேன்'},
    {'en': 'I felt scared without any good reason', 'ta': 'எந்த நல்ல காரணமும் இல்லாமல் பயமாக இருந்தது'},
    {'en': 'I felt that life was meaningless', 'ta': 'வாழ்க்கை அர்த்தமற்றதாக இருந்தது'},
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
      appBar: AppBar(title: const Text('DASS-21 Questionnaire')),
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
        return '0 – Did not apply to me / பொருந்தவில்லை';
      case 1:
        return '1 – Applied sometimes / சில நேரங்களில்';
      case 2:
        return '2 – Applied often / அடிக்கடி';
      case 3:
        return '3 – Applied very much / மிகவும்';
      default:
        return '';
    }
  }

 

Future<void> _submitForm() async {
  setState(() {
    _submitted = true;
  });

  int? firstMissingIndex;

  // Find first unanswered question
  for (int i = 0; i < questions.length; i++) {
    if (answers[i] == null) {
      firstMissingIndex = i;
      break;
    }
  }

  // Scroll to first unanswered
  if (firstMissingIndex != null) {
    ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Please answer all questions")),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext =
          _questionKeys[firstMissingIndex!]!.currentContext;

      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);

        // current scroll + position of widget
        final offset = _scrollController.offset + position.dy - 120;

        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return;
  }

  // Submit API if all answered
  setState(() => isSubmitting = true);

  try {
    String? token = await storage.read(key: "access_token");

    List<int> answersList =
        List.generate(questions.length, (i) => answers[i]!);

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/dass/submit"),
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
        const SnackBar(content: Text("DASS-21 submitted successfully")),
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

  setState(() => isSubmitting = false);
}

}
