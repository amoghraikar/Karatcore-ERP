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

  @override
  List<Object?> get props => [id, name, location, city, status, lastAccessed, isMainBranch];

  static final List<BranchModel> defaultBranches = [
    const BranchModel(
      id: 'MAIN-STORE',
      name: 'Main Store (Primary)',
      location: 'Main Market',
      city: 'Headquarters',
      status: 'Active',
      lastAccessed: 'Just now',
      isMainBranch: true,
    ),
  ];
}
