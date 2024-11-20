import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TxnForm extends StatefulWidget {
  const TxnForm({super.key});

  @override
  _TxnFormState createState() => _TxnFormState();
}

class _TxnFormState extends State<TxnForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedName;
  String? _billNo;
  double? _amount;
  DateTime? _selectedDate;
  String? _selectedType;

  List<String> nameOptions = []; // Empty initially
  final List<String> typeOptions = ['CREDIT', 'ANAMATH'];

  final TextEditingController _dateController = TextEditingController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    fetchNameOptions();
  }

  Future<void> fetchNameOptions() async {
    try {
      // Fetch data from Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      // Extract and concatenate 'surname' and 'name' fields
      List<String> fetchedNames = querySnapshot.docs.map((doc) {
        String surname = doc['surname'] ?? '';
        String name = doc['name'] ?? '';
        return '$surname $name';
      }).toList();

      setState(() {
        nameOptions = fetchedNames;
      });
    } catch (e) {
      print('Error fetching names: $e');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
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
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 6.0,
                    ),
                    children: [
                      _buildDropdownField(
                        label: 'Name',
                        value: _selectedName,
                        items: nameOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedName = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      _buildDropdownField(
                        label: 'Type',
                        value: _selectedType,
                        items: typeOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Type is required'
                            : null,
                      ),
                      _buildTextField(
                        label: 'Bill No',
                        onChanged: (value) {
                          _billNo = value;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Bill No is required'
                            : null,
                      ),
                      _buildTextField(
                        label: 'Amount',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          _amount = double.tryParse(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          double? amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount greater than 0';
                          }
                          return null;
                        },
                      ),
                      _buildDatePickerField()
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Transaction saved Successfully')),
                        );
                      }
                    },
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType? keyboardType,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dateController.text = dateFormat.format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(labelText: 'Date'),
          validator: (value) =>
              value == null || value.isEmpty ? 'Date is required' : null,
        ),
      ),
    );
  }
}
