
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController{

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set loading(bool newValue){

    _isLoading = newValue;
  }

  bool _isObscure = true;

  bool get isObscure => _isObscure;

  set obscure(bool newValue){

    _isObscure = newValue;
  }
  bool _isCheck = false;

  bool get isCheck => _isCheck;

  set check(bool newValue){

    _isCheck = newValue;
  }

  bool _isFirstTime = true;

  bool get isFirstTime => _isFirstTime;

  set firstTime(bool newValue){
    _isFirstTime = newValue;
  }

  bool _isLoggin = false;

  bool get isloggin => _isLoggin;

  set isLoggin(bool newValue){
    _isLoggin = newValue;
  }

  isLogin()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggin', isloggin);
  }

  logOut()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firstTime = await prefs.setBool("firstTime", false);
    _isFirstTime = false;
    firstTime = false;

  }

   removeData()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();
    storage.delete(key: 'SessionPAD_ID');
    storage.delete(key: 'sapUserId');
    storage.delete(key: 'userName');
    storage.delete(key: 'pass');
    prefs.remove('userName');
    prefs.remove('isLoggin');


  }

  String numberToWords(int number) {
    if (number == 0) return 'zero';

    final List<String> units = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen'
    ];
    final List<String> tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety'
    ];

    String convertBelowThousand(int n) {
      String str = '';
      if (n >= 100) {
        str += units[n ~/ 100] + ' hundred ';
        n %= 100;
      }
      if (n >= 20) {
        str += tens[n ~/ 10] + ' ';
        n %= 10;
      }
      if (n > 0) {
        str += units[n] + ' ';
      }
      return str.trim();
    }

    String result = '';

    if (number >= 10000000) {
      result += convertBelowThousand(number ~/ 10000000) + ' crore ';
      number %= 10000000;
    }

    if (number >= 100000) {
      result += convertBelowThousand(number ~/ 100000) + ' lakh ';
      number %= 100000;
    }

    if (number >= 1000) {
      result += convertBelowThousand(number ~/ 1000) + ' thousand ';
      number %= 1000;
    }

    result += convertBelowThousand(number);

    return result.trim();
  }
}