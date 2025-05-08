import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'tabs/bang_keo_tab.dart';
import 'tabs/bang_keo_in_tab.dart';
import 'tabs/truc_in_tab.dart';

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
        order = await db.getBangKeoOrderById(orderId.toString());
      } else if (_loaiDon == 'bang_keo_in') {
        order = await db.getBangKeoInOrderById(orderId.toString());
      } else if (_loaiDon == 'truc_in') {
        order = await db.getTrucInOrderById(orderId.toString());
      } else {
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải đơn hàng: $e')),
          );
        });
      }
    }
  }

  Future<void> _onSaveBangKeo(Map<String, dynamic> data) async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final id = data['id'].toString();
      await db.updateBangKeoOrder(id, data);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi cập nhật đơn hàng: $e')),
          );
        });
      }
    }
  }

  Future<void> _onSaveBangKeoIn(Map<String, dynamic> data) async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      await db.updateBangKeoInOrder(data['id'].toString(), data);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi cập nhật đơn hàng: $e')),
          );
        });
      }
    }
  }

  Future<void> _onSaveTrucIn(Map<String, dynamic> data) async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      await db.updateTrucInOrder(data['id'].toString(), data);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi cập nhật đơn hàng: $e')),
          );
        });
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
    } else if (_loaiDon == 'bang_keo_in') {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa đơn Băng keo in')),
        body: BangKeoInTab(
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
          onSave: _onSaveBangKeoIn,
        ),
      );
    } else if (_loaiDon == 'truc_in') {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa đơn Trục in')),
        body: TrucInTab(
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
          onSave: _onSaveTrucIn,
        ),
      );
    }
    return const Scaffold(
      body: Center(child: Text('Chỉ hỗ trợ chỉnh sửa đơn Băng keo, Băng keo in, Trục in.')), 
    );
  }
}
 