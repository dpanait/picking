class InternalNotes {
  late String date;
  late String adminName;
  late String note;

  InternalNotes({required this.date, required this.adminName, required this.note});

  InternalNotes.fromJson(Map<String, dynamic> json) {
    date = json['date'].toString();
    adminName = json['admin_name'].toString();
    note = json['note'].toString();
  }
}
