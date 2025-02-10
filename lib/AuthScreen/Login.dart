import 'package:ACM/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ACM/controller/auth_controller.dart';
import 'dart:convert';
import '../Widgets/Auth/fields.dart';
import '../views/Dashboard.dart';
import 'confirm_password.dart';
import 'package:ACM/services/helper/notification_services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {

  bool isLoading = false;
  bool check = false;
  AuthController controller = AuthController();
  NotificationServices notificationServices = NotificationServices();
  final storage = const FlutterSecureStorage();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userID = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.setupInteractMessage(context);
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices = NotificationServices();
    //_loadSavedPassword();
  }

  Future<void> _login() async {
    const storage = FlutterSecureStorage();
    const String apiUsername = 'mobile';
    const String apiPassword = 'pakistan@123\$';
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiUsername:$apiPassword'))}';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            "$basUrl/LoginSet(ImUserName='${_userID.text}',ImPassword='${_passwordController.text}')"),
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
          'X-CSRF-Token': 'Fetch'
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        String? csrfToken = response.headers['x-csrf-token'];

        await storage.write(key: 'csrfToken', value: csrfToken);

        final Map<String, dynamic> entries = responseData['d'];

        bool userFound = false;
        bool? isInitialValue;

        // Convert input username to lowercase for comparison
        String lowercaseInputUsername = _userID.text.toLowerCase();

        if (entries['Username'].toString().toLowerCase() ==
                lowercaseInputUsername) {
          isInitialValue = entries['Isinitial'] == 'X';
          await storage.write(key: 'userName', value: entries['Username']);
          await storage.write(key: 'pass', value: entries['Password']);
          await storage.write(key: 'sapUserId', value: entries['SapUserId']);

          userFound = true;
        }

        //notificationServices.firebaseInit(context);
        notificationServices.getDeviceToken();
        notificationServices.getDeviceToken().then((value) {
        });
        notificationServices.requestNotificationPermission();
        //notificationServices.getDeviceToken();

        print('User Found $userFound');
        if (userFound) {
          // Extract SessionPAD_ID from set-cookie header
          String sessionPadId =
              _extractSessionPadId(response.headers['set-cookie']);
          if (sessionPadId.isNotEmpty) {
            // Store SessionPAD_ID in SharedPreferences
            await storage.write(key: 'SessionPAD_ID', value: sessionPadId);
          }

          setState(() {
            Get.snackbar('Successfully Sign in', 'Enjoy your sap app!',
                backgroundColor: Colors.green, colorText: Colors.white);
          });

          if (isInitialValue == true) {
            controller.isLoggin = true;
            controller.isLogin();

            Get.offAll(() => const Dashboard(),
                transition: Transition.rightToLeft,
                duration: const Duration(seconds: 2));
          } else {
            Get.to(() => const ConfirmPasswordScreen(),
                transition: Transition.fadeIn, duration: const Duration(seconds: 2));
          }
        } else {
          setState(() {
            Get.snackbar('Login Failed', 'User not found',
                backgroundColor: Colors.red, colorText: Colors.white);
          });
        }
      } else {
        setState(() {
          Get.snackbar('Login Failed', 'User not found',
              backgroundColor: Colors.red, colorText: Colors.white);
        });
      }
    } catch (e) {
      setState(() {
        Get.snackbar('Login Failed', 'User not found',
            backgroundColor: Colors.red, colorText: Colors.white);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _loadSavedPassword() async {
    bool rememberMe = (await storage.read(key: 'rememberMe')) == 'true';
    final pw = await storage.read(key: 'password') ?? '';
    final userId = await storage.read(key: '_userId') ?? '';

    if (rememberMe) {
      setState(() {
        check = true;
        _passwordController.text = pw;
        _userID.text = userId;
      });
    }
  }

  Future<void> _toggleRememberMe() async {
    setState(() {
      check = !check;
    });

    if (check) {
      // Save the password when "Remember Me" is checked
      await storage.write(key: 'rememberMe', value: 'true');
      await storage.write(key: 'password', value: _passwordController.text);
      await storage.write(key: '_userId', value: _userID.text);
    } else {
      // Remove saved password when "Remember Me" is unchecked
      await storage.write(key: 'rememberMe', value: 'false');
      await storage.delete(key: 'password');
      await storage.delete(key: '_userId');

      // Clear text fields after state has been updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _passwordController.clear();
          _userID.clear();
        });
      });
    }
  }

  // String _extractSessionPadId(String? setCookieHeader) {
  //   if (setCookieHeader == null) return '';
  //
  //   final regExp = RegExp(r'SAP_SESSIONID_PAD_800=([^;]+)');
  //   final match = regExp.firstMatch(setCookieHeader);
  //   return match?.group(1) ?? '';
  // }

  String _extractSessionPadId(String? setCookieHeader) {
    if (setCookieHeader == null) return '';

    // Print the entire set-cookie header for debugging

    // Adjusted regex to match SAP_SESSIONID_PAP_800
    final regExp = RegExp(r'SAP_SESSIONID_PAP_800=([^;]+)');
    final match = regExp.firstMatch(setCookieHeader);

    // Check if the regex finds a match
    if (match != null) {
      final sessionId = match.group(1);
      return sessionId ?? '';
    } else {
      return '';
    }
  }



  @override
  Widget build(BuildContext context) {

    // final TextEditingController _userIDController = TextEditingController();
    // final TextEditingController _passwordController = TextEditingController();
    //
    // _userID = _userIDController.text;
    // _password = _passwordController.text;
    //
    // print(_userID);
    // print(_password);

    _loadSavedPassword();
    final controller = Get.put(AuthController());
    return WillPopScope(
      onWillPop: () async {
        // Returning false to disable the back button
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 30),
                      Center(
                        child: SizedBox(
                          height: 150,
                          child: Image.asset("assets/logo.jpg"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 100,
                          color: Color.fromARGB(255, 148, 148, 148),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Authfields(
                        text: _userID,
                        label: "User ID",
                        obscuretext: false,
                      ),
                      const SizedBox(height: 10),
                      Authfields(
                         text: _passwordController,
                        label: "Password",
                        obscuretext: controller.isObscure,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              controller.obscure = !controller.isObscure;
                            });
                          },
                          child: Icon(
                            controller.isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleRememberMe,
                            child: Container(
                              width: 18.0,
                              height: 18.0,
                              decoration: BoxDecoration(
                                color: check ? Colors.blue : Colors.transparent,
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: check
                                  ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember me',
                            style: TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // controller.isLoggin = true;
                            // controller.isLogin();
                            _login();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue.shade900
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.white,
                                  )),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Colors.blue.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Image.asset(
              "assets/sap.png",
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
