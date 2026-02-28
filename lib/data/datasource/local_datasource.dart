import 'package:hive_flutter/hive_flutter.dart';
import '../../models/contact_model.dart';

class LocalDataSource {
  static const String boxName = "contacts";

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Future<void> saveContact(ContactModel contact) async {
    final box = Hive.box(boxName);
    await box.add(contact.toJson());
  }

  Future<void> deleteContact(int index) async {
    final box = Hive.box(boxName);
    await box.deleteAt(index);
  }

  List<ContactModel> getContacts() {
    final box = Hive.box(boxName);

    return box.values.map((e) {
      return ContactModel.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }
}
