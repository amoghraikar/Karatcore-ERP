import 'package:equatable/equatable.dart';

class BranchModel extends Equatable {
  const BranchModel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.status,
    required this.lastAccessed,
    required this.isMainBranch,
  });

  final String id;
  final String name;
  final String location;
  final String city;
  final String status;
  final String lastAccessed;
  final bool isMainBranch;

  static const List<BranchModel> mockBranches = [
    BranchModel(
      id: 'BR-001',
      name: 'Main Branch (Bandra)',
      location: 'Turner Road, Bandra West',
      city: 'Mumbai',
      status: 'Active / Open',
      lastAccessed: 'Just now',
      isMainBranch: true,
    ),
    BranchModel(
      id: 'BR-002',
      name: 'Downtown Branch (Zaveri Bazaar)',
      location: 'Jewellers Hub, Zaveri Bazaar',
      city: 'Mumbai',
      status: 'Active / Open',
      lastAccessed: '2 hours ago',
      isMainBranch: false,
    ),
    BranchModel(
      id: 'BR-003',
      name: 'City Centre Branch (Chandni Chowk)',
      location: 'Dariba Kalan, Chandni Chowk',
      city: 'Delhi',
      status: 'Active / Open',
      lastAccessed: 'Yesterday',
      isMainBranch: false,
    ),
  ];

  @override
  List<Object?> get props => [id, name, location, city, status, lastAccessed, isMainBranch];
}
