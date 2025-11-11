import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart';

class PaymentScreen extends StatefulWidget {
  final EventModel event;
  final UserModel user;

  const PaymentScreen({
    Key? key,
    required this.event,
    required this.user,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Credit/Debit Card';
  bool _isProcessing = false;

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  void _processPayment() async {
    if (_selectedMethod == 'Credit/Debit Card') {
      if (cardNumberController.text.isEmpty ||
          expiryController.text.isEmpty ||
          cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all card details')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() => _isProcessing = false);

    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Gateway')),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event Info ---
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(widget.event.description),
            SizedBox(height: 16),
            Text(
              'Total Amount: RM ${widget.event.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // --- Payment Method Selection ---
            Text(
              'Select Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            _buildPaymentOption('Credit/Debit Card', Icons.credit_card),
            _buildPaymentOption('Online Banking', Icons.account_balance),
            _buildPaymentOption('E-Wallet', Icons.phone_iphone),

            // --- Conditional Card Details ---
            if (_selectedMethod == 'Credit/Debit Card') ...[
              SizedBox(height: 20),
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 40),

            // --- Pay Button ---
            Center(
              child: _isProcessing
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(Icons.lock_open),
                label: Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: _isProcessing ? null : _processPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for Payment Option ---
  Widget _buildPaymentOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Radio<String>(
        value: title,
        groupValue: _selectedMethod,
        onChanged: (value) {
          setState(() {
            _selectedMethod = value!;
          });
        },
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  final EventModel event;

  const PaymentSuccessScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 90),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You have successfully registered for "${event.name}".',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
