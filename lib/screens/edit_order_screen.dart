import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class EditOrderScreen extends StatefulWidget {
  const EditOrderScreen({super.key});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'Pending';
  DateTime _orderDate = DateTime.now();
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrder();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final orderId = ModalRoute.of(context)!.settings.arguments as int;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final order = await databaseService.getOrderById(orderId);
      
      setState(() {
        _customerNameController.text = order['customer_name'];
        _notesController.text = order['notes'] ?? '';
        _status = order['status'];
        _orderDate = DateTime.parse(order['order_date']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _orderDate) {
      setState(() {
        _orderDate = picked;
      });
    }
  }

  Future<void> _updateOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final orderId = ModalRoute.of(context)!.settings.arguments as int;
        final databaseService = Provider.of<DatabaseService>(context, listen: false);
        
        await databaseService.updateOrder(orderId, {
          'customer_name': _customerNameController.text,
          'order_date': _orderDate.toIso8601String(),
          'status': _status,
          'notes': _notesController.text,
        });

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating order: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Order Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_orderDate.year}-${_orderDate.month.toString().padLeft(2, '0')}-${_orderDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Pending', 'Processing', 'Completed', 'Cancelled']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateOrder,
              child: const Text('Update Order'),
            ),
          ],
        ),
      ),
    );
  }
} 