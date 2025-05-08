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
  String? _errorMessage;

  String? _selectedLoaiDon; // null = tất cả
  final List<String> _loaiDonOptions = ['Tất cả', 'Băng keo in', 'Băng keo', 'Trục in'];

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
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading orders: $e';
      });
    }
  }

  List<Map<String, dynamic>> _filterByLoaiDon(List<Map<String, dynamic>> orders) {
    if (_selectedLoaiDon == null) return orders;
    return orders.where((order) => order['loai_don'] == _selectedLoaiDon).toList();
  }

  List<Map<String, dynamic>> _getUpcomingOrders() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    final filtered = _orders.where((order) {
      final ngayDuKien = _parseDate(order['ngay_du_kien']);
      final daGiao = order['da_giao'] == true;
      return !daGiao && ngayDuKien != null && ngayDuKien.isAfter(now.subtract(const Duration(days: 1))) && ngayDuKien.isBefore(sevenDaysLater.add(const Duration(days: 1)));
    }).toList();
    return _filterByLoaiDon(filtered);
  }

  List<Map<String, dynamic>> _getOverdueOrders() {
    final now = DateTime.now();
    final filtered = _orders.where((order) {
      final ngayDuKien = _parseDate(order['ngay_du_kien']);
      final daGiao = order['da_giao'] == true;
      return !daGiao && ngayDuKien != null && ngayDuKien.isBefore(now);
    }).toList();
    return _filterByLoaiDon(filtered);
  }

  List<Map<String, dynamic>> _getUnpaidOrders() {
    final filtered = _orders.where((order) => order['da_tat_toan'] == false).toList();
    return _filterByLoaiDon(filtered);
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
                    'id': order['id'].toString(),
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
                    final id = order['id'].toString();
                    await db.deleteOrderByAnyTable(id);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
        setState(() {
          _errorMessage = null;
        });
      }
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DropdownButton<String>(
            value: _selectedLoaiDon ?? 'Tất cả',
            isExpanded: true,
            items: _loaiDonOptions.map((loai) {
              return DropdownMenuItem<String>(
                value: loai,
                child: Text(loai),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLoaiDon = value == 'Tất cả' ? null : value;
              });
            },
          ),
        ),
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