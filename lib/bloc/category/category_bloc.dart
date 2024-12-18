import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pm1_task_management/bloc/category/category_event.dart';
import 'package:pm1_task_management/bloc/category/category_state.dart';
import 'package:pm1_task_management/models/category_model.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CategoryBloc() : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
      FetchCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final snapshot = await _firestore.collection('categories').get();
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
  try {
    final docRef = await _firestore.collection('categories').add(
          event.category.toFirestore(),
        );
    await docRef.update({'uid': docRef.id});
    add(FetchCategories());
  } catch (e) {
    emit(CategoryError(e.toString()));
  }
}

Future<void> _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
  try {
    await _firestore.collection('categories').doc(event.category.id).update(
      event.category.toFirestore(),
    );
    add(FetchCategories());
  } catch (e) {
    emit(CategoryError(e.toString()));
  }
}

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _firestore.collection('categories').doc(event.id).delete();
      add(FetchCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
