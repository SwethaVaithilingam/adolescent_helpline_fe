import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class SignupScreen2 extends StatefulWidget {
  final String phoneNumber;

  const SignupScreen2({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SignupScreen2> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final classController = TextEditingController();
  final districtController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    passwordController.dispose();
    classController.dispose();
    districtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(2004),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final parts = dobController.text.split('/');

      final formattedDob =
          "${parts[2]}-${parts[1]}-${parts[0]}";

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/signup"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "full_name": nameController.text.trim(),
          "dob": formattedDob,
          "phone": widget.phoneNumber,
          "password": passwordController.text.trim(),
          "student_class": classController.text,
          "district": districtController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful")),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.phoneNumber,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: nameController,
                  validator: requiredField,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                  ),
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dobController,
                      validator: requiredField,
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: requiredField,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Class",
                  ),
                  items: const [
                    DropdownMenuItem(value: 'V', child: Text('V')),
                    DropdownMenuItem(value: 'VI', child: Text('VI')),
                    DropdownMenuItem(value: 'VII', child: Text('VII')),
                    DropdownMenuItem(value: 'VIII', child: Text('VIII')),
                    DropdownMenuItem(value: 'IX', child: Text('IX')),
                    DropdownMenuItem(value: 'X', child: Text('X')),
                    DropdownMenuItem(value: 'XI', child: Text('XI')),
                    DropdownMenuItem(value: 'XII', child: Text('XII')),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return "Select class";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    classController.text = value!;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: districtController,
                  validator: requiredField,
                  decoration: const InputDecoration(
                    labelText: "District",
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signup,
                    child: const Text("Create Account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}