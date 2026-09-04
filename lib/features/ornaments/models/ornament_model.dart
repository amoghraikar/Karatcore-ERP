import 'package:flutter/material.dart';

enum MetalType {
  gold('Gold', Icons.savings_rounded, Color(0xFFD97706)),
  silver('Silver', Icons.monetization_on_rounded, Color(0xFF6B7280)),
  platinum('Platinum', Icons.diamond_rounded, Color(0xFF2563EB)),
  other('Other Metal', Icons.category_rounded, Color(0xFF8B5CF6));

  const MetalType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum OrnamentPurity {
  k24_999('24K / 999', 'Fine Pure Gold (99.9%)', 0.999),
  k22_916('22K / 916', 'Standard Jewellery Gold (91.6%)', 0.916),
  k20('20K / 833', 'Traditional Gold (83.3%)', 0.833),
  k18_750('18K / 750', 'Diamond Jewellery Gold (75.0%)', 0.750),
  k14_585('14K / 585', 'Studded Jewellery Gold (58.5%)', 0.585),
  silver999('Silver 999', 'Fine Pure Silver (99.9%)', 0.999),
  silver925('Silver 925', 'Sterling Silver (92.5%)', 0.925),
  other('Custom Purity', 'Other alloy composition', 0.800);

  const OrnamentPurity(this.label, this.description, this.purityRatio);
  final String label;
  final String description;
  final double purityRatio;
}

enum OrnamentCategory {
  rings('Rings', Icons.circle_outlined, 'assets/images/jewellery_ring.jpg'),
  necklaces('Necklaces', Icons.auto_awesome_rounded, 'assets/images/jewellery_necklace.jpg'),
  chains('Chains', Icons.link_rounded, 'assets/images/jewellery_chain.jpg'),
  bracelets('Bracelets', Icons.adjust_rounded, 'assets/images/jewellery_bangle.jpg'),
  bangles('Bangles', Icons.panorama_fish_eye_rounded, 'assets/images/jewellery_bangle.jpg'),
  earrings('Earrings', Icons.flare_rounded, 'assets/images/jewellery_earrings.jpg'),
  pendants('Pendants', Icons.turned_in_not_rounded, 'assets/images/jewellery_necklace.jpg'),
  coins('Coins', Icons.toll_rounded, 'assets/images/jewellery_coin.jpg'),
  bars('Bullion Bars', Icons.crop_portrait_rounded, 'assets/images/jewellery_coin.jpg'),
  sets('Jewellery Sets', Icons.collections_rounded, 'assets/images/luxury_jewellery_hero.jpg'),
  other('Other Ornaments', Icons.widgets_rounded, 'assets/images/gold_inspection_hero.jpg');

  const OrnamentCategory(this.label, this.icon, this.assetImage);
  final String label;
  final IconData icon;
  final String assetImage;
}

enum OrnamentStatus {
  available('Available', Icons.check_circle_rounded, Color(0xFF059669), 'In store vault ready for sale or pledge.'),
  reserved('Reserved', Icons.bookmark_rounded, Color(0xFFD97706), 'Hold for customer order or booking.'),
  pledged('Pledged', Icons.lock_rounded, Color(0xFF2563EB), 'Pledged as security for an active gold loan.'),
  released('Released', Icons.key_rounded, Color(0xFF0D9488), 'Released back to customer upon loan settlement.'),
  sold('Sold', Icons.shopping_bag_rounded, Color(0xFF4F46E5), 'Sold to customer.'),
  transferred('Transferred', Icons.sync_alt_rounded, Color(0xFF8B5CF6), 'In transit between branch vaults.'),
  damaged('Damaged', Icons.warning_amber_rounded, Color(0xFFDC2626), 'Requires repair or melting audit.'),
  archived('Archived', Icons.archive_rounded, Color(0xFF6B7280), 'Archived record.');

  const OrnamentStatus(this.label, this.icon, this.color, this.description);
  final String label;
  final IconData icon;
  final Color color;
  final String description;
}

enum OwnershipType {
  shopOwned('Shop Inventory', Icons.store_rounded),
  customerOwned('Customer Owned', Icons.person_rounded),
  pledged('Pledged Asset', Icons.shield_rounded),
  consignment('Consignment', Icons.handshake_rounded),
  other('Other', Icons.help_outline_rounded);

  const OwnershipType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum MovementType {
  received('Received into Inventory', Icons.login_rounded),
  transferred('Transferred Vault Location', Icons.sync_alt_rounded),
  reserved('Reserved Item', Icons.bookmark_added_rounded),
  pledged('Pledged for Gold Loan', Icons.lock_rounded),
  released('Released to Customer', Icons.key_rounded),
  sold('Sold to Customer', Icons.shopping_cart_rounded),
  returned('Returned from Customer', Icons.undo_rounded),
  damaged('Marked Damaged / Melting', Icons.report_problem_rounded),
  archived('Archived Record', Icons.archive_rounded);

  const MovementType(this.label, this.icon);
  final String label;
  final IconData icon;
}

class WeightBreakdown {
  const WeightBreakdown({
    required this.grossWeight,
    this.stoneWeight = 0.0,
    this.otherWeight = 0.0,
  });

  final double grossWeight; // in grams
  final double stoneWeight; // in grams
  final double otherWeight; // in grams

  double get netMetalWeight {
    final net = grossWeight - stoneWeight - otherWeight;
    return net > 0 ? net : 0.0;
  }
}

class ValuationBreakdown {
  const ValuationBreakdown({
    required this.metalRate, // INR per gram
    required this.metalValue,
    this.makingCharges = 0.0,
    this.stoneValue = 0.0,
    this.otherCharges = 0.0,
    required this.totalEstimatedValue,
  });

  final double metalRate;
  final double metalValue;
  final double makingCharges;
  final double stoneValue;
  final double otherCharges;
  final double totalEstimatedValue;
}

class InventoryLocationModel {
  const InventoryLocationModel({
    required this.branch,
    required this.storageArea,
    required this.locker,
    this.shelf = 'Shelf A1',
    this.tray = 'Tray #01',
  });

  final String branch;
  final String storageArea; // Main Vault, Retail Display, Holding Safe
  final String locker; // Locker 01, Vault A
  final String shelf;
  final String tray;

  String get fullLocationPath => '$branch / $storageArea / $locker / $tray';
}

class InventoryMovementModel {
  const InventoryMovementModel({
    required this.id,
    required this.date,
    required this.type,
    required this.fromLocation,
    required this.toLocation,
    required this.actorName,
    required this.reason,
    required this.status,
    this.notes = '',
  });

  final String id;
  final DateTime date;
  final MovementType type;
  final String fromLocation;
  final String toLocation;
  final String actorName;
  final String reason;
  final String status;
  final String notes;
}

class OrnamentDocumentModel {
  const OrnamentDocumentModel({
    required this.id,
    required this.name,
    required this.type, // Hallmark Certificate, Purchase Bill, Purity Audit
    required this.uploadDate,
    required this.uploadedBy,
    this.url = '',
  });

  final String id;
  final String name;
  final String type;
  final DateTime uploadDate;
  final String uploadedBy;
  final String url;
}

class OrnamentAuditLog {
  const OrnamentAuditLog({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.action,
    required this.description,
    required this.location,
    this.relatedRecord = '',
  });

  final String id;
  final DateTime timestamp;
  final String actorName;
  final String action;
  final String description;
  final String location;
  final String relatedRecord;
}

class OrnamentModel {
  const OrnamentModel({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory = 'General',
    this.description = '',
    required this.metalType,
    required this.purity,
    required this.weight,
    required this.valuation,
    required this.status,
    required this.ownershipType,
    this.ownerCustomerId,
    this.ownerCustomerName,
    this.ownerKycStatus = 'Verified',
    this.pledgeLoanId,
    required this.location,
    this.barcode = '8901234567890',
    this.qrCode = 'QR-ORN-000101',
    this.imageUrl = 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f',
    this.additionalImages = const [],
    this.tags = const ['22K', 'Hallmarked', 'Pledged'],
    this.documents = const [],
    this.movements = const [],
    this.auditLogs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final OrnamentCategory category;
  final String subcategory;
  final String description;
  final MetalType metalType;
  final OrnamentPurity purity;
  final WeightBreakdown weight;
  final ValuationBreakdown valuation;
  final OrnamentStatus status;
  final OwnershipType ownershipType;
  final String? ownerCustomerId;
  final String? ownerCustomerName;
  final String ownerKycStatus;
  final String? pledgeLoanId;
  final InventoryLocationModel location;
  final String barcode;
  final String qrCode;
  final String imageUrl;
  final List<String> additionalImages;
  final List<String> tags;
  final List<OrnamentDocumentModel> documents;
  final List<InventoryMovementModel> movements;
  final List<OrnamentAuditLog> auditLogs;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrnamentModel copyWith({
    String? id,
    String? name,
    OrnamentCategory? category,
    String? subcategory,
    String? description,
    MetalType? metalType,
    OrnamentPurity? purity,
    WeightBreakdown? weight,
    ValuationBreakdown? valuation,
    OrnamentStatus? status,
    OwnershipType? ownershipType,
    String? ownerCustomerId,
    String? ownerCustomerName,
    String? ownerKycStatus,
    String? pledgeLoanId,
    InventoryLocationModel? location,
    String? barcode,
    String? qrCode,
    String? imageUrl,
    List<String>? additionalImages,
    List<String>? tags,
    List<OrnamentDocumentModel>? documents,
    List<InventoryMovementModel>? movements,
    List<OrnamentAuditLog>? auditLogs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrnamentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      metalType: metalType ?? this.metalType,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      valuation: valuation ?? this.valuation,
      status: status ?? this.status,
      ownershipType: ownershipType ?? this.ownershipType,
      ownerCustomerId: ownerCustomerId ?? this.ownerCustomerId,
      ownerCustomerName: ownerCustomerName ?? this.ownerCustomerName,
      ownerKycStatus: ownerKycStatus ?? this.ownerKycStatus,
      pledgeLoanId: pledgeLoanId ?? this.pledgeLoanId,
      location: location ?? this.location,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      tags: tags ?? this.tags,
      documents: documents ?? this.documents,
      movements: movements ?? this.movements,
      auditLogs: auditLogs ?? this.auditLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
