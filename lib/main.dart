import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm1_task_management/bloc/auth/auth_bloc.dart';
import 'package:pm1_task_management/bloc/category/category_bloc.dart';
import 'package:pm1_task_management/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:pm1_task_management/bloc/match/match_bloc.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/bloc/question/question_bloc.dart';
import 'package:pm1_task_management/bloc/register/register_bloc.dart';
import 'package:pm1_task_management/bloc/room/room_bloc.dart';
import 'package:pm1_task_management/firebase_options.dart';
import 'package:pm1_task_management/routes/router.dart';
import 'package:pm1_task_management/visibility_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TaskManagement());
}

class TaskManagement extends StatelessWidget {
  const TaskManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VisibilityCubit>(
          create: (context) => VisibilityCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<QuestionBloc>(
          create: (context) => QuestionBloc(),
        ),
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(),
        ),
        // BlocProvider<LeaderboardBloc>(
        //   create: (context) => LeaderboardBloc(),
        // ),

        // Menambahkan provider MatchBloc
        BlocProvider<MatchBloc>(
          create: (context) => MatchBloc(firestore: FirebaseFirestore.instance),
        ),
        // Menambahkan provider RoomBloc dengan FirebaseAuth
        BlocProvider<RoomBloc>(
          create: (context) => RoomBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance, // Pastikan FirebaseAuth disertakan
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
