class Customer {
  final String id;
  final String tenKhachHang;
  final String phone;
  final String address;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.tenKhachHang,
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      tenKhachHang: json['ten_khach_hang'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten_khach_hang': tenKhachHang,
      'phone': phone,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 