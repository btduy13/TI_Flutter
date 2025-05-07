import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

class DatabaseService extends ChangeNotifier {
  late PostgreSQLConnection _connection;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> initDatabase() async {
    try {
      _connection = PostgreSQLConnection(
        'aws-0-ap-southeast-1.pooler.supabase.com',
        6543,
        'postgres',
        username: 'postgres.ctmkkxfheqjdmjahkheu',
        password: 'M4tkh@u_11',
        useSSL: true,
      );

      await _connection.open();
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    if (!_isConnected) await initDatabase();
    
    final results = await _connection.mappedResultsQuery(
      'SELECT * FROM don_hang ORDER BY ngay_dat DESC',
    );
    
    return results.map((r) => r['don_hang']!).toList();
  }

  Future<Map<String, dynamic>> getOrderById(int id) async {
    if (!_isConnected) await initDatabase();
    
    final results = await _connection.mappedResultsQuery(
      'SELECT * FROM don_hang WHERE id = @id',
      substitutionValues: {'id': id},
    );
    
    if (results.isEmpty) {
      throw Exception('Order not found');
    }
    
    return results.first['don_hang']!;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    if (!_isConnected) await initDatabase();
    
    final results = await _connection.mappedResultsQuery(
      'SELECT * FROM chi_tiet_don_hang WHERE don_hang_id = @order_id',
      substitutionValues: {'order_id': orderId},
    );
    
    return results.map((r) => r['chi_tiet_don_hang']!).toList();
  }

  Future<int> createOrder(Map<String, dynamic> order) async {
    if (!_isConnected) await initDatabase();
    
    final results = await _connection.mappedResultsQuery(
      '''
      INSERT INTO don_hang (ngay_dat, ngay_du_kien, trang_thai, da_giao, da_tat_toan, ghi_chu)
      VALUES (@ngay_dat, @ngay_du_kien, @trang_thai, @da_giao, @da_tat_toan, @ghi_chu)
      RETURNING id
      ''',
      substitutionValues: {
        'ngay_dat': order['ngay_dat'],
        'ngay_du_kien': order['ngay_du_kien'],
        'trang_thai': order['trang_thai'],
        'da_giao': order['da_giao'] ?? false,
        'da_tat_toan': order['da_tat_toan'] ?? false,
        'ghi_chu': order['ghi_chu'],
      },
    );
    
    return results.first['don_hang']!['id'] as int;
  }

  Future<void> addOrderItem(int orderId, Map<String, dynamic> item) async {
    if (!_isConnected) await initDatabase();
    
    await _connection.execute(
      '''
      INSERT INTO chi_tiet_don_hang (don_hang_id, ten_hang, so_luong, don_gia, thanh_tien, quy_cach, mau_sac, mau_keo)
      VALUES (@don_hang_id, @ten_hang, @so_luong, @don_gia, @thanh_tien, @quy_cach, @mau_sac, @mau_keo)
      ''',
      substitutionValues: {
        'don_hang_id': orderId,
        'ten_hang': item['ten_hang'],
        'so_luong': item['so_luong'],
        'don_gia': item['don_gia'],
        'thanh_tien': item['thanh_tien'],
        'quy_cach': item['quy_cach'],
        'mau_sac': item['mau_sac'],
        'mau_keo': item['mau_keo'],
      },
    );
  }

  Future<void> updateOrder(int id, Map<String, dynamic> order) async {
    if (!_isConnected) await initDatabase();
    
    await _connection.execute(
      '''
      UPDATE don_hang
      SET ngay_dat = @ngay_dat,
          ngay_du_kien = @ngay_du_kien,
          trang_thai = @trang_thai,
          da_giao = @da_giao,
          da_tat_toan = @da_tat_toan,
          ghi_chu = @ghi_chu
      WHERE id = @id
      ''',
      substitutionValues: {
        'id': id,
        'ngay_dat': order['ngay_dat'],
        'ngay_du_kien': order['ngay_du_kien'],
        'trang_thai': order['trang_thai'],
        'da_giao': order['da_giao'] ?? false,
        'da_tat_toan': order['da_tat_toan'] ?? false,
        'ghi_chu': order['ghi_chu'],
      },
    );
  }

  Future<void> deleteOrder(int id) async {
    if (!_isConnected) await initDatabase();
    
    await _connection.execute(
      'DELETE FROM don_hang WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  Future<void> deleteOrderItem(int itemId) async {
    if (!_isConnected) await initDatabase();
    
    await _connection.execute(
      'DELETE FROM chi_tiet_don_hang WHERE id = @id',
      substitutionValues: {'id': itemId},
    );
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    if (!_isConnected) await initDatabase();
    
    final results = await _connection.mappedResultsQuery(
      'SELECT * FROM products ORDER BY name',
    );
    
    return results.map((r) => r['products']!).toList();
  }

  Future<List<Map<String, dynamic>>> getBangKeoInOrders() async {
    if (!_isConnected) await initDatabase();
    final results = await _connection.mappedResultsQuery(
      'SELECT *, id as order_id FROM bang_keo_in_orders ORDER BY thoi_gian DESC',
    );
    return results.map((r) => {...r['bang_keo_in_orders']!, 'loai_don': 'Băng keo in'}).toList();
  }

  Future<List<Map<String, dynamic>>> getTrucInOrders() async {
    if (!_isConnected) await initDatabase();
    final results = await _connection.mappedResultsQuery(
      'SELECT *, id as order_id FROM truc_in_orders ORDER BY thoi_gian DESC',
    );
    return results.map((r) => {...r['truc_in_orders']!, 'loai_don': 'Trục in'}).toList();
  }

  Future<List<Map<String, dynamic>>> getBangKeoOrders() async {
    if (!_isConnected) await initDatabase();
    final results = await _connection.mappedResultsQuery(
      'SELECT *, id as order_id FROM bang_keo_orders ORDER BY thoi_gian DESC',
    );
    return results.map((r) => {...r['bang_keo_orders']!, 'loai_don': 'Băng keo'}).toList();
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final bki = await getBangKeoInOrders();
    final ti = await getTrucInOrders();
    final bk = await getBangKeoOrders();
    return [...bki, ...ti, ...bk];
  }

  Future<String> createBangKeoInOrder(Map<String, dynamic> order) async {
    if (!_isConnected) await initDatabase();
    final results = await _connection.mappedResultsQuery(
      '''
      INSERT INTO bang_keo_in_orders (
        id, thoi_gian, ten_hang, ten_khach_hang, ngay_du_kien, quy_cach_mm, quy_cach_m, quy_cach_mic, cuon_cay, so_luong, phi_sl, mau_keo, phi_keo, mau_sac, phi_mau, phi_size, phi_cat, don_gia_von, don_gia_goc, thanh_tien_goc, don_gia_ban, thanh_tien_ban, tien_coc, cong_no_khach, ctv, hoa_hong, tien_hoa_hong, loi_giay, thung_bao, loi_nhuan, tien_ship, loi_nhuan_rong, da_giao, da_tat_toan
      ) VALUES (
        @id, @thoi_gian, @ten_hang, @ten_khach_hang, @ngay_du_kien, @quy_cach_mm, @quy_cach_m, @quy_cach_mic, @cuon_cay, @so_luong, @phi_sl, @mau_keo, @phi_keo, @mau_sac, @phi_mau, @phi_size, @phi_cat, @don_gia_von, @don_gia_goc, @thanh_tien_goc, @don_gia_ban, @thanh_tien_ban, @tien_coc, @cong_no_khach, @ctv, @hoa_hong, @tien_hoa_hong, @loi_giay, @thung_bao, @loi_nhuan, @tien_ship, @loi_nhuan_rong, @da_giao, @da_tat_toan
      ) RETURNING id
      ''',
      substitutionValues: order,
    );
    return results.first['bang_keo_in_orders']!['id'].toString();
  }

  Future<String> generateBangKeoInOrderId() async {
    if (!_isConnected) await initDatabase();
    final now = DateTime.now();
    final prefix = 'BKI';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4); // 2 số cuối
    final likePattern = '$prefix-$month-$year-%'; // Đảm bảo đúng pattern
    final result = await _connection.query(
      """
      SELECT MAX(CAST(SUBSTRING(id FROM '[0-9]{3}\$') AS INTEGER))
      FROM bang_keo_in_orders
      WHERE id LIKE @likePattern
      """,
      substitutionValues: {'likePattern': likePattern},
    );
    int nextNumber = 1;
    if (result.isNotEmpty && result.first[0] != null) {
      nextNumber = (result.first[0] as int) + 1;
    }
    final newId = '$prefix-$month-$year-${nextNumber.toString().padLeft(3, '0')}';
    return newId;
  }

  Future<void> deleteBangKeoInOrder(String id) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'DELETE FROM bang_keo_in_orders WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  Future<void> deleteTrucInOrder(String id) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'DELETE FROM truc_in_orders WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  Future<void> deleteBangKeoOrder(String id) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'DELETE FROM bang_keo_orders WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  Future<void> updateBangKeoInOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'UPDATE bang_keo_in_orders SET da_giao = COALESCE(@da_giao, da_giao), da_tat_toan = COALESCE(@da_tat_toan, da_tat_toan) WHERE id = @id',
      substitutionValues: {'id': id, 'da_giao': daGiao, 'da_tat_toan': daTatToan},
    );
  }

  Future<void> updateTrucInOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'UPDATE truc_in_orders SET da_giao = COALESCE(@da_giao, da_giao), da_tat_toan = COALESCE(@da_tat_toan, da_tat_toan) WHERE id = @id',
      substitutionValues: {'id': id, 'da_giao': daGiao, 'da_tat_toan': daTatToan},
    );
  }

  Future<void> updateBangKeoOrderStatus(String id, {bool? daGiao, bool? daTatToan}) async {
    if (!_isConnected) await initDatabase();
    await _connection.execute(
      'UPDATE bang_keo_orders SET da_giao = COALESCE(@da_giao, da_giao), da_tat_toan = COALESCE(@da_tat_toan, da_tat_toan) WHERE id = @id',
      substitutionValues: {'id': id, 'da_giao': daGiao, 'da_tat_toan': daTatToan},
    );
  }

  Future<String> createTrucInOrder(Map<String, dynamic> order) async {
    if (!_isConnected) await initDatabase();
    final results = await _connection.mappedResultsQuery(
      '''
      INSERT INTO truc_in_orders (
        id, thoi_gian, ten_hang, ten_khach_hang, ngay_du_kien, quy_cach, so_luong, mau_sac, mau_keo,
        don_gia_goc, thanh_tien_goc, don_gia_ban, thanh_tien_ban, cong_no_khach, ctv, hoa_hong,
        tien_hoa_hong, loi_nhuan, tien_ship, loi_nhuan_rong, da_giao, da_tat_toan
      ) VALUES (
        @id, @thoi_gian, @ten_hang, @ten_khach_hang, @ngay_du_kien, @quy_cach, @so_luong, @mau_sac, @mau_keo,
        @don_gia_goc, @thanh_tien_goc, @don_gia_ban, @thanh_tien_ban, @cong_no_khach, @ctv, @hoa_hong,
        @tien_hoa_hong, @loi_nhuan, @tien_ship, @loi_nhuan_rong, @da_giao, @da_tat_toan
      ) RETURNING id
      ''',
      substitutionValues: order,
    );
    return results.first['truc_in_orders']!['id'].toString();
  }

  Future<String> generateTrucInOrderId() async {
    if (!_isConnected) await initDatabase();
    final now = DateTime.now();
    final prefix = 'TI';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4);
    final likePattern = '$prefix-$month-$year-%';
    final result = await _connection.query(
      """
      SELECT id FROM truc_in_orders WHERE id LIKE @likePattern ORDER BY id DESC LIMIT 1
      """,
      substitutionValues: {'likePattern': likePattern},
    );
    int nextNumber = 1;
    if (result.isNotEmpty && result.first[0] != null) {
      final lastId = result.first[0] as String;
      final parts = lastId.split('-');
      if (parts.length == 4) {
        final number = int.tryParse(parts[3]);
        if (number != null) {
          nextNumber = number + 1;
        }
      }
    }
    final newId = '$prefix-$month-$year-${nextNumber.toString().padLeft(3, '0')}';
    return newId;
  }

  Future<String> generateBangKeoOrderId() async {
    if (!_isConnected) await initDatabase();
    final now = DateTime.now();
    final prefix = 'B';
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2, 4);
    final likePattern = '$prefix-$month-$year-%';
    final result = await _connection.query(
      """
      SELECT id FROM bang_keo_orders WHERE id LIKE @likePattern ORDER BY id DESC LIMIT 1
      """,
      substitutionValues: {'likePattern': likePattern},
    );
    int nextNumber = 1;
    if (result.isNotEmpty && result.first[0] != null) {
      final lastId = result.first[0] as String;
      final parts = lastId.split('-');
      if (parts.length == 4) {
        final number = int.tryParse(parts[3]);
        if (number != null) {
          nextNumber = number + 1;
        }
      }
    }
    final newId = '$prefix-$month-$year-${nextNumber.toString().padLeft(3, '0')}';
    return newId;
  }

  Future<String> createBangKeoOrder(Map<String, dynamic> order) async {
    if (!_isConnected) await initDatabase();
    
    final id = await generateBangKeoOrderId();
    final results = await _connection.mappedResultsQuery(
      '''
      INSERT INTO bang_keo_orders (
        id, thoi_gian, ten_hang, ten_khach_hang, ngay_du_kien, quy_cach, so_luong,
        mau_sac, don_gia_goc, thanh_tien, don_gia_ban, thanh_tien_ban, cong_no_khach,
        ctv, hoa_hong, tien_hoa_hong, loi_nhuan, tien_ship, loi_nhuan_rong,
        da_giao, da_tat_toan
      ) VALUES (
        @id, @thoi_gian, @ten_hang, @ten_khach_hang, @ngay_du_kien, @quy_cach, @so_luong,
        @mau_sac, @don_gia_goc, @thanh_tien, @don_gia_ban, @thanh_tien_ban, @cong_no_khach,
        @ctv, @hoa_hong, @tien_hoa_hong, @loi_nhuan, @tien_ship, @loi_nhuan_rong,
        @da_giao, @da_tat_toan
      ) RETURNING id
      ''',
      substitutionValues: {
        'id': id,
        ...order,
      },
    );
    return results.first['bang_keo_orders']!['id'].toString();
  }

  @override
  void dispose() {
    _connection.close();
    super.dispose();
  }
} 