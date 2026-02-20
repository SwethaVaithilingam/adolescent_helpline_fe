import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../widgets/form_field_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final classController = TextEditingController();
  final districtController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    classController.dispose();
    districtController.dispose();
    super.dispose();
  }

  /// ---------------- DATE PICKER ----------------
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

  /// ---------------- SIGNUP ----------------
  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final parts = dobController.text.split('/');
      final formattedDob = "${parts[2]}-${parts[1]}-${parts[0]}";

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/signup"), 
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "full_name": nameController.text.trim(),
          "dob": formattedDob,
          "phone": phoneController.text.trim(),
          "password": passwordController.text.trim(),
          "student_class": classController.text,
          "district": districtController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // final error = jsonDecode(response.body);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(error["detail"] ?? "Signup failed")),
        // );

        final error = jsonDecode(response.body);

String message = "Signup failed";

if (error["detail"] is List && error["detail"].isNotEmpty) {
  message = error["detail"][0]["msg"];
} else if (error["detail"] != null) {
  message = error["detail"].toString();
}

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)),
);

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// ---------------- VALIDATORS ----------------

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    final nameRegex = RegExp(r'^[A-Za-z ]+$');

    if (!nameRegex.hasMatch(value.trim())) {
      return "Name should contain only alphabets and spaces";
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter a valid Indian phone number";
    }

    return null;
  }

  String? validateDistrict(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "District is required";
    }

    final districtRegex = RegExp(r'^[A-Za-z ]+$');

    if (!districtRegex.hasMatch(value.trim())) {
      return "District should contain only alphabets and spaces";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormFieldWidget(
                  label: 'Full Name',
                  controller: nameController,
                  validator: validateName,
                ),

                /// DOB
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: FormFieldWidget(
                      label: 'Date of Birth',
                      controller: dobController,
                      validator: Validators.required,
                    ),
                  ),
                ),

                FormFieldWidget(
                  label: 'Phone Number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),

                FormFieldWidget(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: true,
                  validator: validatePassword,
                ),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                  ),
                  initialValue: classController.text.isEmpty
                      ? null
                      : classController.text,
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
                      return 'Please select your class';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      classController.text = value!;
                    });
                  },
                ),

                const SizedBox(height: 12),

                FormFieldWidget(
                  label: 'District',
                  controller: districtController,
                  validator: validateDistrict,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSignup,
                    child: const Text('Create Account'),
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
