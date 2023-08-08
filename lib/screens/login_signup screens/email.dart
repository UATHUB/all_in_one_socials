import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:all_in_one_socials/controllers/email_checker.dart';
import 'package:all_in_one_socials/controllers/page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

EmailChecker ec = Get.put(EmailChecker());
ColorPalette cp = Get.put(ColorPalette());
PagesController pc = Get.put(PagesController());
TextEditingController _textEditingController = TextEditingController();

class _EmailScreenState extends State<EmailScreen> {
  final formkey = GlobalKey<FormState>();
  bool loading = false;
  String _enteredEmail = '';

  void _submit() async {
    final bool isValid = formkey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formkey.currentState!.save();

    try {
      setState(() {
        loading = true;
      });
      ec.email = _enteredEmail;
      ec.list.clear();
      ec.list = await _firebase.fetchSignInMethodsForEmail(_enteredEmail);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')));
    }
    setState(() {
      loading = false;
    });
    if (ec.list.isEmpty) {
      pc.changePage(2);
    } else {
      pc.changePage(1);
    }
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
                        controller: _textEditingController,
                        style: const TextStyle().copyWith(color: cp.text),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_rounded),
                            labelStyle:
                                const TextStyle().copyWith(color: cp.container),
                            labelText: 'Enter Your Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  loading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: _submit,
                          icon: Icon(
                            Icons.arrow_circle_right_rounded,
                            color: cp.container,
                            size: 40,
                          ),
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
