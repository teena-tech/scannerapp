import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact_model.dart';

class GoogleSheetService {
  final String _url =
      "https://script.google.com/macros/s/AKfycbz0092iVcd39VvQ9ddkLluiff_d653EREzw3RavZG9-Kk_mqw8iFGWtt60VFMs27TR-/exec";

  Future<void> save(ContactModel contact) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": contact.name ?? "",
          "company": contact.company ?? "",
          "phone": contact.phone ?? "",
          "email": contact.email ?? "",
          "website": contact.website ?? "",
          "date": contact.date ?? "",
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (!response.body.contains("Success")) {
        throw Exception("Failed to save data to Google Sheet");
      }
    } catch (e) {
      print("Error saving to Google Sheet: $e");
      rethrow; // Keep the exception so the caller knows
    }
  }
}
