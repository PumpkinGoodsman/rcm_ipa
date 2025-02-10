import 'package:xml/xml.dart';

class CompanyCodeModel {
  final String id;
  final String title;
  final List<SaleOfficeEntry> entries;

  CompanyCodeModel({
    required this.id,
    required this.title,
    required this.entries,
  });

  factory CompanyCodeModel.fromXml(XmlDocument xml) {
    final id = xml.findElements('id').isNotEmpty ? xml.findElements('id').first.text : '';
    final title = xml.findElements('title').isNotEmpty ? xml.findElements('title').first.text : '';

    final entriesXml = xml.findAllElements('entry');
    final entries = entriesXml.map((entryXml) => SaleOfficeEntry.fromXml(entryXml)).toList();

    return CompanyCodeModel(
      id: id,
      title: title,
      entries: entries,
    );
  }
}

class SaleOfficeEntry {
  final String id;
  final String title;
  final String userId;
  final String burks;

  SaleOfficeEntry({
    required this.id,
    required this.title,
    required this.userId,
    required this.burks,
  });

  factory SaleOfficeEntry.fromXml(XmlElement xml) {
    final id = xml.findElements('id').isNotEmpty ? xml.findElements('id').first.text : '';
    final title = xml.findElements('title').isNotEmpty ? xml.findElements('title').first.text : '';
    final userId = xml.findAllElements('d:USER_ID').isNotEmpty ? xml.findAllElements('d:USER_ID').first.text : '';
    final burks = xml.findAllElements('d:BUKRS').isNotEmpty ? xml.findAllElements('d:BUKRS').first.text : '';

    return SaleOfficeEntry(
      id: id,
      title: title,
      userId: userId,
      burks: burks,
    );
  }
}
