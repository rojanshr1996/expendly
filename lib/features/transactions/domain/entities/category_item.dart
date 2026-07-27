import 'package:equatable/equatable.dart';
import '../../../../core/database/enums/database_enums.dart';

class CategoryItem extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String colorHex;
  final TransactionType type;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, colorHex, type];
}
