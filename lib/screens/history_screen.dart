import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final orders = await databaseService.getOrders();
      
      setState(() {
        _orders = orders.where((order) => order['status'] == 'Completed').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'No completed orders found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(order['customer_name']),
              subtitle: Text(
                'Date: ${order['order_date'].toString().split('T')[0]}\n'
                'Notes: ${order['notes'] ?? 'No notes'}',
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/order-detail',
                  arguments: order['id'],
                );
              },
            ),
          );
        },
      ),
    );
  }
} 