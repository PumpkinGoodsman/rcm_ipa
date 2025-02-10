import 'package:xml/xml.dart';

class Auth {
  final String username;
  final String pr;
  final String po;
  final String res;
  final String rep1;
  final String rep2;
  final String rep3;
  final String rep4;
  final String salesPal;
  final String salesAcm;
  final String prodPal;
  final String prodAcm;

  Auth({
    required this.username,
    required this.pr,
    required this.po,
    required this.res,
    required this.rep1,
    required this.rep2,
    required this.rep3,
    required this.rep4,
    required this.salesPal,
    required this.salesAcm,
    required this.prodPal,
    required this.prodAcm,
  });

  factory Auth.fromXml(XmlElement xml) {
    String getElementText(String tag, XmlElement xml) {
      final element = xml.findElements(tag).singleOrNull;
      return element != null ? element.text : '';
    }

    return Auth(
      username: getElementText('d:Username', xml),
      pr: getElementText('d:Pr', xml),
      po: getElementText('d:Po', xml),
      res: getElementText('d:Res', xml),
      rep1: getElementText('d:Rep1', xml),
      rep2: getElementText('d:Rep2', xml),
      rep3: getElementText('d:Rep3', xml),
      rep4: getElementText('d:Rep4', xml),
      salesPal: getElementText('d:SALES_PAL', xml),
      salesAcm: getElementText('d:SALES_ACM', xml),
      prodPal: getElementText('d:PROD_PAL', xml),
      prodAcm: getElementText('d:PROD_ACM', xml),
    );
  }
}

extension XmlElementExtension on Iterable<XmlElement> {
  XmlElement? get singleOrNull {
    if (isEmpty) return null;
    return single;
  }
}
