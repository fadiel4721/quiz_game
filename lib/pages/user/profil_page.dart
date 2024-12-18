import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';

final TextEditingController nameC = TextEditingController();

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? uid;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(80.0), // Atur tinggi AppBar jika perlu
        child: Stack(
          children: [
            // Background (SVG Image)
            Positioned.fill(
              child: SvgPicture.asset(
                "assets/svg/bg.svg",
                fit: BoxFit.cover,
              ),
            ),
            // AppBar Content
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.goNamed(Routes.dashboard);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontFamily: 'NeonLight',
                        fontSize: 18,
                        color: Colors.white, // Ubah sesuai background
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'NeonLight',
                      fontSize: 18,
                      color:
                          Colors.white, // Sesuaikan dengan kontras background
                    ),
                  ),
                  const SizedBox(width: 80), // Placeholder agar konten seimbang
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background (SVG Image)
          SvgPicture.asset(
            "assets/svg/bg.svg",
            fit: BoxFit.fitWidth,
            width: double.infinity, // Agar SVG memenuhi lebar layar
            height: double.infinity, // Agar SVG memenuhi tinggi layar
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    color: const Color(0xFF001F3F)
                        .withOpacity(0.9), // Ganti warna sesuai permintaan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: BlocConsumer<ProfileBloc, ProfileState>(
                        listener: (context, state) {
                          if (state is ProfileStateError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                              ),
                            );
                          } else if (state is ProfileStateNameUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile updated successfully!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            context.goNamed(Routes.dashboard);
                          }
                        },
                        builder: (context, state) {
                          if (state is ProfileStateLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is ProfileStatePickedImage) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read<ProfileBloc>().add(
                                          ProfileEventPickedImage(),
                                        );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage:
                                        FileImage(File(state.image.path)),
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: nameC,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ProfileBloc>()
                                        .add(ProfileEventUpdateName(
                                          name: nameC.text,
                                          uid: uid!,
                                          file: File(state.image.path),
                                        ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "UPDATE",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          }
                          if (state is ProfileStateLoaded) {
                            nameC.text = state.userModel.name ?? "";
                            uid = state.userModel.uid;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read<ProfileBloc>().add(
                                          ProfileEventPickedImage(),
                                        );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        state.userModel.photoUrl ?? ''),
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: nameC,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ProfileBloc>().add(
                                        ProfileEventUpdateName(
                                            name: nameC.text, uid: uid!));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF001F3F),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "UPDATE",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const Center(
                              child: Text('No profile data found.'));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
