import 'package:flutter/material.dart';
import '../../data/datasource/google_sheet_service.dart';

import '../../models/contact_model.dart';

class ContactProvider extends ChangeNotifier {
  final GoogleSheetService _sheetService = GoogleSheetService();

  bool isLoading = false;
  String? errorMessage;

  final hiveBox;

  ContactProvider(this.hiveBox);

  Future<void> saveContact(ContactModel contact) async {
    try {
      isLoading = true;
      notifyListeners();

      await hiveBox.add(contact);

      await _sheetService.save(contact);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
