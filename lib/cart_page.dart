import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'address_page.dart';
import 'navigation/back_navigation_handler.dart'; 

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return BackNavigationHandler(
        child: Scaffold(
          appBar: AppBar(
              title: Text('My Cart', style: TextStyle(color: Colors.white))),
          body: Center(
              child: Text('Please log in to view your cart',
                  style: TextStyle(fontSize: 16))),
        ),
      );
    }

    return BackNavigationHandler(
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Cart', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1DCFCA),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 2,
        ),
        body: StreamBuilder(
          stream: _firestore
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DCFCA)));
            }

            final cartItems = snapshot.data!.docs;

            if (cartItems.isEmpty) {
              return Center(
                  child: Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      var data = item.data() as Map<String, dynamic>?;

                      if (data == null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text("Invalid item - missing data",
                              style: TextStyle(color: Colors.red)),
                        );
                      }

                      return Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: data['imageUrl'] != null
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image_not_supported,
                                            color: Colors.grey[600]),
                                      ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['description'] ?? 'Unknown Outfit',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Price: ₹${data['price'] ?? 'N/A'}",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove,
                                              color: Color(0xFF1DCFCA)),
                                          onPressed: () => updateCartItem(
                                              user.uid, item.id, false),
                                        ),
                                        Text(
                                          (data['quantity'] ?? 1).toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              color: Color(0xFF1DCFCA)),
                                          onPressed: () => updateCartItem(
                                              user.uid, item.id, true),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddressPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1DCFCA),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: Text('Proceed to Checkout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void updateCartItem(String userId, String itemId, bool isIncrement) {
    DocumentReference cartItemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(cartItemRef);
      if (!snapshot.exists) return;

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('quantity')) return;

      int newQuantity = (data['quantity'] as int) + (isIncrement ? 1 : -1);
      if (newQuantity > 0) {
        transaction.update(cartItemRef, {'quantity': newQuantity});
      } else {
        transaction.delete(cartItemRef); // Remove item if quantity is 0
      }
    });
  }
}
