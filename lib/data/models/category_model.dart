import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Convert model to domain entity
  factory CategoryModel.fromDomain(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
    );
  }

  // Convert to domain entity
  Category toDomain() {
    return Category(
      id: id,
      name: name,
    );
  }
}
