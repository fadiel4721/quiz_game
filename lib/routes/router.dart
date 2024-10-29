import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pm1_task_management/pages/login_page.dart';
import 'package:pm1_task_management/pages/profil_page.dart';
import 'package:pm1_task_management/pages/smart_building.dart';

final GoRouter router = GoRouter(
  //   initialLocation: '/login',
  redirect: (context, state) {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      return '/login';
    } else {
      return null;
    }
  },

  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        return LoginPage();
      },
    ),
    GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return  SmartBuilding();
        },
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) {
              return ProfilPage();
            },
          ),
        ]),
  ],
);
