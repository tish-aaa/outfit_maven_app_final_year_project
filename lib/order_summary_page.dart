import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/user_provider.dart';
import 'navigation/back_navigation_handler.dart';
import 'orders_history_page.dart';

class OrderSummaryPage extends StatefulWidget {
  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _startRazorpayPayment(double totalAmount, UserProvider userProvider) {
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart is empty. Add items before proceeding.")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_LXZO1v4DgjDFKy', // Replace with your Razorpay API key
      'amount': (totalAmount * 100).toInt(), // Convert to paise
      'currency': 'INR',
      'name': 'Outfit Maven',
      'description': 'Order Payment',
      'prefill': {
        'contact': '8108118884', // Replace with actual user data
        'email': 'tishaaa.dev@gmail.com'
      },
      'theme': {'color': '#1DCFCA'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful! Order Placed."),
        backgroundColor: Color(0xFF1DCFCA),
      ),
    );

    // Store order details in Firestore
    userProvider.storeOrder();

    // Add a short delay before navigating
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OrdersHistoryPage()),
        (route) => false, // Clears all previous routes
      );
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed. Try Again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final List<Map<String, dynamic>> cartItems = userProvider.cartItems;

    final double totalAmount = cartItems.fold(
      0.0,
      (sum, item) =>
          sum +
          ((item['price'] as num? ?? 0.0) * (item['quantity'] as num? ?? 1)),
    );

    return BackNavigationHandler(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1DCFCA),
          title: Text('Order Summary', style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Text(
                        "Your cart is empty.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(15),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final int quantity = item['quantity'] ?? 1;
                        final double price = item['price'] ?? 0.0;
                        final double subtotal = quantity * price;

                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            leading: item['imageUrl'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imageUrl'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey),
                                    ),
                                  )
                                : Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                            title: Text(
                              item['description'] ?? 'Unnamed Item',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "₹${price.toStringAsFixed(2)} x $quantity"),
                                Text(
                                  "Subtotal: ₹${subtotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.teal[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _startRazorpayPayment(totalAmount, userProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF70C2BD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Proceed to Payment',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
