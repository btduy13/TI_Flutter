import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';
import 'tabs/bang_keo_in_tab.dart';
import 'tabs/bang_keo_tab.dart';
import 'tabs/truc_in_tab.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDate;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm đơn hàng mới'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Băng keo in'),
            Tab(text: 'Băng keo'),
            Tab(text: 'Trục in'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BangKeoInTab(
            selectedDate: _selectedDate,
            onDateSelect: _selectDate,
          ),
          BangKeoTab(
            selectedDate: _selectedDate,
            onDateSelect: _selectDate,
          ),
          TrucInTab(
            selectedDate: _selectedDate,
            onDateSelect: _selectDate,
          ),
        ],
      ),
    );
  }
} 