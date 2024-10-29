import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pm1_task_management/bloc/profile/profile_bloc.dart';
import 'package:pm1_task_management/routes/router_name.dart';

final TextEditingController nameC = TextEditingController();

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

Future<void> _pickImage(BuildContext context, String uid) async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        context.read<ProfileBloc>().add(ProfileEventUpdateImage(image: image, uid: uid));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission denied")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/smart.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
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
                        } else if (state is ProfileStateImageUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile image updated successfully!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (state is ProfileStateUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          context.goNamed(Routes.home);
                        }
                      },
                      builder: (context, state) {
                        if (state is ProfileStateLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is ProfileStateLoaded) {
                          // Mengatur controller nama dengan data dari state
                          nameC.text = state.userModel.name ?? "";
                          final String? uid = state.userModel.uid; // Mengambil UID dari state
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: 
                                          (state.userModel.photoUrl != null && state.userModel.photoUrl!.isNotEmpty)
                                              ? NetworkImage(state.userModel.photoUrl!)
                                              : const AssetImage('assets/images/profile.jpg'),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _pickImage(context, uid!), // Pilih gambar ketika di tap
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.blue.shade700,
                                          child: const Icon(Icons.edit, size: 15, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  // Trigger the update when the button is pressed
                                  context.read<ProfileBloc>().add(ProfileEventUpdateName(name: nameC.text, uid: uid!));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                        return const Center(child: Text('No profile data found.'));
                      },
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
