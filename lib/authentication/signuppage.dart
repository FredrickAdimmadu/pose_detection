import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../gainz_ai/workout_screen.dart';
import 'loginpage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController
  _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;


  // Moved _signUp method outside of build
  Future<void> _signUp() async {
  setState(() {
  _isLoading = true;
  });

  try {
  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  email: _emailController.text.trim(),

  password: _passwordController.text.trim(),

  );

  // Save user details to Firestore
  await _firestore.collection('workout_users').doc(userCredential.user!.uid).set({
  'name': _nameController.text.trim(),
  'email': _emailController.text.trim(),
  'id': userCredential.user!.uid,
  });

  // Navigate to WorkoutScreen after successful sign up
  Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => WorkoutScreen()),
  );
  } on FirebaseAuthException catch (e) {
  setState(() {
  _errorMessage = _getErrorMessage(e);
  });
  } catch (e) {
  setState(() {
  _errorMessage = 'An unexpected error occurred. Please try again.';
  });
  } finally {
  setState(() {
  _isLoading = false;
  });
  }
  }

  String _getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
  case 'email-already-in-use':
  return 'The email address is already in use.';
  case 'weak-password':
  return 'The password provided is too weak.';
  default:
  return 'An error occurred. Please try again.';
  }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 7) {
                      return 'Password must be at least 7 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.0),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _signUp();
                    }
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Sign Up'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
