import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BangKeoTab extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDateSelect;

  const BangKeoTab({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
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
  final _donGiaGocController = TextEditingController();
  final _donGiaBanController = TextEditingController();
  final _tenCtvController = TextEditingController();
  final _hoaHongCtvController = TextEditingController();
  final _ghiChuController = TextEditingController();

  @override
  void dispose() {
    _tenHangController.dispose();
    _tenKhachHangController.dispose();
    _quyCachController.dispose();
    _soLuongController.dispose();
    _donGiaGocController.dispose();
    _donGiaBanController.dispose();
    _tenCtvController.dispose();
    _hoaHongCtvController.dispose();
    _ghiChuController.dispose();
    super.dispose();
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
                labelText: 'Hoa hồng CTV',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              controller: _ghiChuController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: () {
            // TODO: Implement calculation logic
          },
          child: const Text('Tính toán'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Implement save logic
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
} 