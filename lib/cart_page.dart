import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'address_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final cartItems = userProvider.cartDetails.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.network(item['imageUrl'],
                            width: 50, height: 50),
                        title: Text(item['name']),
                        subtitle: Text('\$${item['price'].toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () =>
                              userProvider.removeFromCart(item['id']),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (cartItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddressPage()),
                        );
                      }
                    },
                    child: Text('Proceed to Address'),
                  ),
                ),
              ],
            ),
    );
  }
}
