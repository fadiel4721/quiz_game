import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:pm1_task_management/models/user_model.dart';
import 'package:path/path.dart' as path;

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final CollectionReference<Map<String, dynamic>> users;

  ProfileBloc({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance,
        users = (firestore ?? FirebaseFirestore.instance).collection('users'),
        super(ProfileStateInitial()) {
    on<ProfileEventGet>(_onGetProfile);
    on<ProfileEventUpdateName>(_onUpdateName);
    on<ProfileEventUpdateImage>(_onUpdateImage);
  }

  Future<void> _onGetProfile(ProfileEventGet event, Emitter<ProfileState> emit) async {
    if (event.uid.isEmpty) {
      emit(ProfileStateError('UID tidak boleh kosong'));
      return;
    }

    try {
      emit(ProfileStateLoading());

      DocumentSnapshot<Map<String, dynamic>> userDoc = await users.doc(event.uid).get();

      final userData = userDoc.data();
      if (userData != null) {
        emit(ProfileStateLoaded(UserModel.fromJson(userData)));
      } else {
        emit(ProfileStateError('User tidak ditemukan'));
      }
    } on FirebaseException catch (e) {
      emit(ProfileStateError(e.message ?? 'Terjadi kesalahan pada Firebase'));
    } catch (e) {
      emit(ProfileStateError('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateName(ProfileEventUpdateName event, Emitter<ProfileState> emit) async {
    if (event.name.isEmpty) {
      emit(ProfileStateError('Nama tidak boleh kosong'));
      return;
    }

    try {
      emit(ProfileStateLoading());

      await users.doc(event.uid).update({'name': event.name});
      emit(ProfileStateUpdated());
    } on FirebaseException catch (e) {
      emit(ProfileStateError(e.message ?? 'Terjadi kesalahan pada Firebase'));
    } catch (e) {
      emit(ProfileStateError('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateImage(ProfileEventUpdateImage event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileStateLoading());

      final String uid = event.uid; // Menggunakan UID dari event

      final String fileName = path.basename(event.image.path);
      final Reference storageRef = storage.ref().child('profile_images/$uid/$fileName');

      await storageRef.putFile(File(event.image.path));
      final String downloadUrl = await storageRef.getDownloadURL();

      await users.doc(uid).update({'profile_image_url': downloadUrl});

      emit(ProfileStateImageUpdated());
    } on FirebaseException catch (e) {
      emit(ProfileStateError(e.message ?? 'Terjadi kesalahan pada Firebase'));
    } catch (e) {
      emit(ProfileStateError('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
