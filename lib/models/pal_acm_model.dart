import 'package:xml/xml.dart' as xml;

// Define the Feed class
class SalesProdData {
  final String id;
  final String title;
  final String updated;
  final List<Entry> entries;

  SalesProdData({required this.id, required this.title, required this.updated, required this.entries});

  factory SalesProdData.fromXml(xml.XmlDocument document) {
    var feedElement = document.findAllElements('feed').first;
    var id = feedElement.findElements('id').first.text;
    var title = feedElement.findElements('title').first.text;
    var updated = feedElement.findElements('updated').first.text;
    var entries = feedElement.findAllElements('entry').map((entryElement) => Entry.fromXml(entryElement)).toList();

    return SalesProdData(id: id, title: title, updated: updated, entries: entries);
  }
}

// Define the Entry class
class Entry {
  final String id;
  final String title;
  final String updated;
  final double salePal;
  final double salePalQty;
  final double saleAcm;
  final double saleAcmQty;
  final double prodPal;
  final double prodAcm;
  final String userId;

  Entry( {
    required this.id,
    required this.title,
    required this.updated,
    required this.salePal,
    required this.saleAcm,
    required this.prodPal,
    required this.prodAcm,
    required this.userId,
    required this.salePalQty, required this.saleAcmQty,
  });

  factory Entry.fromXml(xml.XmlElement element) {
    var id = element
        .findElements('id')
        .first
        .text;
    var title = element
        .findElements('title')
        .first
        .text;
    var updated = element
        .findElements('updated')
        .first
        .text;
    var content = element
        .findElements('content')
        .first;
    var properties = content
        .findElements('m:properties')
        .first;

    var salePal = double.parse(properties
        .findElements('d:Sale_Pal')
        .first
        .text);
    var salePalQty = double.parse(properties
        .findElements('d:Sale_PalQty')
        .first
        .text);
    var saleAcm = double.parse(properties
        .findElements('d:Sale_Acm')
        .first
        .text);
    var saleAcmQty = double.parse(properties
        .findElements('d:Sale_AcmQty')
        .first
        .text);
    var prodPal = double.parse(properties
        .findElements('d:Prod_Pal')
        .first
        .text);
    var prodAcm = double.parse(properties
        .findElements('d:Prod_Acm')
        .first
        .text);
    var userId = properties
        .findElements('d:USER_ID')
        .first
        .text;

    return Entry(
        id: id,
        title: title,
        updated: updated,
        salePal: salePal,
        saleAcmQty: saleAcmQty,
        salePalQty: salePalQty,
        saleAcm: saleAcm,
        prodPal: prodPal,
        prodAcm: prodAcm,
        userId: userId);
  }}