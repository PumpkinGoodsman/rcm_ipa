import 'package:xml/xml.dart' as xml;

// Main class to hold the ReservationTable
class ReservationTable {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final List<Reservation> reservations;

  ReservationTable({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.reservations,
  });

  factory ReservationTable.fromXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final feed = document.findElements('feed').first;

    final id = feed.findElements('id').first.text;
    final title = feed.findElements('title').first.text;
    final updated = DateTime.parse(feed.findElements('updated').first.text);
    final selfLink = feed.findElements('link').first.getAttribute('href') ?? '';

    final reservations = feed.findElements('entry').map((entry) {
      return Reservation.fromXmlElement(entry);
    }).toList();

    return ReservationTable(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      reservations: reservations,
    );
  }
}

// Class to hold Reservation details
class Reservation {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final List<ReservationItem> items;
  final ReservationProperties properties;

  Reservation({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.items,
    required this.properties,
  });

  factory Reservation.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink = entry.findElements('link').first.getAttribute('href') ?? '';

    final propertiesElement = entry.findElements('content').first.findElements('m:properties').first;
    final properties = ReservationProperties.fromXmlElement(propertiesElement);

    final items = entry
        .findAllElements('m:inline')
        .expand((inline) => inline.findAllElements('entry'))
        .map((itemEntry) {
      return ReservationItem.fromXmlElement(itemEntry);
    }).toList();

    return Reservation(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      items: items,
      properties: properties,
    );
  }
}

// Class to hold Reservation properties
class ReservationProperties {
  final String resNo;
  final DateTime? docDate;
  final String movementType;
  final String costCenter;
  final String recPlant;
  final String recLocation;
  final String userId;
  final String wiId;

  ReservationProperties({
    required this.resNo,
    required this.docDate,
    required this.movementType,
    required this.costCenter,
    required this.recPlant,
    required this.recLocation,
    required this.userId,
    required this.wiId,
  });

  factory ReservationProperties.fromXmlElement(xml.XmlElement element) {
    final resNo = element.findElements('d:RESNO').first.text;
    final docDate = element.findElements('d:DocDate').isNotEmpty
        ? DateTime.tryParse(element.findElements('d:DocDate').first.text)
        : null;
    final movementType = element.findElements('d:MovmentType').first.text;
    final costCenter = element.findElements('d:CostCenter').first.text;
    final recPlant = element.findElements('d:RecPlant').first.text;
    final recLocation = element.findElements('d:RecLocation').first.text;
    final userId = element.findElements('d:USER_ID').first.text;
    final wiId = element.findElements('d:WI_ID').first.text;

    return ReservationProperties(
      resNo: resNo,
      docDate: docDate,
      movementType: movementType,
      costCenter: costCenter,
      recPlant: recPlant,
      recLocation: recLocation,
      userId: userId,
      wiId: wiId,
    );
  }
}

class ReservationItemProperties {
  final String resNo;
  final String item;
  final String material;
  final String materialDesc;
  final String plant;
  final String location;
  final DateTime? reqDate;
  final double qty;
  final String charg;
  final double lpPrice;
  final double cStock;
  final String bun;
  final String text;
  final String plantLocation;

  ReservationItemProperties({
    required this.resNo,
    required this.item,
    required this.material,
    required this.materialDesc,
    required this.plant,
    required this.location,
    required this.reqDate,
    required this.qty,
    required this.charg,
    required this.lpPrice,
    required this.cStock,
    required this.bun,
    required this.text,
    required this.plantLocation,
  });

  factory ReservationItemProperties.fromXmlElement(xml.XmlElement element) {
    final resNo = element.findElements('d:RESNO').first.text;
    final item = element.findElements('d:Item').first.text;
    final material = element.findElements('d:Material').first.text;
    final materialDesc = element.findElements('d:MaterialDesc').first.text;
    final plant = element.findElements('d:Plant').first.text;
    final location = element.findElements('d:Location').first.text;
    final reqDate = element.findElements('d:ReqDate').isNotEmpty
        ? DateTime.tryParse(element.findElements('d:ReqDate').first.text)
        : null;
    final qty = double.tryParse(element.findElements('d:Qty').first.text) ?? 0.0;
    final charg = element.findElements('d:charg').first.text;
    final lpPrice = double.tryParse(element.findElements('d:LPPRICE').first.text) ?? 0.0;
    final cStock = double.tryParse(element.findElements('d:CSTOCK').first.text) ?? 0.0;
    final bun = element.findElements('d:BUN').first.text;
    final text = element.findElements('d:TEXT').first.text;
    final plantLocation = element.findElements('d:PlantLocation').first.text;

    return ReservationItemProperties(
      resNo: resNo,
      item: item,
      material: material,
      materialDesc: materialDesc,
      plant: plant,
      location: location,
      reqDate: reqDate,
      qty: qty,
      charg: charg,
      lpPrice: lpPrice,
      cStock: cStock,
      bun: bun,
      text: text,
      plantLocation: plantLocation,
    );
  }
}


// Class to hold individual ReservationItem details
class ReservationItem {
  final String id;
  final String title;
  final DateTime updated;
  final String selfLink;
  final ReservationItemProperties properties;

  ReservationItem({
    required this.id,
    required this.title,
    required this.updated,
    required this.selfLink,
    required this.properties,
  });

  factory ReservationItem.fromXmlElement(xml.XmlElement entry) {
    final id = entry.findElements('id').first.text;
    final title = entry.findElements('title').first.text;
    final updated = DateTime.parse(entry.findElements('updated').first.text);
    final selfLink = entry.findElements('link').first.getAttribute('href') ?? '';

    final propertiesElement = entry.findElements('content').first.findElements('m:properties').first;
    final properties = ReservationItemProperties.fromXmlElement(propertiesElement);

    return ReservationItem(
      id: id,
      title: title,
      updated: updated,
      selfLink: selfLink,
      properties: properties,
    );
  }
}

// Class to hold properties of each ReservationItem
// class ReservationItemProperties {
//   final String resNo;
//   final String item;
//   final String material;
//   final String materialDesc;
//   final String plant;
//   final String location;
//   final DateTime? reqDate;
//   final double qty;
//   final String charg;
//   final double lpPrice;
//   final double cStock;
//   final String bun;
//
//   ReservationItemProperties({
//     required this.resNo,
//     required this.item,
//     required this.material,
//     required this.materialDesc,
//     required this.plant,
//     required this.location,
//     required this.reqDate,
//     required this.qty,
//     required this.charg,
//     required this.lpPrice,
//     required this.cStock,
//     required this.bun,
//   });
//
//   factory ReservationItemProperties.fromXmlElement(xml.XmlElement element) {
//     final resNo = element.findElements('d:RESNO').first.text;
//     final item = element.findElements('d:Item').first.text;
//     final material = element.findElements('d:Material').first.text;
//     final materialDesc = element.findElements('d:MaterialDesc').first.text;
//     final plant = element.findElements('d:Plant').first.text;
//     final location = element.findElements('d:Location').first.text;
//     final reqDate = element.findElements('d:ReqDate').isNotEmpty
//         ? DateTime.tryParse(element.findElements('d:ReqDate').first.text)
//         : null;
//     final qty = double.parse(element.findElements('d:Qty').first.text);
//     final charg = element.findElements('d:charg').first.text;
//     final lpPrice = double.parse(element.findElements('d:LPPRICE').first.text);
//     final cStock = double.parse(element.findElements('d:CSTOCK').first.text);
//     final bun = element.findElements('d:BUN').first.text;
//
//     return ReservationItemProperties(
//       resNo: resNo,
//       item: item,
//       material: material,
//       materialDesc: materialDesc,
//       plant: plant,
//       location: location,
//       reqDate: reqDate,
//       qty: qty,
//       charg: charg,
//       lpPrice: lpPrice,
//       cStock: cStock,
//       bun: bun,
//     );
//   }
// }
