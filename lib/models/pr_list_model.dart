import 'package:xml/xml.dart';

class PurchaseRequestSet {
  final List<PurchaseOrderEntry> entries;

  PurchaseRequestSet({required this.entries});

  factory PurchaseRequestSet.fromXml(XmlElement xml) {
    var entryElements = xml.findAllElements('entry');
    var entries = entryElements.map((entry) {
      return PurchaseOrderEntry.fromXml(entry);
    }).toList();

    return PurchaseRequestSet(entries: entries);
  }
}

class PurchaseOrderEntry {
  final String pr;
  final String companyCode;
  final DateTime docDate;
  final String purOrg;
  final String purGrp;
  final String supplier;
  final String supplierName;
  final String priceUnit;
  final double valuationPrice;
  final String userId;
  final String wiId;

  PurchaseOrderEntry({
    required this.pr,
    required this.companyCode,
    required this.docDate,
    required this.purOrg,
    required this.purGrp,
    required this.supplier,
    required this.supplierName,
    required this.priceUnit,
    required this.valuationPrice,
    required this.userId,
    required this.wiId,
  });

  factory PurchaseOrderEntry.fromXml(XmlElement xml) {
    var properties = xml.findElements('content').firstOrNull?.findElements('m:properties').firstOrNull;

    return PurchaseOrderEntry(
      pr: properties?.findElements('d:PR').firstOrNull?.text ?? '',
      companyCode: properties?.findElements('d:CompanyCode').firstOrNull?.text ?? '',
      docDate: DateTime.tryParse(properties?.findElements('d:DocDate').firstOrNull?.text ?? '') ?? DateTime.now(),
      purOrg: properties?.findElements('d:PurOrg').firstOrNull?.text ?? '',
      purGrp: properties?.findElements('d:PurGrp').firstOrNull?.text ?? '',
      supplier: properties?.findElements('d:Supplier').firstOrNull?.text ?? '',
      supplierName: properties?.findElements('d:SupplierName').firstOrNull?.text ?? '',
      priceUnit: properties?.findElements('d:PriceUnit').firstOrNull?.text ?? '',
      valuationPrice: double.tryParse(properties?.findElements('d:ValuationPrice').firstOrNull?.text ?? '0.0') ?? 0.0,
      userId: properties?.findElements('d:USER_ID').firstOrNull?.text ?? '',
      wiId: properties?.findElements('d:WI_ID').firstOrNull?.text ?? '',
    );
  }
}
