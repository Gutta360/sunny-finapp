import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientDetails extends StatefulWidget {
  const ClientDetails({super.key});

  @override
  _ClientDetailsState createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedName;
  List<String> _names = [];
  DocumentSnapshot? _clientData;

  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  Future<void> _fetchNames() async {
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection('customers').get();
      setState(() {
        _names = query.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (error) {
      print("Error fetching names: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch names'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchClientDetails(String name) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('customers')
          .where('name', isEqualTo: name)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _clientData = query.docs.first;
          _selectedName = _clientData!['name'];
          _phoneController.text = _clientData!['phone'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer details not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print("Error fetching client details: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch client details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateClientDetails() async {
    if (_formKey.currentState!.validate() && _clientData != null) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(_clientData!.id)
            .update({
          'phone': _phoneController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client details updated successfully'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (error) {
        print("Error updating client details: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update client details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteClient() async {
    if (_clientData != null) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(_clientData!.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form after deletion
        setState(() {
          _selectedName = null;
          _phoneController.clear();
          _clientData = null;
        });

        _fetchNames(); // Refresh the dropdown options
      } catch (error) {
        print("Error deleting client: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete client'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No client selected to delete'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
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
                  _buildNameDropdown(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updateClientDetails,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text('Update'),
                      ),
                      ElevatedButton(
                        onPressed: _deleteClient,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedName,
      decoration: const InputDecoration(
        labelText: 'Name',
        prefixIcon: Icon(Icons.account_circle),
      ),
      items: _names.map((name) {
        return DropdownMenuItem(
          value: name,
          child: Text(name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedName = value;
        });
        if (value != null) {
          _fetchClientDetails(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a name';
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
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone),
      ),
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
