
import 'package:get/get.dart';

class TableController extends GetxController{

  bool _isApproval = false;

  bool get isApproval => _isApproval;

  set approval(bool newValue){

    _isApproval = newValue;
  }

  bool _isRejected = false;

  bool get isRejected => _isRejected;

  set rejected(bool newValue){

    _isRejected = newValue;
  }


}

