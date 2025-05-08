import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await supabase
        .from('don_hang')
        .select()
        .order('ngay_dat', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final response = await supabase
        .from('don_hang')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final response = await supabase
        .from('chi_tiet_don_hang')
        .select()
        .eq('don_hang_id', orderId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String?> createOrder(Map<String, dynamic> order) async {
    final response = await supabase
        .from('don_hang')
        .insert(order)
        .select('id')
        .single();
    return response['id']?.toString();
  }

  Future<void> addOrderItem(String orderId, Map<String, dynamic> item) async {
    await supabase
        .from('chi_tiet_don_hang')
        .insert({...item, 'don_hang_id': orderId});
  }

  Future<void> updateOrder(String id, Map<String, dynamic> order) async {
    await supabase
        .from('don_hang')
        .update(order)
        .eq('id', id);
  }

  Future<void> deleteOrder(String id) async {
    await supabase
        .from('don_hang')
        .delete()
        .eq('id', id);
  }

  Future<void> deleteOrderItem(String itemId) async {
    await supabase
        .from('chi_tiet_don_hang')
        .delete()
        .eq('id', itemId);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getBangKeoInOrders() async {
    final response = await supabase
        .from('bang_keo_in_orders')
        .select()
        .order('thoi_gian', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTrucInOrders() async {
    final response = await supabase
        .from('truc_in_orders')
        .select()
        .order('thoi_gian', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getBangKeoOrders() async {
    final response = await supabase
        .from('bang_keo_orders')
        .select()
        .order('thoi_gian', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final bki = await getBangKeoInOrders();
    final ti = await getTrucInOrders();
    final bk = await getBangKeoOrders();
    // Gán loai_don dựa vào prefix của id
    List<Map<String, dynamic>> addType(List<Map<String, dynamic>> list) {
      return list.map((e) {
        final id = (e['id'] ?? '').toString();
        String loaiDon = '';
        if (id.startsWith('BK')) {
          loaiDon = 'Băng keo in';
        } else if (id.startsWith('TI')) {
          loaiDon = 'Trục in';
        } else if (id.startsWith('B')) {
          loaiDon = 'Băng keo';
        }
        return {...e, 'loai_don': loaiDon};
      }).toList();
    }
    return [...addType(bki), ...addType(ti), ...addType(bk)];
  }

  Future<String?> createBangKeoInOrder(Map<String, dynamic> order) async {
    final response = await supabase
        .from('bang_keo_in_orders')
        .insert(order)
        .select('id')
        .single();
    return response['id']?.toString();
  }

  Future<String> generateBangKeoInOrderId() async {
    final now = DateTime.now();
    final prefix = 'BK';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4);
    final likePattern = '$prefix-$month-$year-%';
    
    // Lấy mã lớn nhất bằng cách order by DESC và lấy record đầu tiên
    final response = await supabase
        .from('bang_keo_in_orders')
        .select('id')
        .ilike('id', likePattern)
        .order('id', ascending: false)
        .limit(1);
    
    int maxNumber = 0;
    if (response.isNotEmpty) {
      final lastId = response[0]['id'] as String;
      final parts = lastId.split('-');
      if (parts.length == 4) {
        final number = int.tryParse(parts[3]);
        if (number != null) {
          maxNumber = number;
        }
      }
    }
    
    final newId = '$prefix-$month-$year-${(maxNumber + 1).toString().padLeft(3, '0')}';
    return newId;
  }

  Future<void> deleteBangKeoInOrder(String id) async {
    await supabase
        .from('bang_keo_in_orders')
        .delete()
        .eq('id', id);
  }

  Future<void> deleteTrucInOrder(String id) async {
    await supabase
        .from('truc_in_orders')
        .delete()
        .eq('id', id);
  }

  Future<void> deleteBangKeoOrder(String id) async {
    await supabase
        .from('bang_keo_orders')
        .delete()
        .eq('id', id);
  }

  Future<void> updateBangKeoInOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    await supabase
        .from('bang_keo_in_orders')
        .update({'da_giao': daGiao, 'da_tat_toan': daTatToan})
        .eq('id', id);
  }

  Future<void> updateTrucInOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    await supabase
        .from('truc_in_orders')
        .update({'da_giao': daGiao, 'da_tat_toan': daTatToan})
        .eq('id', id);
  }

  Future<void> updateBangKeoOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    await supabase
        .from('bang_keo_orders')
        .update({'da_giao': daGiao, 'da_tat_toan': daTatToan})
        .eq('id', id);
  }

  Future<String?> createTrucInOrder(Map<String, dynamic> order) async {
    final response = await supabase
        .from('truc_in_orders')
        .insert(order)
        .select('id')
        .single();
    return response['id']?.toString();
  }

  Future<String> generateTrucInOrderId() async {
    final now = DateTime.now();
    final prefix = 'TI';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4);
    final likePattern = '$prefix-$month-$year-%';
    
    // Lấy mã lớn nhất bằng cách order by DESC và lấy record đầu tiên
    final response = await supabase
        .from('truc_in_orders')
        .select('id')
        .ilike('id', likePattern)
        .order('id', ascending: false)
        .limit(1);
    
    int maxNumber = 0;
    if (response.isNotEmpty) {
      final lastId = response[0]['id'] as String;
      final parts = lastId.split('-');
      if (parts.length == 4) {
        final number = int.tryParse(parts[3]);
        if (number != null) {
          maxNumber = number;
        }
      }
    }
    
    final newId = '$prefix-$month-$year-${(maxNumber + 1).toString().padLeft(3, '0')}';
    return newId;
  }

  Future<String> generateBangKeoOrderId() async {
    final now = DateTime.now();
    final prefix = 'B';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4);
    final likePattern = '$prefix-$month-$year-%';
    
    // Lấy mã lớn nhất bằng cách order by DESC và lấy record đầu tiên
    final response = await supabase
        .from('bang_keo_orders')
        .select('id')
        .ilike('id', likePattern)
        .order('id', ascending: false)
        .limit(1);
    
    int maxNumber = 0;
    if (response.isNotEmpty) {
      final lastId = response[0]['id'] as String;
      final parts = lastId.split('-');
      if (parts.length == 4) {
        final number = int.tryParse(parts[3]);
        if (number != null) {
          maxNumber = number;
        }
      }
    }
    
    final newId = '$prefix-$month-$year-${(maxNumber + 1).toString().padLeft(3, '0')}';
    return newId;
  }

  Future<String?> createBangKeoOrder(Map<String, dynamic> order) async {
    final id = await generateBangKeoOrderId();
    final response = await supabase
        .from('bang_keo_orders')
        .insert({...order, 'id': id})
        .select('id')
        .single();
    return response['id']?.toString();
  }

  Future<Map<String, dynamic>> getBangKeoOrderById(String id) async {
    final response = await supabase
        .from('bang_keo_orders')
        .select()
        .eq('id', id)
        .single();
    if (response == null) {
      throw Exception('BangKeo order not found');
    }
    return {...response, 'loai_don': 'Băng keo'};
  }

  Future<void> updateBangKeoOrder(String id, Map<String, dynamic> order) async {
    await supabase
        .from('bang_keo_orders')
        .update(order)
        .eq('id', id);
  }

  Future<Map<String, dynamic>> getBangKeoInOrderById(String id) async {
    final response = await supabase
        .from('bang_keo_in_orders')
        .select()
        .eq('id', id)
        .single();
    if (response == null) {
      throw Exception('BangKeoIn order not found');
    }
    return {...response, 'loai_don': 'Băng keo in'};
  }

  Future<void> updateBangKeoInOrder(String id, Map<String, dynamic> order) async {
    await supabase
        .from('bang_keo_in_orders')
        .update(order)
        .eq('id', id);
  }

  Future<Map<String, dynamic>> getTrucInOrderById(String id) async {
    final response = await supabase
        .from('truc_in_orders')
        .select()
        .eq('id', id)
        .single();
    if (response == null) {
      throw Exception('TrucIn order not found');
    }
    return {...response, 'loai_don': 'Trục in'};
  }

  Future<void> updateTrucInOrder(String id, Map<String, dynamic> order) async {
    await supabase
        .from('truc_in_orders')
        .update(order)
        .eq('id', id);
  }

  Future<Map<String, dynamic>?> getOrderByAnyTable(String id) async {
    try {
      final order1 = await getBangKeoOrderById(id);
      if (order1 != null) return order1;
    } catch (_) {}
    try {
      final order2 = await getBangKeoInOrderById(id);
      if (order2 != null) return order2;
    } catch (_) {}
    try {
      final order3 = await getTrucInOrderById(id);
      if (order3 != null) return order3;
    } catch (_) {}
    try {
      final order4 = await getOrderById(id);
      if (order4 != null) return order4;
    } catch (_) {}
    return null;
  }

  Future<void> deleteOrderByAnyTable(String id) async {
    try { await deleteBangKeoOrder(id); } catch (_) {}
    try { await deleteBangKeoInOrder(id); } catch (_) {}
    try { await deleteTrucInOrder(id); } catch (_) {}
    try { await deleteOrder(id); } catch (_) {}
  }

  @override
  void dispose() {
    supabase.auth.signOut();
    super.dispose();
  }
} 