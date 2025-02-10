import 'package:xml/xml.dart' as xml;

class CustomerSummaryModel {
  final String id;
  final String title;
  final List<Entry> entries;

  CustomerSummaryModel({
    required this.id,
    required this.title,
    required this.entries,
  });

  factory CustomerSummaryModel.fromXml(xml.XmlElement element) {
    final id = element.findElements('id').single.text;
    final title = element.findElements('title').single.text;

    final entries = element
        .findElements('entry')
        .map((entryElement) => Entry.fromXml(entryElement))
        .toList();

    return CustomerSummaryModel(
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
  final String opbal;
  final String qty;
  final String retail;
  final String value;
  final String othdr;
  final String zmon;
  final String name1;
  final String incentives;
  final String other;
  final String baltrne;
  final String adjustment;
  final String clbal;
  final String totrec;

  Properties(
       {
    required this.userId,
    required this.sVKBUR,
    required this.burks,
    required this.vkbur,
    required this.bezei,
    required this.opbal,
    required this.qty,
    required this.retail,
    required this.value,
    required this.othdr,
    required this.zmon,
         required this.name1,
         required this.incentives,
         required this.other,
         required this.baltrne,
         required this.adjustment,
         required this.clbal,
         required this.totrec,
  });

  factory Properties.fromXml(xml.XmlElement element) {
    return Properties(
      userId: element.findElements('d:USER_ID').single.text,
      sVKBUR: element.findElements('d:S_VKBUR').single.text,
      burks: element.findElements('d:BUKRS').single.text,
      vkbur: element.findElements('d:VKBUR').single.text,
      bezei: element.findElements('d:BEZEI').single.text,
      name1: element.findElements('d:NAME1').single.text,
      opbal: element.findElements('d:OP_BAL').single.text,
      qty: element.findElements('d:QTY').single.text,
      retail: element.findElements('d:RETAIL').single.text,
      value: element.findElements('d:VALUE').single.text,
      othdr: element.findElements('d:OTH_DR').single.text,
      zmon: element.findElements('d:ZMON').single.text,
      incentives: element.findElements('d:INCENTIVES').single.text,
      other: element.findElements('d:OTHER').single.text,
      baltrne: element.findElements('d:BAL_TRNF').single.text,
      adjustment: element.findElements('d:ADJUSTMENT').single.text,
      clbal: element.findElements('d:CL_BAL').single.text,
      totrec: element.findElements('d:TOT_REC').single.text,
    );
  }
}
