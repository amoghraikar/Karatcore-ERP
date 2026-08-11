class CustomerSession {
  const CustomerSession({
    required this.customerId,
    required this.customerName,
    required this.mobile,
    required this.authenticated,
    required this.sessionCreatedAt,
    required this.lastActiveAt,
  });

  final String customerId;
  final String customerName;
  final String mobile;
  final bool authenticated;
  final DateTime sessionCreatedAt;
  final DateTime lastActiveAt;

  CustomerSession copyWith({
    String? customerId,
    String? customerName,
    String? mobile,
    bool? authenticated,
    DateTime? sessionCreatedAt,
    DateTime? lastActiveAt,
  }) {
    return CustomerSession(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      mobile: mobile ?? this.mobile,
      authenticated: authenticated ?? this.authenticated,
      sessionCreatedAt: sessionCreatedAt ?? this.sessionCreatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  // Pre-configured test customer accounts for data isolation verification
  static final CustomerSession demoCustomerA = CustomerSession(
    customerId: 'KC-CUS-000101',
    customerName: 'Rahul Sharma',
    mobile: '+91 98201 12345',
    authenticated: true,
    sessionCreatedAt: DateTime(2026, 8, 11, 10, 0),
    lastActiveAt: DateTime(2026, 8, 11, 10, 0),
  );

  static final CustomerSession demoCustomerB = CustomerSession(
    customerId: 'CUST-002',
    customerName: 'Sunita Devi',
    mobile: '+91 98211 54321',
    authenticated: true,
    sessionCreatedAt: DateTime(2026, 8, 11, 10, 0),
    lastActiveAt: DateTime(2026, 8, 11, 10, 0),
  );
}
