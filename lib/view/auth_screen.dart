import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/widgets/text_input_field.dart';
import 'package:simple_chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController emailTextEditingController;
  late final TextEditingController passwordTextEditingController;
  late final TextEditingController usernameTextEditingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? pickedImage;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    emailTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
    usernameTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    usernameTextEditingController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        (!_isLogin && pickedImage == null)) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim());
        debugPrint("Login UserCredentials $userCredentials");
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim());

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child("${userCredentials.user!.uid}.jpg");
        await storageRef.putFile(pickedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "username": usernameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "image_url": imageUrl,
        });
        debugPrint("Image Url $imageUrl");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        //.. show error message
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Authentication failed.")));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickImage: (image) {
                                  pickedImage = image;
                                },
                              ),
                            TextInputField(
                              controller: emailTextEditingController,
                              labelText: "Email Address",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains("@")) {
                                  return "Please enter a valid email address.";
                                }
                                return null;
                              },
                            ),
                            TextInputField(
                              controller: usernameTextEditingController,
                              labelText: "username",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter username.";
                                }
                                return null;
                              },
                            ),
                            TextInputField(
                              controller: passwordTextEditingController,
                              labelText: "Password",
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return "Password must be a least 6 characters long.";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child: Text(_isLogin ? "Login" : "Signup"),
                                  ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? "Create an account"
                                  : "I already have an account."),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
