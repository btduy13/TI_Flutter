import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'tabs/bang_keo_tab.dart';

class EditOrderScreen extends StatefulWidget {
  const EditOrderScreen({super.key});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;
  String? _loaiDon;
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final orderId = args['id'];
    _loaiDon = args['loai_don'];
    setState(() { _isLoading = true; });
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      Map<String, dynamic>? order;
      if (_loaiDon == 'bang_keo') {
        order = await db.getBangKeoOrderById(orderId);
      } else {
        // TODO: support other types
        order = null;
      }
      DateTime? ngayDuKien;
      if (order != null && order['ngay_du_kien'] != null) {
        final raw = order['ngay_du_kien'];
        if (raw is DateTime) {
          ngayDuKien = raw;
        } else if (raw is String) {
          ngayDuKien = DateTime.tryParse(raw);
        }
      }
      setState(() {
        _orderData = order;
        _selectedDate = ngayDuKien;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải đơn hàng: $e')),
        );
      }
    }
  }

  Future<void> _onSaveBangKeo(Map<String, dynamic> data) async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      await db.updateBangKeoOrder(data['id'], data);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật đơn hàng: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _orderData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Only support Băng keo for now
    if (_loaiDon == 'bang_keo') {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa đơn Băng keo')),
        body: BangKeoTab(
          selectedDate: _selectedDate,
          onDateSelect: (ctx) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() { _selectedDate = picked; });
            }
          },
          initialData: _orderData,
          onSave: _onSaveBangKeo,
        ),
      );
    }
    // TODO: support other types
    return const Scaffold(
      body: Center(child: Text('Chỉ hỗ trợ chỉnh sửa đơn Băng keo.')), 
    );
  }
} 