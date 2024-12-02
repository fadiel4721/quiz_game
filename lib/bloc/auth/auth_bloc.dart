import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthStateInitial()) {
    // Initialize Firebase Auth and Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    // Helper function to login with Google
    Future<UserCredential?> loginWithGoogle() async {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          return null;  // User cancelled the login
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(cred);
      } catch (e) {
        print('Google login error: ${e.toString()}');
        return null;  // Ensure null is returned if an error occurs
      }
    }

    // Event handler for email/password login
    on<AuthEventLogin>((event, emit) async {
      try {
        emit(AuthStateLoading());
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        // Check if user exists in Firestore
        DocumentSnapshot userDoc =
            await users.doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          await users.doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'uid': userCredential.user!.uid,
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
            'createdAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
            'role': 'user',  // Default role if not set
          });
        } else {
          await users.doc(userCredential.user!.uid).set({
            'lastLoginAt': Timestamp.now(),
          }, SetOptions(merge: true));
        }

        // Fetch the role
        String role = userDoc['role'] ?? 'user';

        if (role == 'admin') {
          emit(AuthStateLoginSuccess(userCredential.user, role, isAdmin: true));
        } else {
          emit(AuthStateLoginSuccess(userCredential.user, role, isAdmin: false));
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login Failed: ${e.message}';
        if (e.code == 'user-not-found') {
          errorMessage = 'Tidak ada pengguna dengan email ini.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Password yang Anda masukkan salah.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Format email tidak valid.';
        } else if (e.code == 'network-request-failed') {
          errorMessage =
              'Tidak ada koneksi internet. Silakan periksa koneksi Anda.';
        }
        emit(AuthStateError(message: errorMessage));
      } catch (e) {
        emit(AuthStateError(
            message: 'Kesalahan tidak terduga: ${e.toString()}'));
      }
    });

    // Event handler for Google login
    on<AuthEventGoogleLogin>((event, emit) async {
      try {
        emit(AuthStateLoading());
        UserCredential? userCredential = await loginWithGoogle();

        if (userCredential == null) {
          emit(AuthStateError(
              message: 'Google sign-in dibatalkan oleh pengguna.'));
          return;
        }

        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await users.doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          await users.doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'uid': userCredential.user!.uid,
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
            'createdAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
            'role': 'user',  // Default role if not set
          });
        } else {
          await users.doc(userCredential.user!.uid).set({
            'lastLoginAt': Timestamp.now(),
          }, SetOptions(merge: true));
        }

        // Fetch the role
        String role = userDoc['role'] ?? 'user';

        if (role == 'admin') {
          emit(AuthStateLoginSuccess(userCredential.user, role, isAdmin: true));
        } else {
          emit(AuthStateLoginSuccess(userCredential.user, role, isAdmin: false));
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Google Login Gagal: ${e.message}';
        if (e.code == 'account-exists-with-different-credential') {
          errorMessage =
              'Akun ini sudah terdaftar dengan metode login yang berbeda.';
        }
        emit(AuthStateError(message: errorMessage));
      } catch (e) {
        emit(AuthStateError(
            message: 'Kesalahan tidak terduga: ${e.toString()}'));
      }
    });
  }
}
