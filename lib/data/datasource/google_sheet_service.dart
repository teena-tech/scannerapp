import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact_model.dart';

class GoogleSheetService {
  final String _url =
      "https://script.google.com/macros/s/AKfycbzdqtUbut0Y1ND3KIEQQmWR9an0PMDPGn4vNOdz-Y6E2Cg7H1LyZaOD47fRdopWKEUpNw/exec";

  Future<void> save(ContactModel contact) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": contact.name ?? "",
        "company": contact.company ?? "",
        "phone": contact.phone ?? "",
        "email": contact.email ?? "",
        "website": contact.website ?? "",
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (!response.body.contains("Success")) {
      throw Exception("Failed to save data");
    }
  }
}
