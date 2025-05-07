import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final orders = await db.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _getUpcomingOrders() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return _orders.where((order) {
      final ngayDuKien = _parseDate(order['ngay_du_kien']);
      final daGiao = order['da_giao'] == true;
      return !daGiao && ngayDuKien != null && ngayDuKien.isAfter(now.subtract(const Duration(days: 1))) && ngayDuKien.isBefore(sevenDaysLater.add(const Duration(days: 1)));
    }).toList();
  }

  List<Map<String, dynamic>> _getOverdueOrders() {
    final now = DateTime.now();
    return _orders.where((order) {
      final ngayDuKien = _parseDate(order['ngay_du_kien']);
      final daGiao = order['da_giao'] == true;
      return !daGiao && ngayDuKien != null && ngayDuKien.isBefore(now);
    }).toList();
  }

  List<Map<String, dynamic>> _getUnpaidOrders() {
    return _orders.where((order) => order['da_tat_toan'] == false).toList();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào'));
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Mã đơn: ${order['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order['ten_hang'] != null && order['ten_hang'].toString().isNotEmpty)
                    Text('Tên hàng: 	${order['ten_hang']}'),
                  Text('Loại đơn: ${order['loai_don'] ?? ''}'),
                  if (order['ten_khach_hang'] != null)
                    Text('Khách: ${order['ten_khach_hang']}'),
                  if (order['ngay_du_kien'] != null)
                    Text('Ngày dự kiến: ${_parseDate(order['ngay_du_kien']) != null ? DateFormat('yyyy-MM-dd').format(_parseDate(order['ngay_du_kien'])!) : order['ngay_du_kien']}'),
                  if (order['trang_thai'] != null)
                    Text('Trạng thái: ${order['trang_thai']}'),
                  if (order['ghi_chu'] != null && order['ghi_chu'].toString().isNotEmpty)
                    Text('Ghi chú: ${order['ghi_chu']}'),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/order_detail',
                  arguments: {
                    'id': order['id'],
                    'loai_don': order['loai_don'],
                  },
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text('Bạn có chắc muốn xóa đơn hàng này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final db = Provider.of<DatabaseService>(context, listen: false);
                    final loaiDon = order['loai_don']?.toString() ?? '';
                    final id = order['id'].toString();
                    if (loaiDon == 'Băng keo in') {
                      await db.deleteBangKeoInOrder(id);
                    } else if (loaiDon == 'Trục in') {
                      await db.deleteTrucInOrder(id);
                    } else if (loaiDon == 'Băng keo') {
                      await db.deleteBangKeoOrder(id);
                    } else {
                      await db.deleteOrder(int.parse(id)); // fallback cho bảng don_hang cũ
                    }
                    _loadOrders();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sắp đến hạn'),
            Tab(text: 'Quá hạn'),
            Tab(text: 'Chưa tất toán'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(_getUpcomingOrders()),
              _buildOrderList(_getOverdueOrders()),
              _buildOrderList(_getUnpaidOrders()),
            ],
          ),
        ),
      ],
    );
  }
} 