import 'package:xml/xml.dart' as xml;

class ReservationSet {
  final List<ReservationEntry> entries;

  ReservationSet({required this.entries});

  factory ReservationSet.fromXml(xml.XmlDocument document) {
    var entryElements = document.findAllElements('entry');
    var entries = entryElements.map((entry) {
      return ReservationEntry.fromXml(entry);
    }).toList();

    return ReservationSet(entries: entries);
  }
}

class ReservationEntry {
  final String resno;
  final String? docDate;
  final String movmentType;
  final String? costCenter;
  final String? recPlant;
  final String? recLocation;
  final String userId;
  final String wiId;

  ReservationEntry({
    required this.resno,
    this.docDate,
    required this.movmentType,
    this.costCenter,
    this.recPlant,
    this.recLocation,
    required this.userId,
    required this.wiId,
  });

  factory ReservationEntry.fromXml(xml.XmlElement element) {
    var properties = element.findElements('content').first.findElements('m:properties').first;

    return ReservationEntry(
      resno: properties.getElement('d:RESNO')?.innerText ?? '',
      docDate: properties.getElement('d:DocDate')?.innerText,
      movmentType: properties.getElement('d:MovmentType')?.innerText ?? '',
      costCenter: properties.getElement('d:CostCenter')?.innerText,
      recPlant: properties.getElement('d:RecPlant')?.innerText,
      recLocation: properties.getElement('d:RecLocation')?.innerText,
      userId: properties.getElement('d:USER_ID')?.innerText ?? '',
      wiId: properties.getElement('d:WI_ID')?.innerText ?? '',
    );
  }
}
