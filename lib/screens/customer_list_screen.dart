import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khách hàng'),
      ),
      body: Consumer<DatabaseService>(
        builder: (context, dbService, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: dbService.getAllUniqueCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final customers = snapshot.data ?? [];
              if (customers.isEmpty) {
                return const Center(child: Text('Chưa có khách hàng nào'));
              }
              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        customer['ten_khach_hang']?.toString() ?? 'Không có tên',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số đơn hàng: ${customer['so_don_hang'] ?? 0}'),
                          Text('Tổng tiền: ${currencyFormat.format(customer['tong_tien'] ?? 0)}'),
                          if ((customer['don_chua_thanh_toan'] ?? 0) > 0)
                            Text(
                              'Đơn chưa thanh toán: ${customer['don_chua_thanh_toan']}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (customer['don_hang'] as List?)?.length ?? 0,
                          itemBuilder: (context, orderIndex) {
                            final order = (customer['don_hang'] as List)[orderIndex];
                            final orderTotal = order['tong_tien'] ?? order['thanh_tien_ban'] ?? order['thanh_tien'] ?? order['thanh_tien_goc'];
                            return ListTile(
                              title: Text('Mã đơn: ${order['id']?.toString() ?? 'N/A'}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Loại đơn: ${order['loai_don']?.toString() ?? 'N/A'}'),
                                  if (order['ngay_dat'] != null)
                                    Text('Ngày đặt: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order['ngay_dat'].toString()))}'),
                                  Text('Tổng tiền: ${currencyFormat.format(double.tryParse(orderTotal?.toString() ?? '0') ?? 0)}'),
                                  if (order['da_tat_toan'] != true)
                                    const Text(
                                      'Chưa thanh toán',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/order_detail',
                                  arguments: {
                                    'id': order['id']?.toString() ?? '',
                                    'loai_don': order['loai_don']?.toString() ?? '',
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add customer screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 