import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/datasource/google_sheet_service.dart';
import '../../data/datasource/local_datasource.dart';
import '../../data/datasource/ocr_datasource.dart';
import '../../models/contact_model.dart';
import 'dashboard_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? frontImage;
  File? backImage;

  final ImagePicker picker = ImagePicker();
  final OCRDataSource ocr = OCRDataSource();
  final LocalDataSource localDataSource = LocalDataSource();
  final GoogleSheetService sheetService = GoogleSheetService();

  String extractedText = "";
  bool isLoading = false;

  // Pick images
  Future<void> pickFrontImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        frontImage = File(image.path);
      });
    }
  }

  Future<void> pickBackImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        backImage = File(image.path);
      });
    }
  }

  // Extract info functions
  String extractEmail(String text) {
    final reg = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    return reg.firstMatch(text)?.group(0) ?? "";
  }

  String extractPhone(String text) {
    final reg = RegExp(r'(\+?\d[\d\s-]{8,}\d)');
    return reg.firstMatch(text)?.group(0) ?? "";
  }

  String extractWebsite(String text) {
    final reg = RegExp(r'(www\.[^\s]+)');
    return reg.firstMatch(text)?.group(0) ?? "";
  }

  String extractName(String text) {
    final words = text.split(" ");
    for (int i = 0; i < words.length - 1; i++) {
      if (words[i].isNotEmpty &&
          words[i + 1].isNotEmpty &&
          words[i][0] == words[i][0].toUpperCase() &&
          words[i + 1][0] == words[i + 1][0].toUpperCase()) {
        return "${words[i]} ${words[i + 1]}";
      }
    }
    return "";
  }

  String extractCompany(String text) {
    final lines = text.split("\n");
    for (var line in lines) {
      if (line.toUpperCase() == line &&
          line.length > 4 &&
          !line.contains("@") &&
          !line.contains(RegExp(r'\d'))) {
        return line.trim();
      }
    }
    return "";
  }

  // Read OCR & Save
  Future<void> readText() async {
    if (frontImage == null && backImage == null) {
      setState(() {
        extractedText = "Please upload at least one image.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String fullText = "";

      if (frontImage != null) {
        fullText += await ocr.extractText(frontImage!.path);
      }

      if (backImage != null) {
        fullText += "\n${await ocr.extractText(backImage!.path)}";
      }

      // Extract info
      final name = extractName(fullText);
      final phone = extractPhone(fullText);
      final email = extractEmail(fullText);
      final website = extractWebsite(fullText);
      final company = extractCompany(fullText);

      final contact = ContactModel(
        name: name.isNotEmpty ? name : "",
        company: company.isNotEmpty ? company : "",
        phone: phone.isNotEmpty ? phone : "",
        email: email.isNotEmpty ? email : "",
        website: website.isNotEmpty ? website : "",
        date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
      );

      // Save locally
      try {
        await localDataSource.saveContact(contact);
        print("Saved locally ✅");
      } catch (e) {
        print("Local save failed ❌: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save locally")));
      }

      // Save to Google Sheet
      try {
        await sheetService.save(contact);
        print("Saved to Google Sheet ✅");
      } catch (e) {
        print("Google Sheet save failed ❌: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved locally but failed to save to Sheet"),
          ),
        );
      }

      // Show saved info
      setState(() {
        extractedText = """
Saved Successfully!

Name: ${contact.name}
Company: ${contact.company}
Phone: ${contact.phone}
Email: ${contact.email}
Website: ${contact.website}
""";

        // Optional: Clear images after save
        frontImage = null;
        backImage = null;
      });
    } catch (e) {
      setState(() {
        extractedText = "Unexpected Error: ${e.toString()}";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Business Card"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            Card(
              child: Column(
                children: [
                  frontImage != null
                      ? Image.file(frontImage!, height: 180)
                      : const SizedBox(
                        height: 180,
                        child: Center(child: Text("No Front Image")),
                      ),
                  ElevatedButton.icon(
                    onPressed: pickFrontImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Front"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Column(
                children: [
                  backImage != null
                      ? Image.file(backImage!, height: 180)
                      : const SizedBox(
                        height: 180,
                        child: Center(child: Text("No Back Image")),
                      ),
                  ElevatedButton.icon(
                    onPressed: pickBackImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Back"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  onPressed: readText,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text("Scan & Save"),
                ),

            const SizedBox(height: 20),

            Text(extractedText),
          ],
        ),
      ),
    );
  }
}
