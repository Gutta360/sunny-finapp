import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Client extends StatefulWidget {
  const Client({super.key});

  @override
  _ClientState createState() => _ClientState();
}

class _ClientState extends State<Client> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<String> _generateCustomerId() async {
    DocumentReference counterDoc = FirebaseFirestore.instance
        .collection('counters')
        .doc('customer_counter');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterDoc);

      if (!snapshot.exists) {
        throw Exception("Counter document does not exist!");
      }

      int currentValue = snapshot.get('value');
      int newValue = currentValue + 1;

      transaction.update(counterDoc, {'value': newValue});

      return 'CUST$newValue';
    });
  }

  Future<bool> _isNameUnique(String name) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('customers')
        .where('name', isEqualTo: name)
        .get();
    return query.docs.isEmpty;
  }

  Future<bool> _isPhoneUnique(String phone) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('customers')
        .where('phone', isEqualTo: phone)
        .get();
    return query.docs.isEmpty;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String phone = _phoneController.text.trim();

      bool isNameUnique = await _isNameUnique(name);
      bool isPhoneUnique = await _isPhoneUnique(phone);

      if (!isNameUnique) {
        _showError("The name already exists.");
        return;
      }
      if (!isPhoneUnique) {
        _showError("The phone number already exists.");
        return;
      }

      try {
        String customerId = await _generateCustomerId();

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .set({
          'name': name,
          'phone': phone,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form Saved Successfully'),
            backgroundColor: Colors.blue,
          ),
        );

        _nameController.clear();
        _phoneController.clear();
      } catch (error) {
        print("Error adding document: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save form'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(120, 40),
                        textStyle: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
          labelText: 'Name', prefixIcon: Icon(Icons.account_circle)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Name should be alphabetic only';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
          labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }
}
