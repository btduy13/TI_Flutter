import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../services/database_service.dart';

class BangKeoTab extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDateSelect;
  final Map<String, dynamic>? initialData;
  final Future<void> Function(Map<String, dynamic> data)? onSave;

  const BangKeoTab({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
    this.initialData,
    this.onSave,
  });

  @override
  State<BangKeoTab> createState() => _BangKeoTabState();
}

class _BangKeoTabState extends State<BangKeoTab> {
  final _formKey = GlobalKey<FormState>();
  final _tenHangController = TextEditingController();
  final _tenKhachHangController = TextEditingController();
  final _quyCachController = TextEditingController();
  final _soLuongController = TextEditingController();
  final _mauSacController = TextEditingController();
  final _donGiaGocController = TextEditingController();
  final _donGiaBanController = TextEditingController();
  final _tenCtvController = TextEditingController();
  final _hoaHongCtvController = TextEditingController();
  final _tienShipController = TextEditingController();

  double _thanhTien = 0;
  double _thanhTienBan = 0;
  double _congNoKhach = 0;
  double _tienHoaHong = 0;
  double _loiNhuan = 0;
  double _loiNhuanRong = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _tenHangController.text = d['ten_hang']?.toString() ?? '';
      _tenKhachHangController.text = d['ten_khach_hang']?.toString() ?? '';
      _quyCachController.text = d['quy_cach']?.toString() ?? '';
      _soLuongController.text = d['so_luong']?.toString() ?? '';
      _mauSacController.text = d['mau_sac']?.toString() ?? '';
      _donGiaGocController.text = d['don_gia_goc']?.toString() ?? '';
      _donGiaBanController.text = d['don_gia_ban']?.toString() ?? '';
      _tenCtvController.text = d['ctv']?.toString() ?? '';
      _hoaHongCtvController.text = d['hoa_hong']?.toString() ?? '';
      _tienShipController.text = d['tien_ship']?.toString() ?? '';
      // calculated fields
      _thanhTien = d['thanh_tien'] ?? 0;
      _thanhTienBan = d['thanh_tien_ban'] ?? 0;
      _congNoKhach = d['cong_no_khach'] ?? 0;
      _tienHoaHong = d['tien_hoa_hong'] ?? 0;
      _loiNhuan = d['loi_nhuan'] ?? 0;
      _loiNhuanRong = d['loi_nhuan_rong'] ?? 0;
    }
  }

  void _calculateValues() {
    final soLuong = double.tryParse(toNumericString(_soLuongController.text)) ?? 0;
    final donGiaGoc = double.tryParse(toNumericString(_donGiaGocController.text)) ?? 0;
    final donGiaBan = double.tryParse(toNumericString(_donGiaBanController.text)) ?? 0;
    final tienShip = double.tryParse(toNumericString(_tienShipController.text)) ?? 0;
    final hoaHong = double.tryParse(toNumericString(_hoaHongCtvController.text)) ?? 0;

    setState(() {
      _thanhTien = soLuong * donGiaGoc;
      _thanhTienBan = soLuong * donGiaBan;
      _congNoKhach = _thanhTienBan - tienShip;
      _tienHoaHong = _thanhTienBan * hoaHong / 100;
      _loiNhuan = _thanhTienBan - _thanhTien;
      _loiNhuanRong = _loiNhuan - _tienHoaHong - tienShip;
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final order = {
      'ten_hang': _tenHangController.text,
      'ten_khach_hang': _tenKhachHangController.text,
      'ngay_du_kien': widget.selectedDate?.toIso8601String(),
      'quy_cach': _quyCachController.text,
      'so_luong': double.tryParse(_soLuongController.text) ?? 0,
      'mau_sac': _mauSacController.text,
      'don_gia_goc': double.tryParse(_donGiaGocController.text) ?? 0,
      'thanh_tien': _thanhTien,
      'don_gia_ban': double.tryParse(_donGiaBanController.text) ?? 0,
      'thanh_tien_ban': _thanhTienBan,
      'tien_coc': 0,
      'cong_no_khach': _congNoKhach,
      'ctv': _tenCtvController.text,
      'hoa_hong': double.tryParse(_hoaHongCtvController.text) ?? 0,
      'tien_hoa_hong': _tienHoaHong,
      'loi_nhuan': _loiNhuan,
      'tien_ship': double.tryParse(_tienShipController.text) ?? 0,
      'loi_nhuan_rong': _loiNhuanRong,
      'da_giao': widget.initialData?['da_giao'] ?? false,
      'da_tat_toan': widget.initialData?['da_tat_toan'] ?? false,
      'id': widget.initialData?['id'],
    };
    if (widget.onSave != null) {
      await widget.onSave!(order);
    } else {
      try {
        final dbService = Provider.of<DatabaseService>(context, listen: false);
        await dbService.createBangKeoOrder(order);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu đơn hàng thành công')),
          );
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: \\${e.toString()}')),
          );
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _tenHangController.clear();
    _tenKhachHangController.clear();
    _quyCachController.clear();
    _soLuongController.clear();
    _mauSacController.clear();
    _donGiaGocController.clear();
    _donGiaBanController.clear();
    _tenCtvController.clear();
    _hoaHongCtvController.clear();
    _tienShipController.clear();
    setState(() {
      _thanhTien = 0;
      _thanhTienBan = 0;
      _congNoKhach = 0;
      _tienHoaHong = 0;
      _loiNhuan = 0;
      _loiNhuanRong = 0;
    });
  }

  @override
  void dispose() {
    _tenHangController.dispose();
    _tenKhachHangController.dispose();
    _quyCachController.dispose();
    _soLuongController.dispose();
    _mauSacController.dispose();
    _donGiaGocController.dispose();
    _donGiaBanController.dispose();
    _tenCtvController.dispose();
    _hoaHongCtvController.dispose();
    _tienShipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    
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
            _buildCalculationsCard(),
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
              onChanged: (_) => _calculateValues(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mauSacController,
              decoration: const InputDecoration(
                labelText: 'Màu sắc',
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
              inputFormatters: [
                MoneyInputFormatter(
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 0,
                  trailingSymbol: '',
                ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn giá gốc';
                }
                return null;
              },
              onChanged: (_) => _calculateValues(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _donGiaBanController,
              decoration: const InputDecoration(
                labelText: 'Đơn giá bán',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MoneyInputFormatter(
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 0,
                  trailingSymbol: '',
                ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đơn giá bán';
                }
                return null;
              },
              onChanged: (_) => _calculateValues(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tienShipController,
              decoration: const InputDecoration(
                labelText: 'Tiền ship',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MoneyInputFormatter(
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 0,
                  trailingSymbol: '',
                ),
              ],
              onChanged: (_) => _calculateValues(),
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
              'Thông tin CTV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tenCtvController,
              decoration: const InputDecoration(
                labelText: 'Tên CTV',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoaHongCtvController,
              decoration: const InputDecoration(
                labelText: 'Hoa hồng CTV (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                MoneyInputFormatter(
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 0,
                  trailingSymbol: '',
                ),
              ],
              onChanged: (_) => _calculateValues(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationsCard() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tính toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCalculationRow('Thành tiền:', currencyFormat.format(_thanhTien)),
            _buildCalculationRow('Thành tiền bán:', currencyFormat.format(_thanhTienBan)),
            _buildCalculationRow('Công nợ khách:', currencyFormat.format(_congNoKhach)),
            _buildCalculationRow('Tiền hoa hồng:', currencyFormat.format(_tienHoaHong)),
            _buildCalculationRow('Lợi nhuận:', currencyFormat.format(_loiNhuan)),
            _buildCalculationRow('Lợi nhuận ròng:', currencyFormat.format(_loiNhuanRong)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
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
              'Thông tin bổ sung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Làm mới'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Lưu đơn'),
          ),
        ),
      ],
    );
  }
} 