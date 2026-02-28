class ContactModel {
  final String name;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String date;

  ContactModel({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.website,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "company": company,
      "phone": phone,
      "email": email,
      "website": website,
      "date": date,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json["name"] ?? "",
      company: json["company"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      website: json["website"] ?? "",
      date: json["date"] ?? "",
    );
  }
}