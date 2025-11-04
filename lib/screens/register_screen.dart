import 'package:flutter/material.dart';
import '../models/event.dart';

class RegisterScreen extends StatelessWidget {
  final EventModel event;

  const RegisterScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register for ${event.name}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event Icon + Details (Name, Description, Price) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event, color: Colors.blue, size: 56),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Price: RM ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // --- Register Button ---
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showRegistrationForm(context);
                  },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text('Register Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- Registration Form Dialog ---
  void _showRegistrationForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Register for ${event.name}'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value == null || !value.contains('@') || !value.contains('.') ? 'Enter a valid email' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your phone number';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Phone number must contain only digits';
                      }
                      return null;
                    }
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Successfully registered for ${event.name}!'),
                    ),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}