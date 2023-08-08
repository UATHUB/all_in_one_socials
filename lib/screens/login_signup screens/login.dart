import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/controllers/page_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

EmailChecker ec = Get.put(EmailChecker());
ColorPalette cp = Get.put(ColorPalette());
PagesController pc = Get.put(PagesController());

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    bool loading = false;
    String password = '';

    void submit() async {
      final bool isValid = formkey.currentState!.validate();

      if (!isValid) {
        return;
      }

      formkey.currentState!.save();

      try {
        setState(() {
          loading = true;
        });

        await _firebase.signInWithEmailAndPassword(
            email: ec.email, password: password);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Authentication failed.')));
      }
      setState(() {
        loading = false;
      });
      pc.exitLogin();
    }

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
            child: GlassmorphicContainer(
              width: 300,
              height: 150,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
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
                      child: TextFormField(
                        style: const TextStyle().copyWith(color: cp.text),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelStyle:
                                const TextStyle().copyWith(color: cp.container),
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
                          password = value!;
                        },
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
                              onPressed: submit,
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
          ),
        ),
      ),
    );
  }
}
