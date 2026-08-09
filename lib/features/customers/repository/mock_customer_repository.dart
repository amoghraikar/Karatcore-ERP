import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import 'customer_repository.dart';

class MockCustomerRepository implements ICustomerRepository {
  MockCustomerRepository() {
    _seedData();
  }

  final List<CustomerModel> _customers = [];

  void _seedData() {
    if (_customers.isNotEmpty) return;

    final now = DateTime.now();

    _customers.addAll([
      CustomerModel(
        id: 'KC-CUS-000101',
        firstName: 'Rahul',
        middleName: 'Kumar',
        lastName: 'Sharma',
        dateOfBirth: DateTime(1985, 4, 12),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98201 12345',
        alternateMobile: '+91 98201 99999',
        email: 'rahul.sharma@example.com',
        addressLine: 'Flat 402, Royal Palms, M.G. Road',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        occupation: 'Jewellery Trader / Business Owner',
        annualIncome: '₹ 15,000,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['VIP', 'Premium', 'Frequent Customer', 'High Value'],
        createdAt: now.subtract(const Duration(days: 420)),
        lastActivityAt: now.subtract(const Duration(hours: 3)),
        panNumberPlaceholder: 'ABCPS1234F',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-8821',
        activeLoansCount: 2,
        totalOutstandingAmount: 450000.0,
        totalInterestPaid: 68500.0,
        totalRepaidAmount: 950000.0,
        closedLoansCount: 3,
        notes: [
          CustomerNote(
            id: 'N-101',
            content: 'Client prefers 22K hallmarked bullion pledges. Always requests priority vault storage.',
            authorName: 'Arjun Mehta (Manager)',
            createdAt: now.subtract(const Duration(days: 30)),
            isPinned: true,
          ),
          CustomerNote(
            id: 'N-102',
            content: 'Verified original PAN card physically at Store 01.',
            authorName: 'Priya Nair (Staff)',
            createdAt: now.subtract(const Duration(days: 120)),
            isPinned: false,
          ),
        ],
        loans: [
          CustomerLoanSummary(
            loanId: 'KC-LN-9042',
            pledgeDate: now.subtract(const Duration(days: 45)),
            principalAmount: 250000.0,
            interestRatePercent: 11.5,
            outstandingAmount: 250000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 135)),
          ),
          CustomerLoanSummary(
            loanId: 'KC-LN-8812',
            pledgeDate: now.subtract(const Duration(days: 90)),
            principalAmount: 200000.0,
            interestRatePercent: 12.0,
            outstandingAmount: 200000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 90)),
          ),
        ],
        ornaments: [
          const CustomerOrnamentSummary(
            ornamentId: 'ORN-4401',
            type: 'Gold Necklace & Earrings Set',
            metal: 'Gold',
            purity: '22K (916)',
            grossWeightGrams: 78.5,
            netWeightGrams: 75.2,
            status: 'Pledged (Vault A-12)',
          ),
          const CustomerOrnamentSummary(
            ornamentId: 'ORN-4402',
            type: 'Gold Bangles (Set of 4)',
            metal: 'Gold',
            purity: '22K (916)',
            grossWeightGrams: 52.0,
            netWeightGrams: 52.0,
            status: 'Pledged (Vault A-12)',
          ),
        ],
        payments: [
          CustomerPaymentSummary(
            receiptNo: 'RCP-2026-081',
            date: now.subtract(const Duration(days: 5)),
            amount: 14250.0,
            paymentMethod: 'UPI',
            loanId: 'KC-LN-9042',
            status: 'Success',
          ),
          CustomerPaymentSummary(
            receiptNo: 'RCP-2026-042',
            date: now.subtract(const Duration(days: 35)),
            amount: 14250.0,
            paymentMethod: 'Bank Transfer',
            loanId: 'KC-LN-9042',
            status: 'Success',
          ),
        ],
        documents: [
          CustomerDocument(
            id: 'DOC-101',
            name: 'Aadhaar Card Front & Back',
            documentType: 'Identity / Address Proof',
            uploadDate: now.subtract(const Duration(days: 410)),
            status: 'Approved',
            isVerified: true,
          ),
          CustomerDocument(
            id: 'DOC-102',
            name: 'PAN Card Copy',
            documentType: 'KYC Identity',
            uploadDate: now.subtract(const Duration(days: 410)),
            status: 'Approved',
            isVerified: true,
          ),
        ],
        activities: [
          CustomerActivityItem(
            id: 'ACT-1',
            timestamp: now.subtract(const Duration(hours: 3)),
            actor: 'Rahul Sharma',
            eventType: 'Payment Received',
            description: 'Received ₹14,250 interest payment via UPI for Loan #KC-LN-9042.',
            icon: Icons.payments_rounded,
          ),
          CustomerActivityItem(
            id: 'ACT-2',
            timestamp: now.subtract(const Duration(days: 45)),
            actor: 'Arjun Mehta',
            eventType: 'Loan Created',
            description: 'Issued Gold Loan #KC-LN-9042 of ₹2,50,000.',
            icon: Icons.account_balance_rounded,
          ),
        ],
      ),
      CustomerModel(
        id: 'KC-CUS-000102',
        firstName: 'Sunita',
        lastName: 'Verma',
        dateOfBirth: DateTime(1990, 8, 24),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 97110 54321',
        email: 'sunita.verma@domain.in',
        addressLine: 'House No 12, Sector 15, Vasundhara',
        city: 'Noida',
        state: 'Uttar Pradesh',
        pincode: '201301',
        occupation: 'Software Consultant',
        annualIncome: '₹ 2,400,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Frequent Customer', 'Verified'],
        createdAt: now.subtract(const Duration(days: 200)),
        lastActivityAt: now.subtract(const Duration(days: 1)),
        panNumberPlaceholder: 'XYZPV9876K',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-4412',
        activeLoansCount: 1,
        totalOutstandingAmount: 180000.0,
        totalInterestPaid: 21600.0,
        totalRepaidAmount: 300000.0,
        closedLoansCount: 1,
        notes: [
          CustomerNote(
            id: 'N-201',
            content: 'Regular interest payments made via RTGS on the 1st of every month.',
            authorName: 'Anil Gupta',
            createdAt: now.subtract(const Duration(days: 60)),
            isPinned: false,
          ),
        ],
        loans: [
          CustomerLoanSummary(
            loanId: 'KC-LN-9104',
            pledgeDate: now.subtract(const Duration(days: 60)),
            principalAmount: 180000.0,
            interestRatePercent: 12.0,
            outstandingAmount: 180000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 120)),
          ),
        ],
        ornaments: [
          const CustomerOrnamentSummary(
            ornamentId: 'ORN-4410',
            type: 'Gold Kada (Pair)',
            metal: 'Gold',
            purity: '22K (916)',
            grossWeightGrams: 48.0,
            netWeightGrams: 48.0,
            status: 'Pledged (Vault B-04)',
          ),
        ],
        payments: [
          CustomerPaymentSummary(
            receiptNo: 'RCP-2026-079',
            date: now.subtract(const Duration(days: 1)),
            amount: 1800.0,
            paymentMethod: 'Bank Transfer',
            loanId: 'KC-LN-9104',
            status: 'Success',
          ),
        ],
        documents: [
          CustomerDocument(
            id: 'DOC-201',
            name: 'Passport Photo & KYC Slip',
            documentType: 'KYC Document',
            uploadDate: now.subtract(const Duration(days: 200)),
            status: 'Approved',
            isVerified: true,
          ),
        ],
        activities: [
          CustomerActivityItem(
            id: 'ACT-201',
            timestamp: now.subtract(const Duration(days: 1)),
            actor: 'Sunita Verma',
            eventType: 'Payment Received',
            description: 'Interest payment of ₹1,800 credited.',
            icon: Icons.payments_rounded,
          ),
        ],
      ),
      CustomerModel(
        id: 'KC-CUS-000103',
        firstName: 'Vikramaditya',
        middleName: 'Singh',
        lastName: 'Rathore',
        dateOfBirth: DateTime(1978, 11, 30),
        gender: 'Male',
        customerType: CustomerType.business,
        mobile: '+91 99887 66554',
        email: 'v.rathore@heritagejewels.co.in',
        addressLine: 'Rathore Haveli, City Palace Road',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302002',
        occupation: 'Antique Jewellery Exporter',
        annualIncome: '₹ 45,000,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['VIP', 'High Value', 'Business'],
        createdAt: now.subtract(const Duration(days: 500)),
        lastActivityAt: now.subtract(const Duration(hours: 12)),
        panNumberPlaceholder: 'AAACR1122M',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-9001',
        activeLoansCount: 3,
        totalOutstandingAmount: 1850000.0,
        totalInterestPaid: 320000.0,
        totalRepaidAmount: 4200000.0,
        closedLoansCount: 5,
        notes: [
          CustomerNote(
            id: 'N-301',
            content: 'High-value Kundan & Meenakari inventory pledged. Security protocol 4 required during inspection.',
            authorName: 'Arjun Mehta',
            createdAt: now.subtract(const Duration(days: 15)),
            isPinned: true,
          ),
        ],
        loans: [
          CustomerLoanSummary(
            loanId: 'KC-LN-8501',
            pledgeDate: now.subtract(const Duration(days: 110)),
            principalAmount: 850000.0,
            interestRatePercent: 10.5,
            outstandingAmount: 850000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 70)),
          ),
          CustomerLoanSummary(
            loanId: 'KC-LN-8620',
            pledgeDate: now.subtract(const Duration(days: 80)),
            principalAmount: 1000000.0,
            interestRatePercent: 10.5,
            outstandingAmount: 1000000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 100)),
          ),
        ],
        ornaments: [
          const CustomerOrnamentSummary(
            ornamentId: 'ORN-5001',
            type: 'Heritage Kundan Gold Necklace with Rubies',
            metal: 'Gold 22K + Gemstones',
            purity: '22K (916)',
            grossWeightGrams: 240.5,
            netWeightGrams: 195.0,
            status: 'Pledged (Vault High-Sec)',
          ),
        ],
        payments: [
          CustomerPaymentSummary(
            receiptNo: 'RCP-2026-012',
            date: now.subtract(const Duration(days: 10)),
            amount: 78500.0,
            paymentMethod: 'Bank Transfer',
            loanId: 'KC-LN-8620',
            status: 'Success',
          ),
        ],
        documents: [
          CustomerDocument(
            id: 'DOC-301',
            name: 'GST Registration Certificate',
            documentType: 'Business Proof',
            uploadDate: now.subtract(const Duration(days: 490)),
            status: 'Approved',
            isVerified: true,
          ),
        ],
        activities: [
          CustomerActivityItem(
            id: 'ACT-301',
            timestamp: now.subtract(const Duration(hours: 12)),
            actor: 'Vikramaditya Singh',
            eventType: 'Profile Updated',
            description: 'Updated business GST details and contact email.',
            icon: Icons.edit_note_rounded,
          ),
        ],
      ),
      CustomerModel(
        id: 'KC-CUS-000104',
        firstName: 'Priya',
        lastName: 'Patel',
        dateOfBirth: DateTime(1994, 2, 14),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 98980 11223',
        email: 'priya.patel94@gmail.com',
        addressLine: '14/B, Satellite Road, Opp Star Bazaar',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380015',
        occupation: 'Architect',
        annualIncome: '₹ 1,800,000 / Year',
        kycStatus: CustomerKycStatus.pending,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['New Customer', 'Pending Verification'],
        createdAt: now.subtract(const Duration(days: 5)),
        lastActivityAt: now.subtract(const Duration(hours: 2)),
        panNumberPlaceholder: 'BNPPP4321L',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-1190',
        activeLoansCount: 1,
        totalOutstandingAmount: 120000.0,
        totalInterestPaid: 0.0,
        totalRepaidAmount: 0.0,
        closedLoansCount: 0,
        notes: [
          CustomerNote(
            id: 'N-401',
            content: 'Aadhaar XML verification pending physically. Original submitted.',
            authorName: 'Deepak Patel',
            createdAt: now.subtract(const Duration(days: 2)),
            isPinned: true,
          ),
        ],
        loans: [
          CustomerLoanSummary(
            loanId: 'KC-LN-9210',
            pledgeDate: now.subtract(const Duration(days: 5)),
            principalAmount: 120000.0,
            interestRatePercent: 12.5,
            outstandingAmount: 120000.0,
            status: 'Active',
            dueDate: now.add(const Duration(days: 175)),
          ),
        ],
        ornaments: [
          const CustomerOrnamentSummary(
            ornamentId: 'ORN-4512',
            type: 'Gold Chain with Pendant',
            metal: 'Gold',
            purity: '22K (916)',
            grossWeightGrams: 32.5,
            netWeightGrams: 31.0,
            status: 'Pledged (Vault C-01)',
          ),
        ],
        payments: [],
        documents: [
          CustomerDocument(
            id: 'DOC-401',
            name: 'Aadhaar e-KYC Slip',
            documentType: 'Identity Proof',
            uploadDate: now.subtract(const Duration(days: 5)),
            status: 'Under Review',
            isVerified: false,
          ),
        ],
        activities: [
          CustomerActivityItem(
            id: 'ACT-401',
            timestamp: now.subtract(const Duration(days: 5)),
            actor: 'Priya Patel',
            eventType: 'Customer Created',
            description: 'Customer profile created and initial gold pledge submitted.',
            icon: Icons.person_add_alt_1_rounded,
          ),
        ],
      ),
      CustomerModel(
        id: 'KC-CUS-000105',
        firstName: 'Amitabh',
        lastName: 'Banerjee',
        dateOfBirth: DateTime(1968, 6, 19),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98300 44556',
        email: 'amitabh.banerjee@kolkatabiz.net',
        addressLine: '55 Park Street, 2nd Floor',
        city: 'Kolkata',
        state: 'West Bengal',
        pincode: '700016',
        occupation: 'Retired Professor',
        annualIncome: '₹ 1,200,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Senior Citizen', 'Verified'],
        createdAt: now.subtract(const Duration(days: 350)),
        lastActivityAt: now.subtract(const Duration(days: 4)),
        panNumberPlaceholder: 'AGPB1234M',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-6789',
        activeLoansCount: 0,
        totalOutstandingAmount: 0.0,
        totalInterestPaid: 45000.0,
        totalRepaidAmount: 500000.0,
        closedLoansCount: 2,
        notes: [],
        loans: [],
        ornaments: [],
        payments: [],
        documents: [],
        activities: [],
      ),
      CustomerModel(
        id: 'KC-CUS-000106',
        firstName: 'Meenakshi',
        lastName: 'Sundaram',
        dateOfBirth: DateTime(1982, 9, 10),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 94440 98765',
        email: 'meenakshi.s@chennaidesign.in',
        addressLine: '78 Anna Salai, T. Nagar',
        city: 'Chennai',
        state: 'Tamil Nadu',
        pincode: '600017',
        occupation: 'Textile Retailer',
        annualIncome: '₹ 3,200,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['VIP', 'High Value'],
        createdAt: now.subtract(const Duration(days: 180)),
        lastActivityAt: now.subtract(const Duration(hours: 6)),
        panNumberPlaceholder: 'CMSM5678P',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-3344',
        activeLoansCount: 1,
        totalOutstandingAmount: 350000.0,
        totalInterestPaid: 38000.0,
        totalRepaidAmount: 600000.0,
        closedLoansCount: 2,
      ),
      CustomerModel(
        id: 'KC-CUS-000107',
        firstName: 'Gurpreet',
        lastName: 'Singh',
        dateOfBirth: DateTime(1987, 12, 5),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98140 22334',
        email: 'gurpreet.singh@farmerscorp.in',
        addressLine: 'GT Road, Near Model Town',
        city: 'Ludhiana',
        state: 'Punjab',
        pincode: '141002',
        occupation: 'Agricultural Producer',
        annualIncome: '₹ 2,800,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['Frequent Customer'],
        createdAt: now.subtract(const Duration(days: 290)),
        lastActivityAt: now.subtract(const Duration(days: 2)),
        panNumberPlaceholder: 'GPSG7890Q',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-5566',
        activeLoansCount: 2,
        totalOutstandingAmount: 620000.0,
        totalInterestPaid: 72000.0,
        totalRepaidAmount: 1100000.0,
        closedLoansCount: 4,
      ),
      CustomerModel(
        id: 'KC-CUS-000108',
        firstName: 'Kavita',
        lastName: 'Rao',
        dateOfBirth: DateTime(1992, 7, 22),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 98450 77889',
        email: 'kavita.rao@techhub.com',
        addressLine: '100 Feet Road, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        occupation: 'Product Manager',
        annualIncome: '₹ 3,600,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Verified', 'VIP'],
        createdAt: now.subtract(const Duration(days: 150)),
        lastActivityAt: now.subtract(const Duration(hours: 1)),
        panNumberPlaceholder: 'KTRK1234S',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-9900',
        activeLoansCount: 1,
        totalOutstandingAmount: 150000.0,
        totalInterestPaid: 15000.0,
        totalRepaidAmount: 250000.0,
        closedLoansCount: 1,
      ),
      CustomerModel(
        id: 'KC-CUS-000109',
        firstName: 'Rajesh',
        lastName: 'Joshi',
        dateOfBirth: DateTime(1975, 3, 18),
        gender: 'Male',
        customerType: CustomerType.business,
        mobile: '+91 94250 11223',
        email: 'rjoshi@mpexports.com',
        addressLine: '34 MG Road, New Palasia',
        city: 'Indore',
        state: 'Madhya Pradesh',
        pincode: '452001',
        occupation: 'Grain Merchant',
        annualIncome: '₹ 5,000,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Business', 'High Value'],
        createdAt: now.subtract(const Duration(days: 600)),
        lastActivityAt: now.subtract(const Duration(days: 3)),
        panNumberPlaceholder: 'RJJS4567T',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-1234',
        activeLoansCount: 1,
        totalOutstandingAmount: 900000.0,
        totalInterestPaid: 140000.0,
        totalRepaidAmount: 2200000.0,
        closedLoansCount: 6,
      ),
      CustomerModel(
        id: 'KC-CUS-000110',
        firstName: 'Sneha',
        lastName: 'Kulkarni',
        dateOfBirth: DateTime(1989, 10, 8),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 98220 33445',
        email: 'sneha.k@punedesign.co',
        addressLine: 'F-12, FC Road, Shivaji Nagar',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411005',
        occupation: 'Interior Designer',
        annualIncome: '₹ 2,100,000 / Year',
        kycStatus: CustomerKycStatus.incomplete,
        customerStatus: CustomerStatus.inactive,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['Incomplete KYC'],
        createdAt: now.subtract(const Duration(days: 90)),
        lastActivityAt: now.subtract(const Duration(days: 45)),
        panNumberPlaceholder: 'SNKK8901U',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-5678',
        activeLoansCount: 0,
        totalOutstandingAmount: 0.0,
        totalInterestPaid: 0.0,
        totalRepaidAmount: 0.0,
        closedLoansCount: 0,
      ),
      CustomerModel(
        id: 'KC-CUS-000111',
        firstName: 'Tariq',
        lastName: 'Ahmed',
        dateOfBirth: DateTime(1983, 1, 25),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98490 66778',
        email: 'tariq.ahmed@hydbiz.org',
        addressLine: '89 Banjara Hills, Road No 12',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500034',
        occupation: 'Real Estate Developer',
        annualIncome: '₹ 8,500,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['VIP', 'High Value'],
        createdAt: now.subtract(const Duration(days: 310)),
        lastActivityAt: now.subtract(const Duration(hours: 5)),
        panNumberPlaceholder: 'TAHA2345V',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-9012',
        activeLoansCount: 2,
        totalOutstandingAmount: 1200000.0,
        totalInterestPaid: 180000.0,
        totalRepaidAmount: 3100000.0,
        closedLoansCount: 4,
      ),
      CustomerModel(
        id: 'KC-CUS-000112',
        firstName: 'Ananya',
        lastName: 'Deshmukh',
        dateOfBirth: DateTime(1996, 5, 17),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 97650 44332',
        email: 'ananya.d@fintech.io',
        addressLine: '22 Residency Road',
        city: 'Nagpur',
        state: 'Maharashtra',
        pincode: '440001',
        occupation: 'Financial Analyst',
        annualIncome: '₹ 1,500,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Verified'],
        createdAt: now.subtract(const Duration(days: 80)),
        lastActivityAt: now.subtract(const Duration(days: 3)),
        panNumberPlaceholder: 'ANDD6789W',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-3456',
        activeLoansCount: 1,
        totalOutstandingAmount: 85000.0,
        totalInterestPaid: 7650.0,
        totalRepaidAmount: 100000.0,
        closedLoansCount: 1,
      ),
      CustomerModel(
        id: 'KC-CUS-000113',
        firstName: 'Manish',
        lastName: 'Agarwal',
        dateOfBirth: DateTime(1979, 12, 14),
        gender: 'Male',
        customerType: CustomerType.business,
        mobile: '+91 98100 55443',
        email: 'magarwal@delhisteel.com',
        addressLine: '101 Connaught Place, Block C',
        city: 'New Delhi',
        state: 'Delhi',
        pincode: '110001',
        occupation: 'Wholesale Metals Distributer',
        annualIncome: '₹ 12,000,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['Business', 'VIP'],
        createdAt: now.subtract(const Duration(days: 400)),
        lastActivityAt: now.subtract(const Duration(days: 1)),
        panNumberPlaceholder: 'MNAG1234X',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-7890',
        activeLoansCount: 2,
        totalOutstandingAmount: 1600000.0,
        totalInterestPaid: 210000.0,
        totalRepaidAmount: 2500000.0,
        closedLoansCount: 3,
      ),
      CustomerModel(
        id: 'KC-CUS-000114',
        firstName: 'Pooja',
        lastName: 'Nambiar',
        dateOfBirth: DateTime(1991, 3, 29),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 94470 11998',
        email: 'pooja.nambiar@cochinport.in',
        addressLine: '15 Marine Drive',
        city: 'Kochi',
        state: 'Kerala',
        pincode: '682031',
        occupation: 'Maritime Logistics Lead',
        annualIncome: '₹ 2,200,000 / Year',
        kycStatus: CustomerKycStatus.rejected,
        customerStatus: CustomerStatus.blocked,
        riskStatus: CustomerRiskLevel.high,
        tags: ['Watchlist', 'High Risk', 'Blocked'],
        createdAt: now.subtract(const Duration(days: 120)),
        lastActivityAt: now.subtract(const Duration(days: 15)),
        panNumberPlaceholder: 'PJNM5678Y',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-1122',
        activeLoansCount: 0,
        totalOutstandingAmount: 0.0,
        totalInterestPaid: 0.0,
        totalRepaidAmount: 0.0,
        closedLoansCount: 0,
        notes: [
          CustomerNote(
            id: 'N-999',
            content: 'Pan verification failed discrepancy in name. Account flagged and blocked by Compliance Officer.',
            authorName: 'Compliance Officer (Admin)',
            createdAt: now.subtract(const Duration(days: 15)),
            isPinned: true,
          ),
        ],
      ),
      CustomerModel(
        id: 'KC-CUS-000115',
        firstName: 'Harish',
        lastName: 'Chawla',
        dateOfBirth: DateTime(1972, 8, 11),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98180 33221',
        email: 'harish.chawla@ncrtraders.com',
        addressLine: '56 Golf Course Road',
        city: 'Gurugram',
        state: 'Haryana',
        pincode: '122002',
        occupation: 'Automobile Franchise Owner',
        annualIncome: '₹ 6,500,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['High Value'],
        createdAt: now.subtract(const Duration(days: 270)),
        lastActivityAt: now.subtract(const Duration(hours: 18)),
        panNumberPlaceholder: 'HRCW9012Z',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-5544',
        activeLoansCount: 1,
        totalOutstandingAmount: 500000.0,
        totalInterestPaid: 55000.0,
        totalRepaidAmount: 800000.0,
        closedLoansCount: 2,
      ),
      CustomerModel(
        id: 'KC-CUS-000116',
        firstName: 'Deepika',
        lastName: 'Reddy',
        dateOfBirth: DateTime(1995, 11, 3),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 99000 88776',
        email: 'd.reddy@vizagtech.com',
        addressLine: '44 Beach Road, Maharani Peta',
        city: 'Visakhapatnam',
        state: 'Andhra Pradesh',
        pincode: '530002',
        occupation: 'Software Engineer',
        annualIncome: '₹ 1,600,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.archived,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Archived', 'Inactive Loan'],
        createdAt: now.subtract(const Duration(days: 700)),
        lastActivityAt: now.subtract(const Duration(days: 180)),
        panNumberPlaceholder: 'DPRD3456A',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-7788',
        activeLoansCount: 0,
        totalOutstandingAmount: 0.0,
        totalInterestPaid: 18500.0,
        totalRepaidAmount: 150000.0,
        closedLoansCount: 1,
      ),
      CustomerModel(
        id: 'KC-CUS-000117',
        firstName: 'Siddharth',
        lastName: 'Tripathi',
        dateOfBirth: DateTime(1986, 4, 30),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 94150 99887',
        email: 'stripathi@lucknowlegal.in',
        addressLine: '12 Hazratganj Road',
        city: 'Lucknow',
        state: 'Uttar Pradesh',
        pincode: '226001',
        occupation: 'Advocate',
        annualIncome: '₹ 2,700,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Verified'],
        createdAt: now.subtract(const Duration(days: 210)),
        lastActivityAt: now.subtract(const Duration(days: 2)),
        panNumberPlaceholder: 'SDTR7890B',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-2233',
        activeLoansCount: 1,
        totalOutstandingAmount: 210000.0,
        totalInterestPaid: 21000.0,
        totalRepaidAmount: 400000.0,
        closedLoansCount: 2,
      ),
      CustomerModel(
        id: 'KC-CUS-000118',
        firstName: 'Divya',
        lastName: 'Bhatt',
        dateOfBirth: DateTime(1993, 1, 15),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 98370 22110',
        email: 'divya.bhatt@rajpurtech.com',
        addressLine: '89 Rajpur Road',
        city: 'Dehradun',
        state: 'Uttarakhand',
        pincode: '248001',
        occupation: 'E-commerce Entrepreneur',
        annualIncome: '₹ 2,000,000 / Year',
        kycStatus: CustomerKycStatus.pending,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.medium,
        tags: ['New Customer'],
        createdAt: now.subtract(const Duration(days: 10)),
        lastActivityAt: now.subtract(const Duration(hours: 4)),
        panNumberPlaceholder: 'DVBH1234C',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-6677',
        activeLoansCount: 1,
        totalOutstandingAmount: 95000.0,
        totalInterestPaid: 0.0,
        totalRepaidAmount: 0.0,
        closedLoansCount: 0,
      ),
      CustomerModel(
        id: 'KC-CUS-000119',
        firstName: 'Nilesh',
        lastName: 'Gaikwad',
        dateOfBirth: DateTime(1980, 9, 27),
        gender: 'Male',
        customerType: CustomerType.individual,
        mobile: '+91 98230 77665',
        email: 'nilesh.gaikwad@nasikwine.in',
        addressLine: '67 Gangapur Road',
        city: 'Nashik',
        state: 'Maharashtra',
        pincode: '422005',
        occupation: 'Vineyard Owner',
        annualIncome: '₹ 4,200,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Frequent Customer', 'Verified'],
        createdAt: now.subtract(const Duration(days: 380)),
        lastActivityAt: now.subtract(const Duration(hours: 10)),
        panNumberPlaceholder: 'NLGK5678D',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-8899',
        activeLoansCount: 2,
        totalOutstandingAmount: 780000.0,
        totalInterestPaid: 95000.0,
        totalRepaidAmount: 1400000.0,
        closedLoansCount: 3,
      ),
      CustomerModel(
        id: 'KC-CUS-000120',
        firstName: 'Shruti',
        lastName: 'Mishra',
        dateOfBirth: DateTime(1997, 12, 1),
        gender: 'Female',
        customerType: CustomerType.individual,
        mobile: '+91 97520 88990',
        email: 'shruti.mishra@bhopaltech.in',
        addressLine: '12 Arera Colony',
        city: 'Bhopal',
        state: 'Madhya Pradesh',
        pincode: '462016',
        occupation: 'Data Scientist',
        annualIncome: '₹ 1,900,000 / Year',
        kycStatus: CustomerKycStatus.verified,
        customerStatus: CustomerStatus.active,
        riskStatus: CustomerRiskLevel.low,
        tags: ['Verified'],
        createdAt: now.subtract(const Duration(days: 60)),
        lastActivityAt: now.subtract(const Duration(days: 1)),
        panNumberPlaceholder: 'SRMS9012E',
        aadhaarNumberPlaceholder: 'XXXX-XXXX-4455',
        activeLoansCount: 1,
        totalOutstandingAmount: 110000.0,
        totalInterestPaid: 11000.0,
        totalRepaidAmount: 150000.0,
        closedLoansCount: 1,
      ),
    ]);
  }

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    CustomerFilterParams? filters,
    CustomerSortOption? sortOption,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<CustomerModel> result = List.of(_customers);

    // 1. Search Query Filter
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q) ||
            c.mobile.replaceAll(' ', '').contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.panNumberPlaceholder.toLowerCase().contains(q) ||
            c.aadhaarNumberPlaceholder.replaceAll('-', '').contains(q) ||
            c.loans.any((l) => l.loanId.toLowerCase().contains(q));
      });
    }

    // 2. Filter Parameters
    if (filters != null) {
      if (filters.kycStatus != null) {
        result = result.where((c) => c.kycStatus == filters.kycStatus);
      }
      if (filters.customerStatus != null) {
        result = result.where((c) => c.customerStatus == filters.customerStatus);
      }
      if (filters.hasActiveLoans != null) {
        if (filters.hasActiveLoans!) {
          result = result.where((c) => c.activeLoansCount > 0);
        } else {
          result = result.where((c) => c.activeLoansCount == 0);
        }
      }
      if (filters.customerType != null) {
        result = result.where((c) => c.customerType == filters.customerType);
      }
      if (filters.riskLevel != null) {
        result = result.where((c) => c.riskStatus == filters.riskLevel);
      }
    }

    // 3. Sorting
    final list = result.toList();
    final sort = sortOption ?? CustomerSortOption.newest;

    switch (sort) {
      case CustomerSortOption.nameAsc:
        list.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case CustomerSortOption.nameDesc:
        list.sort((a, b) => b.fullName.compareTo(a.fullName));
        break;
      case CustomerSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CustomerSortOption.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CustomerSortOption.outstandingDesc:
        list.sort((a, b) => b.totalOutstandingAmount.compareTo(a.totalOutstandingAmount));
        break;
      case CustomerSortOption.activeLoansDesc:
        list.sort((a, b) => b.activeLoansCount.compareTo(a.activeLoansCount));
        break;
      case CustomerSortOption.lastActivity:
        list.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
        break;
      case CustomerSortOption.riskLevel:
        list.sort((a, b) => b.riskStatus.index.compareTo(a.riskStatus.index));
        break;
    }

    return list;
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel newCustomer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final nextIdNum = 100 + _customers.length + 1;
    final generatedId = 'KC-CUS-000$nextIdNum';

    final created = newCustomer.copyWith(
      id: generatedId,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      kycStatus: CustomerKycStatus.pending,
      customerStatus: CustomerStatus.active,
      activities: [
        CustomerActivityItem(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'Current User',
          eventType: 'Customer Created',
          description: 'New customer account initialized in system.',
          icon: Icons.person_add_alt_1_rounded,
        ),
      ],
    );

    _customers.insert(0, created);
    return created;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel updatedCustomer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
    if (index != -1) {
      final newActivities = List<CustomerActivityItem>.from(updatedCustomer.activities);
      newActivities.insert(
        0,
        CustomerActivityItem(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'Current User',
          eventType: 'Profile Updated',
          description: 'Updated customer information and contact details.',
          icon: Icons.edit_note_rounded,
        ),
      );

      final result = updatedCustomer.copyWith(
        lastActivityAt: DateTime.now(),
        activities: newActivities,
      );
      _customers[index] = result;
      return result;
    }
    return updatedCustomer;
  }

  @override
  Future<CustomerModel> updateCustomerStatus(String id, CustomerStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      final existing = _customers[index];
      final newActivities = List<CustomerActivityItem>.from(existing.activities);
      newActivities.insert(
        0,
        CustomerActivityItem(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'Compliance System',
          eventType: 'Status Changed',
          description: 'Customer status updated to ${status.label}.',
          icon: status.icon,
        ),
      );

      final updated = existing.copyWith(
        customerStatus: status,
        lastActivityAt: DateTime.now(),
        activities: newActivities,
      );
      _customers[index] = updated;
      return updated;
    }
    throw Exception('Customer not found');
  }

  @override
  Future<CustomerModel> archiveCustomer(String id) async {
    return updateCustomerStatus(id, CustomerStatus.archived);
  }

  @override
  Future<CustomerModel> restoreCustomer(String id) async {
    return updateCustomerStatus(id, CustomerStatus.active);
  }

  @override
  Future<CustomerModel> addCustomerNote(String customerId, String noteContent, String authorName) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final existing = _customers[index];
      final newNotes = List<CustomerNote>.from(existing.notes);
      final newNote = CustomerNote(
        id: 'N-${DateTime.now().millisecondsSinceEpoch}',
        content: noteContent,
        authorName: authorName,
        createdAt: DateTime.now(),
        isPinned: false,
      );
      newNotes.insert(0, newNote);

      final updated = existing.copyWith(
        notes: newNotes,
        lastActivityAt: DateTime.now(),
      );
      _customers[index] = updated;
      return updated;
    }
    throw Exception('Customer not found');
  }

  @override
  Future<CustomerModel> togglePinCustomerNote(String customerId, String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final existing = _customers[index];
      final updatedNotes = existing.notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(isPinned: !n.isPinned);
        }
        return n;
      }).toList();

      final updated = existing.copyWith(notes: updatedNotes);
      _customers[index] = updated;
      return updated;
    }
    throw Exception('Customer not found');
  }

  @override
  Future<CustomerModel> deleteCustomerNote(String customerId, String noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final existing = _customers[index];
      final updatedNotes = existing.notes.where((n) => n.id != noteId).toList();
      final updated = existing.copyWith(notes: updatedNotes);
      _customers[index] = updated;
      return updated;
    }
    throw Exception('Customer not found');
  }
}
