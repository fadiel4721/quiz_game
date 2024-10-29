import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthStateInitial()) {
    // Emit state loading saat proses login dimulai
    FirebaseAuth auth = FirebaseAuth.instance; // Inisialisasi FirebaseAuth
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    on<AuthEventLogin>((event, emit) async {
      try {
        emit(AuthStateLoading());
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        // Cek apakah pengguna sudah ada di Firestore
        DocumentSnapshot userDoc =
            await users.doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          // Jika pengguna belum ada, buat dokumen baru
          await users.doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'uid': userCredential.user!.uid,
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
            'createAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
          });
        } else {
          // Jika pengguna sudah ada, update hanya lastLoginAt
          await users.doc(userCredential.user!.uid).set({
            'lastLoginAt': Timestamp.now(),
          }, SetOptions(merge: true)); // Merging untuk update
        }

        emit(AuthStateLoaded());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user tidak ditemukan') {
          emit(AuthStateError(message: 'tidak ada user dengan email tersebut.'));
        } else if (e.code == 'password salah') {
          emit(AuthStateError(
              message: 'Password Salah.'));
        } else {
          emit(AuthStateError(message: 'Login Gagal: ${e.message}'));
        }
      } catch (e) {
        emit(AuthStateError(
            message: 'An unknown error occurred: ${e.toString()}'));
      }
    });
  }
}
