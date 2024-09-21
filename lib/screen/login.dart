import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/screen/bottombar.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool isLoading = false;
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    name.dispose();
    password.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void logIn_method() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return Bottombar();
      }));
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: h * 0.1,
                ),
                Text("Insta app",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(
                  height: h * 0.05,
                ),
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@'))
                              return 'please inter valid Email';
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: password,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7)
                              return 'please inter valid password';
                          },
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.visibility_off),
                            hintText: 'password',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: h * 0.05,
                ),
                SizedBox(
                    height: h * 0.05,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            logIn_method();
                          }
                        },
                        child: isLoading == true
                            ? CircularProgressIndicator()
                            : Text('Log In'))),
                TextButton(
                  onPressed: () {},
                  child: Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
