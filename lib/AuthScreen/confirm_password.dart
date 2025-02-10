import 'package:ACM/Widgets/Auth/fields.dart';
import 'package:ACM/controller/auth_controller.dart';
import 'package:ACM/models/update_password_model.dart';
import 'package:ACM/services/helper/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';




class ConfirmPasswordScreen extends StatefulWidget {
  const ConfirmPasswordScreen({
    super.key,
  });

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {

  TextEditingController passcontroller = TextEditingController();
  TextEditingController confirmPascontroller = TextEditingController();

  AuthHelper helper = AuthHelper();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    passcontroller.dispose();
    confirmPascontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AuthController());
    print(controller.isloggin);
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Password'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 150,
                  child: Image.asset("assets/logo.jpg"),
                ),
                SizedBox(
                  height: 20,
                ),
                Authfields(
                  label: 'Password',
                  obscuretext: true,
                  text: passcontroller,
                ),
                SizedBox(
                  height: 10,
                ),
                Authfields(
                  label: 'Confirm-Password',
                  obscuretext: true,
                  text: confirmPascontroller,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (passcontroller.text.isNotEmpty &&
                          confirmPascontroller.text.isNotEmpty) {
                        if (passcontroller.text == confirmPascontroller.text) {
                          UpdatePassModel model = UpdatePassModel(
                              newPassword: passcontroller.text,
                              confPassword: confirmPascontroller.text);

                          //helper.updatePassword();
                          controller.isLoggin = true;
                          controller.isLogin();

                          setState(() {
                           helper.updatePassword(model);
                         });
                        } else {
                          Get.snackbar(
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              icon: Icon(Icons.info),
                              'Update Failed',
                              'Please your password should be matched');
                        }
                      } else {
                        Get.snackbar(
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            icon: Icon(Icons.info),
                            'Update Failed',
                            'Please fill your fields');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue.shade900),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: helper.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
