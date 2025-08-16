import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(String filePath) async {
    try {
      File file = File(filePath);
      String fileName = file.path.split('/').last;
      Reference storageRef = _storage.ref().child('card_images').child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      developer.log('Error uploading image: $e');
      return null;
    }
  }
}