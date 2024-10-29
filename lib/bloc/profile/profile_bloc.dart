// import 'dart:io';

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pm1_task_management/models/user_model.dart';
// import 'package:path/path.dart' as path;

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final CollectionReference<Map<String, dynamic>> users;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  ProfileBloc({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance,
        users = (firestore ?? FirebaseFirestore.instance).collection('users'),
        super(ProfileStateInitial()) {
    on<ProfileEventGet>(_onGetProfile);
    on<ProfileEventUpdateName>(_onUpdateName);
    on<ProfileEventPickedImage>((event, emit) async {
      try {
        final dataImage = await _picker.pickImage(source: ImageSource.gallery);
        if (dataImage != null) {
          pickedImage = dataImage;
          emit(ProfileStatePickedImage(image: pickedImage!));
        }
      } catch (e) {
        pickedImage = null;
        emit(ProfileStateError(message: 'Image tidak ditemukan'));
      }
    });
  }

  Future<void> _onGetProfile(
      ProfileEventGet event, Emitter<ProfileState> emit) async {
    if (event.uid.isEmpty) {
      emit(ProfileStateError(message: 'UID tidak boleh kosong'));
      return;
    }

    try {
      emit(ProfileStateLoading());

      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await users.doc(event.uid).get();

      final userData = userDoc.data();
      if (userData != null) {
        emit(ProfileStateLoaded(UserModel.fromJson(userData)));
      } else {
        emit(ProfileStateError(message: 'User tidak ditemukan'));
      }
    } on FirebaseException catch (e) {
      emit(ProfileStateError(
          message: e.message ?? 'Terjadi kesalahan pada Firebase'));
    } catch (e) {
      emit(ProfileStateError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateName(
      ProfileEventUpdateName event, Emitter<ProfileState> emit) async {
    if (event.name.isEmpty) {
      emit(ProfileStateError(message: 'Nama tidak boleh kosong'));
      return;
    }

    try {
      emit(ProfileStateLoading());

      await users.doc(event.uid).update({'name': event.name});
      emit(ProfileStateNameUpdated());
      Reference storageRef = storage.ref("users/${event.uid}.jpg");

      await storageRef.putFile(event.file!);
      var photo = await storageRef.getDownloadURL();
      await firestore.collection('users').doc(event.uid).set({
        "photoUrl" : photo,
        "name" : event.name,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      emit(ProfileStateError(
          message: e.message ?? 'Terjadi kesalahan pada Firebase'));
    } catch (e) {
      emit(ProfileStateError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
