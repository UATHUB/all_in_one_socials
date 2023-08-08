import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/controllers/page_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebase = FirebaseAuth.instance;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

EmailChecker ec = Get.put(EmailChecker());
ColorPalette cp = Get.put(ColorPalette());
PagesController pc = Get.put(PagesController());

class _SignupScreenState extends State<SignupScreen> {
  final formkey = GlobalKey<FormState>();
  bool loading = false;
  String _firstPassword = '';
  String _secondPassword = '';

  void _submit() async {
    final bool isValid = formkey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formkey.currentState!.save();

    if (_firstPassword != _secondPassword) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'The entered passwords does not match. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.close(1);
                return;
              },
              child: const Text('Ok.'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await _firebase.createUserWithEmailAndPassword(
          email: ec.email, password: _firstPassword);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')));
    }
    setState(() {
      loading = false;
    });
    pc.changePage(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/login_bg.png"), fit: BoxFit.cover),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassmorphicContainer(
                  width: 250,
                  height: 50,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFffffff).withOpacity(0.1),
                        const Color(0xFFFFFFFF).withOpacity(0.12),
                      ],
                      stops: const [
                        0.1,
                        1
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFffffff).withOpacity(0),
                      const Color((0xFFFFFFFF)).withOpacity(0),
                    ],
                  ),
                  child: Text(
                    'Hello Stranger',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.courgette(
                        color: cp.container, fontSize: 25),
                  ),
                ),
                const SizedBox(height: 20),
                GlassmorphicContainer(
                  width: 300,
                  height: 250,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFffffff).withOpacity(0.1),
                        const Color(0xFFFFFFFF).withOpacity(0.12),
                      ],
                      stops: const [
                        0.1,
                        1
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFffffff).withOpacity(0),
                      const Color((0xFFFFFFFF)).withOpacity(0),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 230,
                        child: Form(
                          key: formkey,
                          child: Column(
                            children: [
                              TextFormField(
                                style:
                                    const TextStyle().copyWith(color: cp.text),
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock),
                                    labelStyle: const TextStyle()
                                        .copyWith(color: cp.container),
                                    labelText: 'Enter Your Password'),
                                keyboardType: TextInputType.visiblePassword,
                                autocorrect: false,
                                obscureText: true,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a valid password';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _firstPassword = value!;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                style:
                                    const TextStyle().copyWith(color: cp.text),
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock),
                                    labelStyle: const TextStyle()
                                        .copyWith(color: cp.container),
                                    labelText: 'Enter Your Password Again'),
                                keyboardType: TextInputType.visiblePassword,
                                autocorrect: false,
                                obscureText: true,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a valid password';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _secondPassword = value!;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      loading
                          ? const CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => Get.close(1),
                                  icon: Icon(
                                    Icons.arrow_circle_left_rounded,
                                    size: 40,
                                    color: cp.container,
                                  ),
                                ),
                                const SizedBox(width: 40),
                                IconButton(
                                  onPressed: _submit,
                                  icon: Icon(
                                    Icons.arrow_circle_right_rounded,
                                    color: cp.container,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                    ],
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
