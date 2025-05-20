import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  dynamic _orderId;
  String? _loaiDon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _orderId = args['id'];
      _loaiDon = args['loai_don'];
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final order = await db.getOrderByAnyTable(_orderId.toString());
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading order: $e')),
      );
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      final dt = value is DateTime ? value : DateTime.parse(value.toString());
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return value.toString();
    }
  }

  String _getOrderTypeForEdit() {
    if (_loaiDon == 'Băng keo in') return 'bang_keo_in';
    if (_loaiDon == 'Trục in') return 'truc_in';
    if (_loaiDon == 'Băng keo') return 'bang_keo';
    return '';
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_order == null || _order!.isEmpty)
              ? const Center(child: Text('Không tìm thấy đơn hàng.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt_long, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text('Mã đơn: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order!['id'] ?? '', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_order!['ten_hang'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.label, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    const Text('Tên đơn hàng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_order!['ten_hang'] ?? '', style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              if (_order!['ten_khach_hang'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    const Text('Khách hàng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_order!['ten_khach_hang'] ?? '', style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              if (_order!['thoi_gian'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      const Text('Ngày đặt: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(_formatDate(_order!['thoi_gian']), style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              if (_order!['ngay_du_kien'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      const Text('Ngày dự kiến: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(_formatDate(_order!['ngay_du_kien']), style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              if (_order!['trang_thai'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(_order!['trang_thai'] ?? '', style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              if (_order!['ghi_chu'] != null && _order!['ghi_chu'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.notes, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      const Text('Ghi chú: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Expanded(child: Text(_order!['ghi_chu'], style: const TextStyle(fontSize: 16))),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_shipping, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    const Text('Trạng thái giao hàng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      _order!['da_giao'] == true ? 'Đã giao' : 'Chưa giao',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _order!['da_giao'] == true ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.payment, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    const Text('Trạng thái thanh toán: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      _order!['da_tat_toan'] == true ? 'Đã tất toán' : 'Chưa tất toán',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _order!['da_tat_toan'] == true ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 400;
                          if (isNarrow) {
                            return Column(
                              children: [
                                _buildActionButton(context, 'Chỉnh sửa', Colors.orange, () {
                                  String loaiDon = '';
                                  final id = _order!['id']?.toString() ?? '';
                                  if (id.startsWith('BK')) {
                                    loaiDon = 'bang_keo_in';
                                  } else if (id.startsWith('TI')) {
                                    loaiDon = 'truc_in';
                                  } else if (id.startsWith('B')) {
                                    loaiDon = 'bang_keo';
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    '/edit_order',
                                    arguments: {
                                      'id': id,
                                      'loai_don': loaiDon,
                                    },
                                  );
                                }),
                                const SizedBox(height: 12),
                                _buildActionButton(context, _order!['da_giao'] == true ? 'CHƯA GIAO HÀNG' : 'ĐÃ GIAO HÀNG',
                                  _order!['da_giao'] == true ? Colors.red : Colors.green, () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: Row(
                                          children: [
                                            Icon(_order!['da_giao'] == true ? Icons.undo : Icons.local_shipping, color: _order!['da_giao'] == true ? Colors.red : Colors.green, size: 32),
                                            const SizedBox(width: 12),
                                            Text(_order!['da_giao'] == true ? 'Xác nhận hoàn tác giao hàng' : 'Xác nhận giao hàng'),
                                          ],
                                        ),
                                        content: Text(_order!['da_giao'] == true ? 'Bạn có chắc muốn chuyển về CHƯA GIAO HÀNG?' : 'Bạn có chắc muốn chuyển sang ĐÃ GIAO HÀNG?'),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[700],
                                              textStyle: const TextStyle(fontSize: 18),
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _order!['da_giao'] == true ? Colors.red : Colors.green,
                                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Xác nhận'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                    final db = Provider.of<DatabaseService>(context, listen: false);
                                    final loaiDon = _order?['loai_don'];
                                    try {
                                      if (loaiDon == 'Băng keo in') {
                                        await db.updateBangKeoInOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                      } else if (loaiDon == 'Trục in') {
                                        await db.updateTrucInOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                      } else if (loaiDon == 'Băng keo') {
                                        await db.updateBangKeoOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                      }
                                      await _loadOrder();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Cập nhật trạng thái giao hàng thành công!')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
                                      );
                                    }
                                  }),
                                const SizedBox(height: 12),
                                _buildActionButton(context, _order!['da_tat_toan'] == true ? 'CHƯA TẤT TOÁN' : 'ĐÃ TẤT TOÁN',
                                  _order!['da_tat_toan'] == true ? Colors.red : Colors.green, () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: Row(
                                          children: [
                                            Icon(_order!['da_tat_toan'] == true ? Icons.undo : Icons.payment, color: _order!['da_tat_toan'] == true ? Colors.red : Colors.green, size: 32),
                                            const SizedBox(width: 12),
                                            Text(_order!['da_tat_toan'] == true ? 'Xác nhận hoàn tác tất toán' : 'Xác nhận tất toán'),
                                          ],
                                        ),
                                        content: Text(_order!['da_tat_toan'] == true ? 'Bạn có chắc muốn chuyển về CHƯA TẤT TOÁN?' : 'Bạn có chắc muốn chuyển sang ĐÃ TẤT TOÁN?'),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[700],
                                              textStyle: const TextStyle(fontSize: 18),
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _order!['da_tat_toan'] == true ? Colors.red : Colors.green,
                                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Xác nhận'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                    final db = Provider.of<DatabaseService>(context, listen: false);
                                    final loaiDon = _order?['loai_don'];
                                    try {
                                      if (loaiDon == 'Băng keo in') {
                                        await db.updateBangKeoInOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                        if (!(_order!['da_tat_toan'] == true)) {
                                          await db.updateBangKeoInOrderStatus(_orderId.toString(), daTatToan: true);
                                          _order!['cong_no_khach'] = 0;
                                        }
                                      } else if (loaiDon == 'Trục in') {
                                        await db.updateTrucInOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                        if (!(_order!['da_tat_toan'] == true)) {
                                          await db.updateTrucInOrderStatus(_orderId.toString(), daTatToan: true);
                                          _order!['cong_no_khach'] = 0;
                                        }
                                      } else if (loaiDon == 'Băng keo') {
                                        await db.updateBangKeoOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                        if (!(_order!['da_tat_toan'] == true)) {
                                          await db.updateBangKeoOrderStatus(_orderId.toString(), daTatToan: true);
                                          _order!['cong_no_khach'] = 0;
                                        }
                                      }
                                      await _loadOrder();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Cập nhật trạng thái thanh toán thành công!')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
                                      );
                                    }
                                  }),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(context, 'Chỉnh sửa', Colors.orange, () {
                                    String loaiDon = '';
                                    final id = _order!['id']?.toString() ?? '';
                                    if (id.startsWith('BK')) {
                                      loaiDon = 'bang_keo_in';
                                    } else if (id.startsWith('TI')) {
                                      loaiDon = 'truc_in';
                                    } else if (id.startsWith('B')) {
                                      loaiDon = 'bang_keo';
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      '/edit_order',
                                      arguments: {
                                        'id': id,
                                        'loai_don': loaiDon,
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionButton(context, _order!['da_giao'] == true ? 'CHƯA GIAO HÀNG' : 'ĐÃ GIAO HÀNG',
                                    _order!['da_giao'] == true ? Colors.red : Colors.green, () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: [
                                              Icon(_order!['da_giao'] == true ? Icons.undo : Icons.local_shipping, color: _order!['da_giao'] == true ? Colors.red : Colors.green, size: 32),
                                              const SizedBox(width: 12),
                                              Text(_order!['da_giao'] == true ? 'Xác nhận hoàn tác giao hàng' : 'Xác nhận giao hàng'),
                                            ],
                                          ),
                                          content: Text(_order!['da_giao'] == true ? 'Bạn có chắc muốn chuyển về CHƯA GIAO HÀNG?' : 'Bạn có chắc muốn chuyển sang ĐÃ GIAO HÀNG?'),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.grey[700],
                                                textStyle: const TextStyle(fontSize: 18),
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Hủy'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _order!['da_giao'] == true ? Colors.red : Colors.green,
                                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Xác nhận'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      final db = Provider.of<DatabaseService>(context, listen: false);
                                      final loaiDon = _order?['loai_don'];
                                      try {
                                        if (loaiDon == 'Băng keo in') {
                                          await db.updateBangKeoInOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                        } else if (loaiDon == 'Trục in') {
                                          await db.updateTrucInOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                        } else if (loaiDon == 'Băng keo') {
                                          await db.updateBangKeoOrderStatus(_orderId.toString(), daGiao: !(_order!['da_giao'] == true));
                                        }
                                        await _loadOrder();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Cập nhật trạng thái giao hàng thành công!')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
                                        );
                                      }
                                    }),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionButton(context, _order!['da_tat_toan'] == true ? 'CHƯA TẤT TOÁN' : 'ĐÃ TẤT TOÁN',
                                    _order!['da_tat_toan'] == true ? Colors.red : Colors.green, () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: [
                                              Icon(_order!['da_tat_toan'] == true ? Icons.undo : Icons.payment, color: _order!['da_tat_toan'] == true ? Colors.red : Colors.green, size: 32),
                                              const SizedBox(width: 12),
                                              Text(_order!['da_tat_toan'] == true ? 'Xác nhận hoàn tác tất toán' : 'Xác nhận tất toán'),
                                            ],
                                          ),
                                          content: Text(_order!['da_tat_toan'] == true ? 'Bạn có chắc muốn chuyển về CHƯA TẤT TOÁN?' : 'Bạn có chắc muốn chuyển sang ĐÃ TẤT TOÁN?'),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.grey[700],
                                                textStyle: const TextStyle(fontSize: 18),
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Hủy'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _order!['da_tat_toan'] == true ? Colors.red : Colors.green,
                                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Xác nhận'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      final db = Provider.of<DatabaseService>(context, listen: false);
                                      final loaiDon = _order?['loai_don'];
                                      try {
                                        if (loaiDon == 'Băng keo in') {
                                          await db.updateBangKeoInOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                          if (!(_order!['da_tat_toan'] == true)) {
                                            await db.updateBangKeoInOrderStatus(_orderId.toString(), daTatToan: true);
                                            _order!['cong_no_khach'] = 0;
                                          }
                                        } else if (loaiDon == 'Trục in') {
                                          await db.updateTrucInOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                          if (!(_order!['da_tat_toan'] == true)) {
                                            await db.updateTrucInOrderStatus(_orderId.toString(), daTatToan: true);
                                            _order!['cong_no_khach'] = 0;
                                          }
                                        } else if (loaiDon == 'Băng keo') {
                                          await db.updateBangKeoOrderStatus(_orderId.toString(), daTatToan: !(_order!['da_tat_toan'] == true));
                                          if (!(_order!['da_tat_toan'] == true)) {
                                            await db.updateBangKeoOrderStatus(_orderId.toString(), daTatToan: true);
                                            _order!['cong_no_khach'] = 0;
                                          }
                                        }
                                        await _loadOrder();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Cập nhật trạng thái thanh toán thành công!')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
                                        );
                                      }
                                    }),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
} 