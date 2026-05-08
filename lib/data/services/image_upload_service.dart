import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:segundo_parcial/core/constants/app_constants.dart';

class ImageUploadService {
  late final CloudinaryPublic _cloudinary;

  ImageUploadService() {
    _cloudinary = CloudinaryPublic(
      AppConstants.cloudinaryCloudName, 
      AppConstants.cloudinaryUploadPreset,
      cache: false,
    );
  }

  // Sube una imagen a Cloudinary y retorna la URL publica
  Future<String> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'shopflow_products',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }
}