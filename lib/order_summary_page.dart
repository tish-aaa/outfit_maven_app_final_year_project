import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class OrderSummaryPage extends StatefulWidget {
  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  void _simulatePayment(double totalAmount, UserProvider userProvider) {
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart is empty. Add items before proceeding.")),
      );
      return;
    }

    // Simulate Payment Delay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Processing Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Please wait while we process your payment..."),
          ],
        ),
      ),
    );

    // Simulating successful payment after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      _handlePaymentSuccess(userProvider);
    });
  }

  void _handlePaymentSuccess(UserProvider userProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful! Order Placed.")),
    );

    // Store order details in Firestore
    userProvider.storeOrder();

    // Navigate to success page (or homepage)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final List<Map<String, dynamic>> cartItems = userProvider.cartItems; // Ensure it's a list of maps

    final double totalAmount = cartItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] as num?) ?? 0.0), // Explicitly cast to num
    );

    return Scaffold(
      appBar: AppBar(title: Text('Order Summary')),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text("Your cart is empty."))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: item['imageUrl'] != null
                            ? Image.network(
                                item['imageUrl'],
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported),
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text(item['name'] ?? 'Unnamed Item'),
                        subtitle: Text('₹${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: ₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _simulatePayment(totalAmount, userProvider),
                  child: Text('Proceed to Payment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
