import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:pm1_task_management/bloc/auth/auth_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';
import 'package:pm1_task_management/visibility_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm1_task_management/utils/constants.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => AuthBloc(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background (SVG Image)
            SvgPicture.asset(
              "assets/svg/bg.svg",
              fit: BoxFit.fitWidth,
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: SingleChildScrollView(
                  // Untuk menghindari overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Spasi awal
                      // Lottie Animation
                      Center(
                        child: Lottie.asset(
                          'assets/gif/hello_gif.json',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Spasi antara animasi dan teks

                      // Welcome Text
                      Text(
                        "Let's Play Quiz",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NeonLight', // Update font family
                            ),
                      ),
                      const Text(
                        "Masukkan email dan password",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'NeonLight'), // Update font family
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: emailC,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontFamily:
                                  'NeonLight'), // Update label font family
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field with Visibility Toggle
                      BlocConsumer<VisibilityCubit, bool>(
                        listener: (context, state) {},
                        builder: (context, isObscured) {
                          return TextFormField(
                            controller: passC,
                            obscureText: isObscured,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                  fontFamily:
                                      'NeonLight'), // Update label font family
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isObscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  context.read<VisibilityCubit>().change();
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthStateError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } else if (state is AuthStateLoginSuccess) {
                            // Setelah login berhasil, cek role
                            if (state.isAdmin) {
                              // Redirect ke admin dashboard
                              context.goNamed(Routes.adminDashboard);
                            } else {
                              // Redirect ke user dashboard
                              context.goNamed(Routes.dashboard);
                            }
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: kPrimaryGradient,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(
                                    kDefaultPadding * 0.75),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: state is! AuthStateLoading
                                  ? () {
                                      context.read<AuthBloc>().add(
                                            AuthEventLogin(
                                              email: emailC.text,
                                              password: passC.text,
                                            ),
                                          );
                                    }
                                  : null,
                              child: state is AuthStateLoading
                                  ? Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontFamily:
                                            'NeonLight', // Update font family for loading text
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: Colors.black,
                                              fontFamily:
                                                  'NeonLight'), // Update button font family
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Link ke Halaman Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'NeonLight'),
                          ),
                          TextButton(
                            onPressed: () {
                              print("Navigating to Register Page");
                              context.go('/register');
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  color: Colors.blue, fontFamily: 'NeonLight'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


                    // Sign in with other options
                    // const Text(
                    //   'Or sign in with',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w400,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),

                    // // Google Sign-In Button
                    // SignInButton(
                    //   buttonType: ButtonType.google,
                    //   onPressed: () {
                    //     context.read<AuthBloc>().add(AuthEventGoogleLogin());
                    //   },
                    // ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
