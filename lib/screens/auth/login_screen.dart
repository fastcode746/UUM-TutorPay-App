// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fee_app/config/theme.dart';
import 'package:fee_app/config/utils.dart';
import 'package:fee_app/screens/auth/signup_screen.dart';
import 'package:fee_app/screens/student/dashboard_screen.dart';
import 'package:fee_app/screens/tutor/dashboard_screen.dart';
import 'package:fee_app/services/auth_service.dart';
import 'package:fee_app/services/database_service.dart';
import 'package:fee_app/services/helper_service.dart';
import 'package:fee_app/widgets/logo_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  var userType = ['Tutor', 'Student'];

  String? selectedUserType;
  bool obscureText = true;
  bool isLoading = false;
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LogoContainer(height: MediaQuery.of(context).size.height / 3),
              SizedBox(height: 20),
              Form(
                key: formkey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 150,
                            child: FormField<String>(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select user type';
                                }
                                return null;
                              },
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    errorStyle: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12.0,
                                    ),
                                    errorText:
                                        state.hasError ? state.errorText : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  isEmpty: selectedUserType == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedUserType,
                                      isDense: true,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedUserType = newValue;
                                          state.didChange(newValue);
                                        });
                                      },
                                      items:
                                          userType.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                      hint: Text(
                                        "Select Role",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // Email Field
                      Text(
                        'Email / Username',
                        style: TextStyle(
                          color: AppColors().appNavyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: AppColors().appNavyColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: AppColors().appNavyColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          color: AppColors().appNavyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors().appNavyColor,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: AppColors().appNavyColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: AppColors().appNavyColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                        ),
                        obscureText:
                            obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // Password regex: at least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
                          final passwordRegex = RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                          );
                          if (!passwordRegex.hasMatch(value)) {
                            return 'Password must have at least 8 characters, \nuppercase, lowercase, number and special character';
                          }
                          return null;
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot password ?',
                              style: TextStyle(
                                color: AppColors().appNavyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child:
                            isLoading
                                ? CircularProgressIndicator(
                                  color: AppColors().appYellowColor,
                                )
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    fixedSize: Size(
                                      MediaQuery.of(context).size.width * 0.9,
                                      60,
                                    ),
                                    backgroundColor: AppColors().appYellowColor,
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                  ),
                                  onPressed: () async {
                                    await loginUser();
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      ),

                      // Signup Redirect Button
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account ?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign up now',
                                style: TextStyle(
                                  color: AppColors().appNavyColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  loginUser() async {
    if (formkey.currentState!.validate() ) {
      setState(() {
        isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(
            emailController.text,
            passwordController.text,
          )
          .then((value) async {
            if (value == true) {
              // If tutor tries to login
              if (selectedUserType == 'Tutor') {
                QuerySnapshot snapshot = await DatabaseService(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                ).gettingTutorData(emailController.text);
                // If the entered info is not in the database
                if (snapshot.docs.isEmpty) {
                  showSnackbar(
                    context,
                    Colors.red,
                    "Invalid Login Info ! Please enter correct login credentials.",
                  );
                  setState(() {
                    isLoading = false;
                  });
                }

                // If the entered info is available in database
                if (snapshot.docs.isNotEmpty) {
                  await HelperFunctions.saveUserLoggedInStatus(true);
                  await HelperFunctions.saveUserEmailSF(emailController.text);
                  await HelperFunctions.saveUserNameSF(
                    snapshot.docs[0]['fullName'],
                  );
                  await HelperFunctions.saveUserType(
false                  );
                  showSnackbar(context, Colors.green, "Login Successful !");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> TutorDashboardScreen(),),);
                }
              }

              // If student tries to login
              if (selectedUserType == 'Student') {
                QuerySnapshot snapshot = await DatabaseService(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                ).gettingStudentData(emailController.text);
                // If the entered info is not in the database
                if (snapshot.docs.isEmpty) {
                  showSnackbar(
                    context,
                    Colors.red,
                    "Invalid Login Info ! Please enter correct login credentials.",
                  );
                }
                // If the entered info is available in database
                if (snapshot.docs.isNotEmpty) {
                  await HelperFunctions.saveUserLoggedInStatus(true);
                  await HelperFunctions.saveUserEmailSF(emailController.text);
                  await HelperFunctions.saveUserNameSF(
                    snapshot.docs[0]['fullName'],
                  );
                  await HelperFunctions.saveUserType(
true                  );
                  showSnackbar(context, Colors.green, "Login Successful !");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> StudentDashboardScreen(),),);
                }
              }
            } else {
              showSnackbar(context, Colors.red, value);
              setState(() {
                isLoading = false;
              });
            }
          });
    }
  }
}
