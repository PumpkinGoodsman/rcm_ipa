import 'package:xml/xml.dart';

class ApprovalRequest {
  final String wiId;
  final String userId;
  final String typeId;
  final String instId;

  ApprovalRequest({
    required this.wiId,
    required this.userId,
    required this.typeId,
    required this.instId,
  });

  factory ApprovalRequest.fromXml(XmlElement xml) {
    return ApprovalRequest(
      wiId: xml.getElement('d:WiId')?.innerText ?? '',
      userId: xml.getElement('d:UserId')?.innerText ?? '',
      typeId: xml.getElement('d:Typeid')?.innerText ?? '',
      instId: xml.getElement('d:Instid')?.innerText ?? '',
    );
  }

  int getContentLength() {
    return wiId.length + userId.length + typeId.length + instId.length;
  }
}
