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

  static final CustomerSession empty = CustomerSession(
    customerId: '',
    customerName: '',
    mobile: '',
    authenticated: false,
    sessionCreatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    lastActiveAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
