import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageStateInitial());

  final ImagePicker imagePicker = ImagePicker();
  Future<void> pickImage() async {
    try {
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        emit(ImageStateLoaded(pickedImage.path));
      } else {
        emit(ImageStateError("tidak ada gambar yang dipilih"));
      }
    } catch (e) {
      emit(ImageStateError(e.toString()));
    }
  }
}
