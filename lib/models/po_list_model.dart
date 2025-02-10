import 'package:xml/xml.dart';

class PurchaseOrderSet {
  final List<PurchaseOrderEntry> entries;

  PurchaseOrderSet({required this.entries});

  factory PurchaseOrderSet.fromXml(XmlElement xml) {
    var entryElements = xml.findAllElements('entry');
    var entries = entryElements.map((entry) {
      return PurchaseOrderEntry.fromXml(entry);
    }).toList();

    return PurchaseOrderSet(entries: entries);
  }
}

class PurchaseOrderEntry {
  final String po;
  final String companyCode;
  final DateTime docDate;
  final String purOrg;
  final String purGrp;
  final String supplier;
  final String supplierName;
  final String currency;
  final double amount;
  final String userId;
  final String wiId;

  PurchaseOrderEntry({
    required this.po,
    required this.companyCode,
    required this.docDate,
    required this.purOrg,
    required this.purGrp,
    required this.supplier,
    required this.supplierName,
    required this.currency,
    required this.amount,
    required this.userId,
    required this.wiId,
  });

  factory PurchaseOrderEntry.fromXml(XmlElement xml) {
    var properties = xml.findElements('content').firstOrNull?.findElements('m:properties').firstOrNull;

    return PurchaseOrderEntry(
      po: properties?.findElements('d:PO').firstOrNull?.text ?? '',
      companyCode: properties?.findElements('d:CompanyCode').firstOrNull?.text ?? '',
      docDate: DateTime.tryParse(properties?.findElements('d:DocDate').firstOrNull?.text ?? '') ?? DateTime.now(),
      purOrg: properties?.findElements('d:PurOrg').firstOrNull?.text ?? '',
      purGrp: properties?.findElements('d:PurGrp').firstOrNull?.text ?? '',
      supplier: properties?.findElements('d:Supplier').firstOrNull?.text ?? '',
      supplierName: properties?.findElements('d:SupplierName').firstOrNull?.text ?? '',
      currency: properties?.findElements('d:Currency').firstOrNull?.text ?? '',
      amount: double.tryParse(properties?.findElements('d:Amount').firstOrNull?.text ?? '0.0') ?? 0.0,
      userId: properties?.findElements('d:USER_ID').firstOrNull?.text ?? '',
      wiId: properties?.findElements('d:WI_ID').firstOrNull?.text ?? '',
    );
  }
}
