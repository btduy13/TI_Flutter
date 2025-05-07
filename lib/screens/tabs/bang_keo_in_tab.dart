import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class BangKeoInTab extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDateSelect;

  const BangKeoInTab({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
  });

  @override
  State<BangKeoInTab> createState() => _BangKeoInTabState();
}

class _BangKeoInTabState extends State<BangKeoInTab> {
  final _formKey = GlobalKey<FormState>();
  final _tenHangController = TextEditingController();
  final _tenKhachHangController = TextEditingController();
  final _quyCachMmController = TextEditingController();
  final _quyCachMController = TextEditingController();
  final _quyCachMicController = TextEditingController();
  final _cuonCayController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _phiSlController = TextEditingController();
  final _mauKeoController = TextEditingController();
  final _phiKeoController = TextEditingController();
  final _mauSacController = TextEditingController();
  final _phiMauController = TextEditingController();
  final _phiSizeController = TextEditingController();
  final _phiCatController = TextEditingController();
  final _donGiaVonController = TextEditingController();
  final _donGiaGocController = TextEditingController();
  final _thanhTienGocController = TextEditingController();
  final _donGiaBanController = TextEditingController();
  final _thanhTienBanController = TextEditingController();
  final _tienCocController = TextEditingController();
  final _congNoKhachController = TextEditingController();
  final _ctvController = TextEditingController();
  final _hoaHongController = TextEditingController();
  final _tienHoaHongController = TextEditingController();
  final _loiGiayController = TextEditingController();
  final _thungBaoController = TextEditingController();
  final _loiNhuanController = TextEditingController();
  final _tienShipController = TextEditingController();
  final _loiNhuanRongController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void dispose() {
    _tenHangController.dispose();
    _tenKhachHangController.dispose();
    _quyCachMmController.dispose();
    _quyCachMController.dispose();
    _quyCachMicController.dispose();
    _cuonCayController.dispose();
    _soLuongController.dispose();
    _phiSlController.dispose();
    _mauKeoController.dispose();
    _phiKeoController.dispose();
    _mauSacController.dispose();
    _phiMauController.dispose();
    _phiSizeController.dispose();
    _phiCatController.dispose();
    _donGiaVonController.dispose();
    _donGiaGocController.dispose();
    _thanhTienGocController.dispose();
    _donGiaBanController.dispose();
    _thanhTienBanController.dispose();
    _tienCocController.dispose();
    _congNoKhachController.dispose();
    _ctvController.dispose();
    _hoaHongController.dispose();
    _tienHoaHongController.dispose();
    _loiGiayController.dispose();
    _thungBaoController.dispose();
    _loiNhuanController.dispose();
    _tienShipController.dispose();
    _loiNhuanRongController.dispose();
    super.dispose();
  }

  dynamic _parseField(String value) {
    final numValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    return numValue;
  }

  void _autoCalculate() {
    final soLuong = _parseField(_soLuongController.text);
    final donGiaVon = _parseField(_donGiaVonController.text);
    final phiSl = _parseField(_phiSlController.text);
    final phiKeo = _parseField(_phiKeoController.text);
    final phiMau = _parseField(_phiMauController.text);
    final phiSize = _parseField(_phiSizeController.text);
    final phiCat = _parseField(_phiCatController.text);
    final donGiaBan = _parseField(_donGiaBanController.text);
    final tienCoc = _parseField(_tienCocController.text);
    final hoaHong = _parseField(_hoaHongController.text) / 100.0;
    final tienShip = _parseField(_tienShipController.text);
    final cuonCay = _parseField(_cuonCayController.text);
    final quyCachM = _parseField(_quyCachMController.text);

    double donGiaGoc = 0.0;
    if (cuonCay != 0 && quyCachM != 0) {
      donGiaGoc = (donGiaVon + phiSl + phiKeo + phiMau + phiSize + phiCat) / 90.0 * quyCachM / cuonCay;
    }
    final thanhTienGoc = donGiaGoc * soLuong;
    final thanhTienBan = donGiaBan * soLuong;
    final congNoKhach = thanhTienBan - tienCoc;
    final loiNhuan = thanhTienBan - thanhTienGoc;
    final tienHoaHong = loiNhuan * hoaHong;
    final loiNhuanRong = loiNhuan - tienHoaHong - tienShip;

    _donGiaGocController.text = currencyFormat.format(donGiaGoc);
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
            _buildSpecsCard(),
            const SizedBox(height: 16),
            _buildQuantityAndFeesCard(),
            const SizedBox(height: 16),
            _buildPricingCard(),
            const SizedBox(height: 16),
            _buildCTVAndCommissionCard(),
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(),
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

  Widget _buildSpecsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quy cách',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quyCachMmController,
              decoration: const InputDecoration(
                labelText: 'Quy cách (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quy cách';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quyCachMController,
              decoration: const InputDecoration(
                labelText: 'Quy cách (m)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quy cách';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quyCachMicController,
              decoration: const InputDecoration(
                labelText: 'Quy cách (mic)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quy cách';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuonCayController,
              decoration: const InputDecoration(
                labelText: 'Cuộn/Cây',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng cuộn/cây';
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

  Widget _buildQuantityAndFeesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số lượng và phí',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phiSlController,
              decoration: const InputDecoration(
                labelText: 'Phí số lượng',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mauKeoController,
              decoration: const InputDecoration(
                labelText: 'Màu keo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phiKeoController,
              decoration: const InputDecoration(
                labelText: 'Phí keo',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
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
              controller: _phiMauController,
              decoration: const InputDecoration(
                labelText: 'Phí màu',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phiSizeController,
              decoration: const InputDecoration(
                labelText: 'Phí size',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phiCatController,
              decoration: const InputDecoration(
                labelText: 'Phí cắt',
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
              controller: _donGiaVonController,
              decoration: const InputDecoration(
                labelText: 'Đơn giá vốn',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn giá vốn';
                }
                return null;
              },
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _donGiaGocController,
              decoration: _readonlyDecoration('Đơn giá gốc'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thanhTienGocController,
              decoration: _readonlyDecoration('Thành tiền gốc'),
              readOnly: true,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _thanhTienBanController,
              decoration: _readonlyDecoration('Thành tiền bán'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tienCocController,
              decoration: const InputDecoration(
                labelText: 'Tiền cọc',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalculate(),
              inputFormatters: [MoneyInputFormatter(thousandSeparator: ThousandSeparator.Period, mantissaLength: 0, trailingSymbol: '')],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _congNoKhachController,
              decoration: _readonlyDecoration('Công nợ khách'),
              readOnly: true,
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
              controller: _tienHoaHongController,
              decoration: _readonlyDecoration('Tiền hoa hồng'),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin thêm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loiGiayController,
              decoration: const InputDecoration(
                labelText: 'Lõi giấy',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thungBaoController,
              decoration: const InputDecoration(
                labelText: 'Thùng/Bao',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loiNhuanController,
              decoration: _readonlyDecoration('Lợi nhuận'),
              readOnly: true,
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
                final newId = await db.generateBangKeoInOrderId();
                final order = {
                  'id': newId,
                  'thoi_gian': now.toIso8601String(),
                  'ten_hang': _tenHangController.text,
                  'ten_khach_hang': _tenKhachHangController.text,
                  'ngay_du_kien': widget.selectedDate?.toIso8601String() ?? now.toIso8601String(),
                  'quy_cach_mm': _parseField(_quyCachMmController.text),
                  'quy_cach_m': _parseField(_quyCachMController.text),
                  'quy_cach_mic': _parseField(_quyCachMicController.text),
                  'cuon_cay': _parseField(_cuonCayController.text),
                  'so_luong': _parseField(_soLuongController.text),
                  'phi_sl': _parseField(_phiSlController.text),
                  'mau_keo': _mauKeoController.text,
                  'phi_keo': _parseField(_phiKeoController.text),
                  'mau_sac': _mauSacController.text,
                  'phi_mau': _parseField(_phiMauController.text),
                  'phi_size': _parseField(_phiSizeController.text),
                  'phi_cat': _parseField(_phiCatController.text),
                  'don_gia_von': _parseField(_donGiaVonController.text),
                  'don_gia_goc': _parseField(_donGiaGocController.text),
                  'thanh_tien_goc': _parseField(_thanhTienGocController.text),
                  'don_gia_ban': _parseField(_donGiaBanController.text),
                  'thanh_tien_ban': _parseField(_thanhTienBanController.text),
                  'tien_coc': _parseField(_tienCocController.text),
                  'cong_no_khach': _parseField(_congNoKhachController.text),
                  'ctv': _ctvController.text,
                  'hoa_hong': _parseField(_hoaHongController.text),
                  'tien_hoa_hong': _parseField(_tienHoaHongController.text),
                  'loi_giay': _loiGiayController.text,
                  'thung_bao': _thungBaoController.text,
                  'loi_nhuan': _parseField(_loiNhuanController.text),
                  'tien_ship': _parseField(_tienShipController.text),
                  'loi_nhuan_rong': _parseField(_loiNhuanRongController.text),
                  'da_giao': false,
                  'da_tat_toan': false,
                };
                print(order);
                order.forEach((k, v) => print('$k: \\t${v.runtimeType} - $v'));
                final id = await db.createBangKeoInOrder(order);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã lưu đơn hàng thành công (ID: $id)!')),
                  );
                }
              } catch (e, stack) {
                print('Lỗi khi lưu đơn hàng: $e');
                print(stack);
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