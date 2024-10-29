part of 'image_cubit.dart';

sealed class ImageState {}

final class ImageStateInitial extends ImageState {}

final class ImageStateLoaded extends ImageState {
  final String imagePath;

  ImageStateLoaded(this.imagePath);
}
final class ImageStateError extends ImageState {
  final String message;

  ImageStateError(this.message);
}
