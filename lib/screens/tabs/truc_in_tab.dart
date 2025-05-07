import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tape_inventory_flutter/services/database_service.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class TrucInTab extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDateSelect;

  const TrucInTab({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
  });

  @override
  State<TrucInTab> createState() => _TrucInTabState();
}

class _TrucInTabState extends State<TrucInTab> {
  final _formKey = GlobalKey<FormState>();
  final _tenHangController = TextEditingController();
  final _tenKhachHangController = TextEditingController();
  final _quyCachController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _mauSacController = TextEditingController();
  final _mauKeoController = TextEditingController();
  final _donGiaGocController = TextEditingController();
  final _donGiaBanController = TextEditingController();
  final _ctvController = TextEditingController();
  final _hoaHongController = TextEditingController();
  final _tienShipController = TextEditingController();

  // Các trường tính toán (readonly)
  final _thanhTienGocController = TextEditingController();
  final _thanhTienBanController = TextEditingController();
  final _congNoKhachController = TextEditingController();
  final _tienHoaHongController = TextEditingController();
  final _loiNhuanController = TextEditingController();
  final _loiNhuanRongController = TextEditingController();

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void dispose() {
    _tenHangController.dispose();
    _tenKhachHangController.dispose();
    _quyCachController.dispose();
    _soLuongController.dispose();
    _mauSacController.dispose();
    _mauKeoController.dispose();
    _donGiaGocController.dispose();
    _donGiaBanController.dispose();
    _ctvController.dispose();
    _hoaHongController.dispose();
    _tienShipController.dispose();
    _thanhTienGocController.dispose();
    _thanhTienBanController.dispose();
    _congNoKhachController.dispose();
    _tienHoaHongController.dispose();
    _loiNhuanController.dispose();
    _loiNhuanRongController.dispose();
    super.dispose();
  }

  double _parseField(String value) {
    final numValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    return numValue;
  }

  void _autoCalculate() {
    final soLuong = _parseField(_soLuongController.text);
    final donGiaGoc = _parseField(_donGiaGocController.text);
    final donGiaBan = _parseField(_donGiaBanController.text);
    final hoaHong = _parseField(_hoaHongController.text) / 100.0;
    final tienShip = _parseField(_tienShipController.text);

    final thanhTienGoc = donGiaGoc * soLuong;
    final thanhTienBan = donGiaBan * soLuong;
    final loiNhuan = thanhTienBan - thanhTienGoc;
    final tienHoaHong = loiNhuan * hoaHong;
    final congNoKhach = thanhTienBan;
    final loiNhuanRong = loiNhuan - tienHoaHong - tienShip;

    _thanhTienGocController.text = currencyFormat.format(thanhTienGoc);
    _thanhTienBanController.text = currencyFormat.format(thanhTienBan);
    _congNoKhachController.text = currencyFormat.format(congNoKhach);
    _tienHoaHongController.text = currencyFormat.format(tienHoaHong);
    _loiNhuanController.text = currencyFormat.format(loiNhuan);
    _loiNhuanRongController.text = currencyFormat.format(loiNhuanRong);
  }

  InputDecoration _readonlyDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildProductInfoCard(),
            const SizedBox(height: 16),
            _buildPricingCard(),
            const SizedBox(height: 16),
            _buildCTVAndCommissionCard(),
            const SizedBox(height: 16),
            _buildReadonlyCalculatedCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tenHangController,
              decoration: const InputDecoration(
                labelText: 'Tên hàng',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tenKhachHangController,
              decoration: const InputDecoration(
                labelText: 'Tên khách hàng',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên khách hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => widget.onDateSelect(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày dự kiến',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  widget.selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!)
                      : 'Chọn ngày',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quyCachController,
              decoration: const InputDecoration(
                labelText: 'Quy cách',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quy cách';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _soLuongController,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mauSacController,
              decoration: const InputDecoration(
                labelText: 'Màu sắc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mauKeoController,
              decoration: const InputDecoration(
                labelText: 'Màu keo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giá cả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _donGiaGocController,
              decoration: const InputDecoration(
                labelText: 'Đơn giá gốc',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn giá gốc';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _donGiaBanController,
              decoration: const InputDecoration(
                labelText: 'Đơn giá bán',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn giá bán';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTVAndCommissionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CTV và hoa hồng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ctvController,
              decoration: const InputDecoration(
                labelText: 'CTV',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoaHongController,
              decoration: const InputDecoration(
                labelText: 'Hoa hồng (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tienShipController,
              decoration: const InputDecoration(
                labelText: 'Tiền ship',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadonlyCalculatedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả tính toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thanhTienGocController,
              decoration: _readonlyDecoration('Thành tiền gốc'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thanhTienBanController,
              decoration: _readonlyDecoration('Thành tiền bán'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _congNoKhachController,
              decoration: _readonlyDecoration('Công nợ khách'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tienHoaHongController,
              decoration: _readonlyDecoration('Tiền hoa hồng'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loiNhuanController,
              decoration: _readonlyDecoration('Lợi nhuận'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loiNhuanRongController,
              decoration: _readonlyDecoration('Lợi nhuận ròng'),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _autoCalculate,
          child: const Text('Tính toán'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final db = Provider.of<DatabaseService>(context, listen: false);
                final now = DateTime.now();
                final newId = await db.generateTrucInOrderId();
                final order = {
                  'id': newId,
                  'thoi_gian': now.toIso8601String(),
                  'ten_hang': _tenHangController.text,
                  'ten_khach_hang': _tenKhachHangController.text,
                  'ngay_du_kien': widget.selectedDate?.toIso8601String() ?? now.toIso8601String(),
                  'quy_cach': _quyCachController.text,
                  'so_luong': _parseField(_soLuongController.text),
                  'mau_sac': _mauSacController.text,
                  'mau_keo': _mauKeoController.text,
                  'don_gia_goc': _parseField(_donGiaGocController.text),
                  'thanh_tien_goc': _parseField(_thanhTienGocController.text),
                  'don_gia_ban': _parseField(_donGiaBanController.text),
                  'thanh_tien_ban': _parseField(_thanhTienBanController.text),
                  'cong_no_khach': _parseField(_congNoKhachController.text),
                  'ctv': _ctvController.text,
                  'hoa_hong': _parseField(_hoaHongController.text),
                  'tien_hoa_hong': _parseField(_tienHoaHongController.text),
                  'loi_nhuan': _parseField(_loiNhuanController.text),
                  'tien_ship': _parseField(_tienShipController.text),
                  'loi_nhuan_rong': _parseField(_loiNhuanRongController.text),
                  'da_giao': false,
                  'da_tat_toan': false,
                };
                final id = await db.createTrucInOrder(order);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã lưu đơn hàng thành công (ID: $id)!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi lưu đơn hàng: $e')),
                  );
                }
              }
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
} 