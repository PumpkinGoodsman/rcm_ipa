import 'package:xml/xml.dart' as xml;

class PurchaseOrderTable {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final List<PurchaseOrder> purchaseOrders;

  PurchaseOrderTable({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.purchaseOrders,
  });

  factory PurchaseOrderTable.fromXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final feed = document.findElements('feed').first;

    final id = feed.findElements('id').first.text;
    final title = feed.findElements('title').first.text;
    final updated = DateTime.parse(feed.findElements('updated').first.text);
    final selfLink = feed.findElements('link').first.getAttribute('href') ?? '';

    final purchaseOrders = feed.findElements('entry').map((entry) {
      return PurchaseOrder.fromXmlElement(entry);
    }).toList();

    return PurchaseOrderTable(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      purchaseOrders: purchaseOrders,
    );
  }
}

class PurchaseOrder {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final String poNavLink;
  final List<PurchaseOrderItem> items;
  final PurchaseOrderProperties properties;

  PurchaseOrder({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.poNavLink,
    required this.items,
    required this.properties,
  });

  factory PurchaseOrder.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink = entry.findElements('link').first.getAttribute('href') ?? '';
    final poNavLink = entry.findElements('link').last.getAttribute('href') ?? '';

    final propertiesElement = entry.findElements('content').first.findElements('m:properties').first;
    final properties = PurchaseOrderProperties.fromXmlElement(propertiesElement);

    final items = entry
        .findAllElements('m:inline')
        .expand((inline) => inline.findAllElements('entry'))
        .map((itemEntry) {
      return PurchaseOrderItem.fromXmlElement(itemEntry);
    }).toList();

    return PurchaseOrder(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      poNavLink: poNavLink,
      items: items,
      properties: properties,
    );
  }
}

class PurchaseOrderProperties {
  final String po;
  final String companyCode;
  final DateTime docDate;
  final String purOrg;
  final String purOrgName;
  final String purGrp;
  final String purGrpName;
  final String supplier;
  final String supplierName;
  final String currency;
  final double amount;
  final double gst;
  final double trnasport;
  final double discount1;
  final double discount2;
  final String userId;
  final String wiId;
  final String description;

  PurchaseOrderProperties({
    required this.po,
    required this.companyCode,
    required this.docDate,
    required this.purOrg,
    required this.purOrgName,
    required this.purGrp,
    required this.purGrpName,
    required this.supplier,
    required this.supplierName,
    required this.currency,
    required this.amount,
    required this.gst,
    required this.trnasport,
    required this.discount1,
    required this.discount2,
    required this.userId,
    required this.wiId,
    required this.description,
  });

  factory PurchaseOrderProperties.fromXmlElement(xml.XmlElement element) {
    final po = element.findElements('d:PO').first.text;
    final companyCode = element.findElements('d:CompanyCode').first.text;
    final docDate = DateTime.parse(element.findElements('d:DocDate').first.text);
    final purOrg = element.findElements('d:PurOrg').first.text;
    final purOrgName = element.findElements('d:PurOrgName').first.text;
    final purGrp = element.findElements('d:PurGrp').first.text;
    final purGrpName = element.findElements('d:PurGrpName').first.text;
    final supplier = element.findElements('d:Supplier').first.text;
    final supplierName = element.findElements('d:SupplierName').first.text;
    final currency = element.findElements('d:Currency').first.text;
    final amount = double.parse(element.findElements('d:Amount').first.text);
    final gst = double.parse(element.findElements('d:GST').first.text);
    final trnasport = double.parse(element.findElements('d:TRANSPORT').first.text);
    final discount1 = double.parse(element.findElements('d:DISCOUNT').first.text);
    final discount2 = double.parse(element.findElements('d:DISCOUNT2').first.text);
    final userId = element.findElements('d:USER_ID').isNotEmpty ? element.findElements('d:USER_ID').first.text : '';
    final wiId = element.findElements('d:WI_ID').isNotEmpty ? element.findElements('d:WI_ID').first.text : '';
    final description = element.findElements('d:Description').isNotEmpty ? element.findElements('d:WI_ID').first.text : '';

    return PurchaseOrderProperties(
      po: po,
      companyCode: companyCode,
      docDate: docDate,
      purOrg: purOrg,
      purOrgName: purOrgName,
      purGrp: purGrp,
      purGrpName: purGrpName,
      supplier: supplier,
      supplierName: supplierName,
      currency: currency,
      amount: amount,
      gst: gst,
      trnasport: trnasport,
      discount1: discount1,
      discount2: discount2,
      userId: userId,
      wiId: wiId,
      description: description,
    );
  }
}

class PurchaseOrderItem {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final PurchaseOrderItemProperties properties;

  PurchaseOrderItem({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.properties,
  });

  factory PurchaseOrderItem.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink = entry.findElements('link').first.getAttribute('href') ?? '';

    final propertiesElement = entry.findElements('content').first.findElements('m:properties').first;
    final properties = PurchaseOrderItemProperties.fromXmlElement(propertiesElement);

    return PurchaseOrderItem(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      properties: properties,
    );
  }
}

class PurchaseOrderItemProperties {
  final String po;
  final String poItem;
  final String material;
  final String materialDesc;
  final double poQty;
  final String uom;
  final DateTime deliveryDate;
  final double rate;
  final double netPrice;
  final String currency;
  final String hsCode;
  final String kntp;

  PurchaseOrderItemProperties({
    required this.po,
    required this.poItem,
    required this.material,
    required this.materialDesc,
    required this.poQty,
    required this.uom,
    required this.deliveryDate,
    required this.rate,
    required this.netPrice,
    required this.currency,
    required this.hsCode,
    required this.kntp,
  });

  factory PurchaseOrderItemProperties.fromXmlElement(xml.XmlElement element) {
    final po = element.findElements('d:PO').first.text;
    final poItem = element.findElements('d:POItem').first.text;
    final material = element.findElements('d:Material').first.text;
    final materialDesc = element.findElements('d:MaterialDesc').first.text;
    final poQty = double.parse(element.findElements('d:PoQty').first.text);
    final uom = element.findElements('d:UOM').first.text;
    final deliveryDate = DateTime.parse(element.findElements('d:DeliveryDate').first.text);
    final rate = double.parse(element.findElements('d:Rate').first.text);
    final netPrice = double.parse(element.findElements('d:NetPrice').first.text);
    final currency = element.findElements('d:Currency').first.text;
    final hsCode = element.findElements('d:HSCODE').isNotEmpty ? element.findElements('d:HSCODE').first.text : '';
    final kntp = element.findElements('d:KNTTP').isNotEmpty ? element.findElements('d:KNTTP').first.text : '';

    return PurchaseOrderItemProperties(
      po: po,
      poItem: poItem,
      material: material,
      materialDesc: materialDesc,
      poQty: poQty,
      uom: uom,
      deliveryDate: deliveryDate,
      rate: rate,
      netPrice: netPrice,
      currency: currency,
      hsCode: hsCode,
      kntp: kntp,
    );
  }
}
