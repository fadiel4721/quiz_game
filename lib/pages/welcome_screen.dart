// welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm1_task_management/bloc/welcome/welcome_bloc.dart';
import 'package:pm1_task_management/bloc/welcome/welcome_event.dart';
import 'package:pm1_task_management/bloc/welcome/welcome_state.dart';
import 'package:pm1_task_management/utils/constants.dart';
import 'package:go_router/go_router.dart'; // Pastikan ini diimport

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeBloc(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              "assets/bg.svg",
              fit: BoxFit.fitWidth,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      "Let's Play Quiz",
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Text("Enter your information below"),
                    const Spacer(),
                    BlocBuilder<WelcomeBloc, WelcomeState>(
                      builder: (context, state) {
                        return TextField(
                          onChanged: (value) {
                            context
                                .read<WelcomeBloc>()
                                .add(UserNameChanged(value));
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF1C2341),
                            hintText: "Full Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<WelcomeBloc>().add(StartQuiz());
                        // Navigasi menggunakan GoRouter
                        context.go('/quiz-category'); // Pastikan rute sudah dikonfigurasi
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(kDefaultPadding * 0.75),
                        decoration: BoxDecoration(
                          gradient: kPrimaryGradient,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Let's Start Quiz",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
