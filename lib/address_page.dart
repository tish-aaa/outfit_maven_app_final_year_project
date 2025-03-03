import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  List<Map<String, dynamic>> _savedAddresses = [];
  String? _defaultAddressId;
  bool _isEditing = false;
  String? _editingAddressId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      final addressesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      setState(() {
        _savedAddresses = addressesSnapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'],
            'phone': data['phone'],
            'pincode': data['pincode'],
            'city': data['city'],
            'state': data['state'],
            'address': data['address'],
            'isDefault': data['isDefault'] ?? false,
          };
        }).toList();
        _defaultAddressId = _savedAddresses.firstWhere((addr) => addr['isDefault'], orElse: () => {})['id'];
      });
    }
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return;

      Map<String, dynamic> addressData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'pincode': _pincodeController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'address': _addressController.text,
        'isDefault': _savedAddresses.isEmpty, // First address is default
      };

      if (_isEditing && _editingAddressId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(_editingAddressId)
            .update(addressData);
      } else {
        DocumentReference addressRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add(addressData);

        if (_savedAddresses.isEmpty) {
          setState(() {
            _defaultAddressId = addressRef.id;
          });
        }
      }
      
      _fetchAddresses();
      Navigator.pop(context);
    }
  }

  void _setDefaultAddress(String addressId) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    
    for (var addr in _savedAddresses) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addr['id'])
          .update({'isDefault': addr['id'] == addressId});
    }
    
    setState(() {
      _defaultAddressId = addressId;
    });
  }

  void _editAddress(Map<String, dynamic> address) {
    setState(() {
      _isEditing = true;
      _editingAddressId = address['id'];
      _nameController.text = address['name'];
      _phoneController.text = address['phone'];
      _pincodeController.text = address['pincode'];
      _cityController.text = address['city'];
      _stateController.text = address['state'];
      _addressController.text = address['address'];
    });
    _showAddressForm();
  }

  void _showAddressForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length == 10 ? null : 'Enter valid phone number',
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.length == 6 ? null : 'Enter valid pincode',
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Full Address'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              ElevatedButton(onPressed: _saveAddress, child: Text(_isEditing ? 'Update Address' : 'Save Address')),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isEditing = false;
        _editingAddressId = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Addresses')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                var address = _savedAddresses[index];
                return ListTile(
                  title: Text(address['name']),
                  subtitle: Text("${address['address']}, ${address['city']}, ${address['state']} - ${address['pincode']}"),
                  trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => _editAddress(address)),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _showAddressForm, child: Text('Add New Address')),
          ElevatedButton(onPressed: () {/* Navigate to OrderSummaryPage */}, child: Text('Next')),
        ],
      ),
    );
  }
}
