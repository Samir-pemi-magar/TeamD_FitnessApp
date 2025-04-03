import 'package:flutter/material.dart';

class UserSignup extends StatelessWidget {
  const UserSignup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen
                    },
                  ),
                ),
                // Circular Logo
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 20),
                // Welcome Text
                const Text(
                  'Welcome to ZenFit -\nwhere fitness meets balance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Input Fields
                _buildTextField('Enter name...'),
                const SizedBox(height: 10),
                _buildTextField('Enter email...'),
                const SizedBox(height: 10),
                _buildTextField('Enter password...', obscureText: true),
                const SizedBox(height: 10),
                _buildTextField('Enter number...'),
                const SizedBox(height: 20),
                // Create Button
                ElevatedButton(
                  onPressed: () {
                    // Add signup functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor:const Color.fromARGB(255, 128, 202, 138), // Button color
                  ),
                  child: const Text('Create', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  Widget _buildTextField(String hintText, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
