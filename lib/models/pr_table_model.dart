import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart';

class PurchaseRequestTable {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final List<PurchaseRequest> purchaseRequests;

  PurchaseRequestTable({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.purchaseRequests,
  });

  factory PurchaseRequestTable.fromXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final feed = document.findElements('feed').first;

    final id = feed.findElements('id').first.text;
    final title = feed.findElements('title').first.text;
    final updated = DateTime.parse(feed.findElements('updated').first.text);
    final selfLink = feed.findElements('link').first.getAttribute('href') ?? '';

    final purchaseRequests = feed.findElements('entry').map((entry) {
      return PurchaseRequest.fromXmlElement(entry);
    }).toList();

    return PurchaseRequestTable(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      purchaseRequests: purchaseRequests,
    );
  }
}

class PurchaseRequest {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final String purNavLink;
  final List<PurchaseRequestItem> items;
  final PurchaseRequestProperties properties;

  PurchaseRequest({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.purNavLink,
    required this.items,
    required this.properties,
  });

  factory PurchaseRequest.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink =
        entry.findElements('link').first.getAttribute('href') ?? '';
    final purNavLink =
        entry.findElements('link').last.getAttribute('href') ?? '';

    final propertiesElement =
        entry.findElements('content').first.findElements('m:properties').first;
    final properties =
        PurchaseRequestProperties.fromXmlElement(propertiesElement);

    final items = entry
        .findAllElements('m:inline')
        .expand((inline) => inline.findAllElements('entry'))
        .map((itemEntry) {
      return PurchaseRequestItem.fromXmlElement(itemEntry);
    }).toList();

    return PurchaseRequest(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      purNavLink: purNavLink,
      items: items,
      properties: properties,
    );
  }
}

class PurchaseRequestProperties {
  final String pr;
  final DateTime docDate;
  final String purOrg;
  final String purGrp;
  final double valuationPrice;
  final String userId;
  final String wiId;
  final String description;
  final String htext;

  PurchaseRequestProperties(  {
    required this.pr,
    required this.docDate,
    required this.purOrg,
    required this.purGrp,
    required this.valuationPrice,
    required this.userId,
    required this.wiId,
    required this.description,
    required this.htext,
  });

  factory PurchaseRequestProperties.fromXmlElement(xml.XmlElement element) {
    final pr = element.findElements('d:PR').first.text;
    final docDate =
        DateTime.parse(element.findElements('d:DocDate').first.text);
    final purOrg = element.findElements('d:PurOrg').first.text;
    final purGrp = element.findElements('d:PurGrp').first.text;
    final valuationPrice =
        double.parse(element.findElements('d:ValuationPrice').first.text);
    final userId = element.findElements('d:USER_ID').isNotEmpty
        ? element.findElements('d:USER_ID').first.text
        : '';
    final wiId = element.findElements('d:WI_ID').isNotEmpty
        ? element.findElements('d:WI_ID').first.text
        : '';
    final description = element.findElements('d:Description').isNotEmpty
        ? element.findElements('d:WI_ID').first.text
        : '';
    final htext = element.findElements('d:Htxt').isNotEmpty
        ? element.findElements('d:Htxt').first.text
        : '';

    return PurchaseRequestProperties(
      pr: pr,
      docDate: docDate,
      purOrg: purOrg,
      purGrp: purGrp,
      valuationPrice: valuationPrice,
      userId: userId,
      wiId: wiId,
      description: description,
      htext: htext,
    );
  }
}

class PurchaseRequestItem {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final PurchaseRequestItemProperties properties;

  PurchaseRequestItem({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.properties,
  });

  factory PurchaseRequestItem.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink =
        entry.findElements('link').first.getAttribute('href') ?? '';

    final propertiesElement =
        entry.findElements('content').first.findElements('m:properties').first;
    final properties =
        PurchaseRequestItemProperties.fromXmlElement(propertiesElement);

    return PurchaseRequestItem(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      properties: properties,
    );
  }
}

class PurchaseRequestItemProperties {
  final String pr;
  final String prItem;
  final String materialDesc;
  final String material;
  final double prQty;
  final String acc_Assign;
  final String kntp;
  final String uom;
  final DateTime? deliveryDate;
  final double valuationPrice;
  final double stock;
  final String priceUnit;

  PurchaseRequestItemProperties(
      {required this.pr,
      required this.prItem,
      required this.materialDesc,
      required this.material,
      required this.prQty,
      required this.uom,
      required this.deliveryDate,
      required this.valuationPrice,
      required this.priceUnit,
      required this.stock,
      required this.kntp,
      required this.acc_Assign});

  factory PurchaseRequestItemProperties.fromXmlElement(xml.XmlElement element) {
    final pr = element.findElements('d:PR').first.text;
    final prItem = element.findElements('d:PRItem').first.text;
    final materialDesc = element.findElements('d:MaterialDesc').first.text;
    final material = element.findElements('d:Material').first.text;
    final prQty = double.parse(element.findElements('d:PRQty').first.text);
    final uom = element.findElements('d:UOM').first.text;
    final deliveryDate = element.findElements('d:DeliveryDate').isNotEmpty
        ? DateTime.tryParse(element.findElements('d:DeliveryDate').first.text)
        : null;
    final valuationPrice =
        double.parse(element.findElements('d:ValuationPrice').first.text);
    final stock = double.parse(element.findElements('d:Stock').first.text);
    final priceUnit = element.findElements('d:PriceUnit').first.text;
    final acc_Assign = element.findElements('d:Acc_Assign').first.text;
    final kntp = element.findElements('d:KNTTP').first.text;

    return PurchaseRequestItemProperties(
        pr: pr,
        prItem: prItem,
        materialDesc: materialDesc,
        material: material,
        acc_Assign: acc_Assign,
        prQty: prQty,
        uom: uom,
        deliveryDate: deliveryDate,
        valuationPrice: valuationPrice,
        priceUnit: priceUnit,
        kntp: kntp,
        stock: stock);
  }
}
