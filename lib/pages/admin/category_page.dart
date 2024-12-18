import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pm1_task_management/bloc/category/category_bloc.dart';
import 'package:pm1_task_management/bloc/category/category_event.dart';
import 'package:pm1_task_management/bloc/category/category_state.dart';
import 'package:pm1_task_management/models/category_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(FetchCategories()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories'),
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              final categories = state.categories;
              if (categories.isEmpty) {
                return const Center(child: Text('No categories available.'));
              }
              return ListView.builder(
                itemCount: categories.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: category.imageUrl.isNotEmpty
                          ? Image.network(category.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'UID: ${category.uid}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditCategoryDialog(context, category);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<CategoryBloc>().add(DeleteCategory(category.id));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is CategoryError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            pickedImage == null
                ? const Icon(Icons.image, size: 50)
                : Image.file(File(pickedImage!.path), width: 50, height: 50, fit: BoxFit.cover),
            TextButton(
              onPressed: () async {
                pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
              },
              child: const Text('Pick an image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isNotEmpty && pickedImage != null) {
                // Upload image to Firebase Storage
                final storageRef = FirebaseStorage.instance.ref().child('categories/${DateTime.now().toString()}');
                final uploadTask = storageRef.putFile(File(pickedImage!.path));
                final snapshot = await uploadTask.whenComplete(() {});
                final imageUrl = await snapshot.ref.getDownloadURL();

                // Create category with image URL
                final category = CategoryModel(
                  id: '',
                  name: name,
                  uid: '',
                  imageUrl: imageUrl,
                );

                context.read<CategoryBloc>().add(AddCategory(category));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            pickedImage == null
                ? Image.network(category.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : Image.file(File(pickedImage!.path), width: 50, height: 50, fit: BoxFit.cover),
            TextButton(
              onPressed: () async {
                pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
              },
              child: const Text('Pick an image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedName = nameController.text.trim();

              if (updatedName.isNotEmpty) {
                String imageUrl = category.imageUrl;

                if (pickedImage != null) {
                  // Upload new image to Firebase Storage
                  final storageRef = FirebaseStorage.instance.ref().child('categories/${DateTime.now().toString()}');
                  final uploadTask = storageRef.putFile(File(pickedImage!.path));
                  final snapshot = await uploadTask.whenComplete(() {});
                  imageUrl = await snapshot.ref.getDownloadURL();
                }

                final updatedCategory = CategoryModel(
                  id: category.id,
                  name: updatedName,
                  uid: category.uid,
                  imageUrl: imageUrl,
                );
                context.read<CategoryBloc>().add(UpdateCategory(updatedCategory));
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
