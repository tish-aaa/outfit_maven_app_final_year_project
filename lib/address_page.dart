import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_summary_page.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  List<Map<String, dynamic>> _savedAddresses = [];
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
            'area': data['area'],
            'building': data['building'],
            'city': data['city'],
            'state': data['state'],
          };
        }).toList();
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
        'area': _areaController.text,
        'building': _buildingController.text,
        'city': _cityController.text,
        'state': _stateController.text,
      };

      if (_editingAddressId == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add(addressData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(_editingAddressId)
            .update(addressData);
      }

      _fetchAddresses();
      Navigator.pop(context);
    }
  }

  void _showAddressForm({Map<String, dynamic>? address}) {
    _editingAddressId = address?['id'];
    _nameController.text = address?['name'] ?? '';
    _phoneController.text = address?['phone'] ?? '';
    _pincodeController.text = address?['pincode'] ?? '';
    _areaController.text = address?['area'] ?? '';
    _buildingController.text = address?['building'] ?? '';
    _cityController.text = address?['city'] ?? '';
    _stateController.text = address?['state'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, 'Full Name'),
              _buildTextField(_phoneController, 'Phone Number',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: _validatePhone),
              _buildTextField(_pincodeController, 'Pincode',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: _validatePincode),
              _buildTextField(_areaController, 'Area Name'),
              _buildTextField(_buildingController, 'Building Name'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_stateController, 'State'),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1DCFCA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(_editingAddressId == null
                    ? 'Save Address'
                    : 'Update Address'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.length != 6) {
      return 'Pincode must be exactly 6 digits';
    }
    return null;
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      int? maxLength,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: Colors.white,
          filled: true,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator ?? (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1DCFCA),
        title: Text('Manage Addresses', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                var address = _savedAddresses[index];
                return ListTile(
                  title: Text(address['name']),
                  subtitle: Text(
                      "${address['building']}, ${address['area']}, ${address['city']}, ${address['state']} - ${address['pincode']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFF1DCFCA)),
                    onPressed: () => _showAddressForm(address: address),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Left and Right Margin
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _showAddressForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF70C2BD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Add New Address'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderSummaryPage())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1DCFCA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
