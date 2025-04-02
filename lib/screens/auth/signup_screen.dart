// ignore_for_file: use_build_context_synchronously

import 'package:fee_app/screens/auth/login_screen.dart';
import 'package:fee_app/screens/student/dashboard_screen.dart';
import 'package:fee_app/screens/tutor/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../config/utils.dart';
import '../../services/auth_service.dart';
import '../../services/helper_service.dart';
import '../../widgets/logo_container.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formkey = GlobalKey<FormState>();
  var userType = ['Tutor', 'Student'];

  String? selectedUserType;
  bool obscureText = true;
  bool isLoading = false;
  final AuthService authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
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

                      // Name Field
                      Text(
                        'Full Name',
                        style: TextStyle(
                          color: AppColors().appNavyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
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
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
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
                          // Email regex pattern
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
                            obscureText, // This requires a boolean variable in your state
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
                                    await registerUser();
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      ),

                      // Login Redirect
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account ?',
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
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign in now',
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

  registerUser() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .registerUserWithEmailandPassword(
            nameController.text,
            emailController.text,
            passwordController.text,
            selectedUserType.toString(),
          )
          .then((value) async {
            if (value == true) {
              // saving the shared preference state
              await HelperFunctions.saveUserLoggedInStatus(true);
              await HelperFunctions.saveUserEmailSF(emailController.text);
              await HelperFunctions.saveUserNameSF(nameController.text);
              if (selectedUserType == "Student") {
                              await HelperFunctions.saveUserType(true);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDashboardScreen(),
                  ),
                );
              }
              if (selectedUserType == "Tutor") {
                  await HelperFunctions.saveUserType(false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorDashboardScreen(),
                  ),
                );
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
