import 'package:flutter/material.dart';

import '../../data/datasource/local_datasource.dart';
import '../../models/contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalDataSource localDataSource = LocalDataSource();
  List<ContactModel> contacts = [];
  List<ContactModel> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  void deleteContact(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Contact"),
            content: const Text(
              "Are you sure you want to delete this contact?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await localDataSource.deleteContact(index);
                  loadContacts();
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  void loadContacts() {
    final data = localDataSource.getContacts();
    setState(() {
      contacts = data;
      filteredContacts = data;
    });
  }

  void searchContacts(String query) {
    final results =
        contacts.where((contact) {
          final nameLower = contact.name.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower);
        }).toList();

    setState(() {
      filteredContacts = results;
    });
  }

  Future<void> makeCall(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    await launchUrl(uri);
  }

  Future<void> openWhatsApp(String phone) async {
    final Uri uri = Uri.parse("https://wa.me/$phone");
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Contacts"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: searchContacts,
              decoration: const InputDecoration(
                hintText: "Search by name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child:
                filteredContacts.isEmpty
                    ? const Center(child: Text("No Contacts Found"))
                    : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(contact.name),
                            subtitle: Text(contact.phone),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.call),
                                  onPressed: () => makeCall(contact.phone),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () => openWhatsApp(contact.phone),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteContact(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
