import 'package:equatable/equatable.dart';
import 'package:pm1_task_management/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String id; // Document ID

  DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}
