import 'package:flutter/material.dart';
import 'package:softagi_chat/modules/login/login_screen.dart';
import 'package:softagi_chat/shared/components.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/logo.png'),fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Text(
              'Take privacy with you.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              'Be yourself in every message.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50.0,
            ),
            defaultButton(
              function: () {
                navigateTo(
                  context,
                  LoginScreen(),
                );
              },
              text: 'continue',
            ),
            SizedBox(
              height: 25.0,
            ),
            MaterialButton(
              onPressed: () {},
              child: Text(
                'Terms & Privacy Policy',
                style: size14(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
