import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/api_config.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final storage = const FlutterSecureStorage();

  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController classController;
  late TextEditingController schoolController;
  late TextEditingController districtController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.profile["name"] ?? "");

    dobController =
        TextEditingController(text: widget.profile["dob"] ?? "");

    // IMPORTANT: backend uses student_class
    classController =
        TextEditingController(text: widget.profile["student_class"] ?? "");

    schoolController = TextEditingController(text:widget.profile["school_name"]??"");

    districtController =
        TextEditingController(text: widget.profile["district"] ?? "");
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    try {
      String? token = await storage.read(key: "access_token");

      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/user/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text,
          "dob":dobController.text,
          "student_class": classController.text,
          "school_name":schoolController.text,
          "district": districtController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // refresh profile page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update failed")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
             const SizedBox(height: 20),
            // DOB (read only)
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Date of Birth"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2005),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    dobController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),

             const SizedBox(height: 20),
            TextField(
              controller: classController,
              decoration: const InputDecoration(labelText: "Class"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: schoolController,
              decoration: const InputDecoration(labelText: "School"),
            ),
               const SizedBox(height: 20),
            TextField(
              controller: districtController,
              decoration: const InputDecoration(labelText: "District"),
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
