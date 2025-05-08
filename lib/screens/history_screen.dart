import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Băng keo'),
              Tab(text: 'Băng keo in'),
              Tab(text: 'Trục in'),
            ],
          ),
          Expanded( 
            child: TabBarView(
              children: [
                HistoryTab(type: 'bang_keo'),
                HistoryTab(type: 'bang_keo_in'),
                HistoryTab(type: 'truc_in'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatefulWidget {
  final String type; // 'bang_keo', 'bang_keo_in', 'truc_in'
  const HistoryTab({super.key, required this.type});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = true;
  String _searchText = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; });
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      List<Map<String, dynamic>> orders = [];
      if (widget.type == 'bang_keo') {
        orders = await db.getBangKeoOrders();
      } else if (widget.type == 'bang_keo_in') {
        orders = await db.getBangKeoInOrders();
      } else if (widget.type == 'truc_in') {
        orders = await db.getTrucInOrders();
      }
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
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

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final name = (order['ten_khach_hang'] ?? '').toString().toLowerCase();
        final search = _searchText.toLowerCase();
        final rawDate = order['ngay_du_kien'];
        DateTime? orderDate;
        if (rawDate is DateTime) {
          orderDate = rawDate;
        } else if (rawDate is String) {
          orderDate = DateTime.tryParse(rawDate);
        }
        final dateMatch = (_startDate == null && _endDate == null) ||
          (orderDate != null &&
            (_startDate == null || !orderDate.isBefore(_startDate!)) &&
            (_endDate == null || !orderDate.isAfter(_endDate!)));
        return name.contains(search) && dateMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tìm theo tên khách hàng',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _searchText = value;
                        _filterOrders();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () async {
                      final pickedStart = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        helpText: 'Chọn ngày bắt đầu',
                      );
                      if (pickedStart != null) {
                        final pickedEnd = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? pickedStart,
                          firstDate: pickedStart,
                          lastDate: DateTime(2100),
                          helpText: 'Chọn ngày kết thúc',
                        );
                        setState(() {
                          _startDate = pickedStart;
                          _endDate = pickedEnd;
                        });
                        _filterOrders();
                      }
                    },
                  ),
                  if (_startDate != null || _endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _filterOrders();
                      },
                    ),
                ],
              ),
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Từ: ${_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : '...'} '
                    'đến: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : '...'}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredOrders.isEmpty
                  ? const Center(child: Text('Không có đơn hàng nào'))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text('Tên Hàng: ${order['ten_hang'] ?? ''}'),
                              subtitle: Builder(
                                builder: (context) {
                                  final rawDate = order['ngay_du_kien'];
                                  String ngayDuKien = '';
                                  if (rawDate is DateTime) {
                                    ngayDuKien = DateFormat('dd/MM/yyyy').format(rawDate);
                                  } else if (rawDate is String) {
                                    final parsed = DateTime.tryParse(rawDate);
                                    if (parsed != null) {
                                      ngayDuKien = DateFormat('dd/MM/yyyy').format(parsed);
                                    }
                                  }
                                  return Text(
                                    'Người đặt: ${order['ten_khach_hang'] ?? ''}\n'
                                    'Ngày dự kiến giao: $ngayDuKien\n'
                                    'Công nợ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(order['cong_no_khach'] ?? 0)}',
                                  );
                                },
                              ),
                              onTap: () {
                                final id = order['id']?.toString() ?? '';
                                String loaiDon = '';
                                if (id.startsWith('BK')) {
                                  loaiDon = 'bang_keo_in';
                                } else if (id.startsWith('TI')) {
                                  loaiDon = 'truc_in';
                                } else if (id.startsWith('B')) {
                                  loaiDon = 'bang_keo';
                                }
                                Navigator.pushNamed(
                                  context,
                                  '/order_detail',
                                  arguments: {
                                    'id': id,
                                    'loai_don': loaiDon,
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
                    ),
        ),
      ],
    );
  }
} 