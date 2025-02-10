import 'package:xml/xml.dart' as xml;

class AgingSummaryModel {
  final String id;
  final String title;
  final List<Entry> entries;

  AgingSummaryModel({
    required this.id,
    required this.title,
    required this.entries,
  });

  factory AgingSummaryModel.fromXml(xml.XmlElement element) {
    final id = element.findElements('id').single.text;
    final title = element.findElements('title').single.text;

    final entries = element
        .findElements('entry')
        .map((entryElement) => Entry.fromXml(entryElement))
        .toList();

    return AgingSummaryModel(
      id: id,
      title: title,
      entries: entries,
    );
  }
}

class Entry {
  final String id;
  final String title;
  final String updated;
  final Properties properties;

  Entry({
    required this.id,
    required this.title,
    required this.updated,
    required this.properties,
  });

  factory Entry.fromXml(xml.XmlElement element) {
    final id = element.findElements('id').single.text;
    final title = element.findElements('title').single.text;
    final updated = element.findElements('updated').single.text;

    final propertiesElement = element.findElements('content').single
        .findElements('m:properties')
        .single;

    final properties = Properties.fromXml(propertiesElement);

    return Entry(
      id: id,
      title: title,
      updated: updated,
      properties: properties,
    );
  }
}

class Properties {
  final String userId;
  final String sVKBUR;
  final String burks;
  final String kunnr;
  final String vkbur;
  final String name1;
  final String bezei;
  final String dmbtr;
  final String cramtt;
  final String age01;
  final String age02;
  final String age03;
  final String age04;
  final String age05;
  final String age06;
  final String age07;
  final String age08;
  final String age09;
  final String age10;
  final String age11;

  Properties( {
    required this.userId,
    required this.sVKBUR,
    required this.kunnr,
    required this.vkbur,
    required this.name1,
    required this.bezei,
    required this.dmbtr,
    required this.cramtt,
    required this.age01,
    required this.age02,
    required this.age03,
    required this.age04,
    required this.age05,
    required this.age06,
    required this.age07,
    required this.age08,
    required this.age09,
    required this.age10,
    required this.age11,
    required this.burks,
  });

  factory Properties.fromXml(xml.XmlElement element) {
    return Properties(
      userId: element.findElements('d:USER_ID').single.text,
      sVKBUR: element.findElements('d:S_VKBUR').single.text,
      kunnr: element.findElements('d:KUNNR').single.text,
      vkbur: element.findElements('d:VKBUR').single.text,
      name1: element.findElements('d:NAME1').single.text,
      bezei: element.findElements('d:BEZEI').single.text,
      dmbtr: element.findElements('d:DMBTR').single.text,
      cramtt: element.findElements('d:CRAMT').single.text,
      age01: element.findElements('d:AGE01').single.text,
      age02: element.findElements('d:AGE02').single.text,
      age03: element.findElements('d:AGE03').single.text,
      age04: element.findElements('d:AGE04').single.text,
      age05: element.findElements('d:AGE05').single.text,
      age06: element.findElements('d:AGE06').single.text,
      age07: element.findElements('d:AGE07').single.text,
      age08: element.findElements('d:AGE08').single.text,
      age09: element.findElements('d:AGE09').single.text,
      age10: element.findElements('d:AGE10').single.text,
      age11: element.findElements('d:AGE11').single.text,
      burks: element.findElements('d:BUKRS').single.text,
    );
  }
}
