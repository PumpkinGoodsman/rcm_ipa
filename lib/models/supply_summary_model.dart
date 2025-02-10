import 'package:xml/xml.dart' as xml;

class SupplySummaryModel {
  final String id;
  final String title;
  final List<Entry> entries;

  SupplySummaryModel({
    required this.id,
    required this.title,
    required this.entries,
  });

  factory SupplySummaryModel.fromXml(xml.XmlElement element) {
    final id = element.findElements('id').single.text;
    final title = element.findElements('title').single.text;

    final entries = element
        .findElements('entry')
        .map((entryElement) => Entry.fromXml(entryElement))
        .toList();

    return SupplySummaryModel(
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
  final String vkbur;
  final String bezei;
  final String zmvgr3;
  final String zmvgr2;
  final String zmvgr4;
  final String fkimg;
  final String kwert;
  final String zmon;

  Properties({
    required this.userId,
    required this.sVKBUR,
    required this.burks,
    required this.vkbur,
    required this.bezei,
    required this.zmvgr3,
    required this.zmvgr2,
    required this.zmvgr4,
    required this.fkimg,
    required this.kwert,
    required this.zmon,
  });

  factory Properties.fromXml(xml.XmlElement element) {
    return Properties(
      userId: element.findElements('d:USER_ID').single.text,
      sVKBUR: element.findElements('d:S_VKBUR').single.text,
      burks: element.findElements('d:BUKRS').single.text,
      vkbur: element.findElements('d:VKBUR').single.text,
      bezei: element.findElements('d:BEZEI').single.text,
      zmvgr3: element.findElements('d:ZMVGR3').single.text,
      zmvgr2: element.findElements('d:ZMVGR2').single.text,
      zmvgr4: element.findElements('d:ZMVGR4').single.text,
      fkimg: element.findElements('d:FKIMG').single.text,
      kwert: element.findElements('d:KWERT').single.text,
      zmon: element.findElements('d:ZMON').single.text,
    );
  }
}
