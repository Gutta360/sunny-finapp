import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Map<String, bool> _proofsCollected = {
    'Cheques': false,
    'Notes': false,
    'Stamps': false,
    'Documents': false,
  };

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the customer with the same name already exists
        QuerySnapshot existingCustomer = await FirebaseFirestore.instance
            .collection('clients')
            .where('name', isEqualTo: _nameController.text)
            .get();

        if (existingCustomer.docs.isNotEmpty) {
          // Show an alert if the customer with the same name already exists
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Customer with this name already exists'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Collect selected proofs
          List<String> selectedProofs = _proofsCollected.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

          // Save the form data to Firestore if the name doesn't exist
          await FirebaseFirestore.instance.collection('customers').add({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'proofsCollected': selectedProofs,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form Saved Successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the form after saving
          _nameController.clear();
          _phoneController.clear();
          setState(() {
            _proofsCollected.updateAll((key, value) => false);
          });
        }
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
                  const SizedBox(height: 16),
                  _buildProofsCollectedField(),
                  const SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(120, 40),
                        textStyle: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      child: Text('Save'),
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
        } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
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

  Widget _buildProofsCollectedField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proofs Collected',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._proofsCollected.keys.map((proof) {
          return CheckboxListTile(
            title: Text(proof),
            value: _proofsCollected[proof],
            onChanged: (bool? value) {
              setState(() {
                _proofsCollected[proof] = value ?? false;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}
