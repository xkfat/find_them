import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all((16),
        child: Column(children: [
          const SizedBox(height: 40), 
          Image.asset('assets/images/logo.png', height:100),
          Text('FindThem', style: Theme.of(context).textTheme.headlineMedium),
          
          const SizedBox(height: 40),

          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username", 
                  prefixIcon: Icon(PhosphorIcons.user,size: 30,),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;

                  },
                ),
                const SizedBox(height: 16,),
                TextFormField(controller: _passwordController, 
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(
  PhosphorIcons.lockKey,
  size: 30.0,
),
obscureText: true, 
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  return null;
},

),
const SizedBox(height: 24,),
SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
  if (_formKey.currentState!.validate()) {
    ///logic apres
  }
},
 child: const Text ('Login'), 
 ) ,
 ),
 const SizedBox(height: 16),
 Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Don't have an account?"), 
    TextButton( 
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      }
      child: const Text('Sign up'),
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
    );
  }
}