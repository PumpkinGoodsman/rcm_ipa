import 'package:xml/xml.dart';

class SaleOfficeModel {
  final String id;
  final String title;
  final List<SaleOfficeEntry> entries;

  SaleOfficeModel({
    required this.id,
    required this.title,
    required this.entries,
  });

  factory SaleOfficeModel.fromXml(XmlDocument xml) {
    final id = xml.findElements('id').isNotEmpty ? xml.findElements('id').first.text : '';
    final title = xml.findElements('title').isNotEmpty ? xml.findElements('title').first.text : '';

    final entriesXml = xml.findAllElements('entry');
    final entries = entriesXml.map((entryXml) => SaleOfficeEntry.fromXml(entryXml)).toList();

    return SaleOfficeModel(
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
  final String vkbur;

  SaleOfficeEntry({
    required this.id,
    required this.title,
    required this.userId,
    required this.vkbur,
  });

  factory SaleOfficeEntry.fromXml(XmlElement xml) {
    final id = xml.findElements('id').isNotEmpty ? xml.findElements('id').first.text : '';
    final title = xml.findElements('title').isNotEmpty ? xml.findElements('title').first.text : '';
    final userId = xml.findAllElements('d:USER_ID').isNotEmpty ? xml.findAllElements('d:USER_ID').first.text : '';
    final vkbur = xml.findAllElements('d:VKBUR').isNotEmpty ? xml.findAllElements('d:VKBUR').first.text : '';

    return SaleOfficeEntry(
      id: id,
      title: title,
      userId: userId,
      vkbur: vkbur,
    );
  }
}
