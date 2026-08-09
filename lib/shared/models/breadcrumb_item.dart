import 'package:equatable/equatable.dart';

class BreadcrumbItem extends Equatable {
  const BreadcrumbItem({required this.label, this.path});
  final String label;
  final String? path;

  @override
  List<Object?> get props => [label, path];
}
