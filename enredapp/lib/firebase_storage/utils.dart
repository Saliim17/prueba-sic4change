import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

Future<List<Reference>> getImagesFromFirebaseStorage() async {
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  ListResult listResult = await referenceDirImages.listAll();
  return listResult.items;
}

void uploadFileFromCamera(
    RxString imageType, RxString photoUrl, RxString logoUrl) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
  if (file == null) return;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  try {
    await referenceImageToUpload.putFile(File(file.path));
    if (imageType.value == 'photo') {
      photoUrl.value = await referenceImageToUpload.getDownloadURL();
    } else if (imageType.value == 'logo') {
      logoUrl.value = await referenceImageToUpload.getDownloadURL();
    }
  } on FirebaseException catch (e) {
    print(e);
  }
}

void uploadFileFromGallery(
    RxString imageType, RxString photoUrl, RxString logoUrl) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file == null) return;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  try {
    await referenceImageToUpload.putFile(File(file.path));
    if (imageType.value == 'photo') {
      photoUrl.value = await referenceImageToUpload.getDownloadURL();
    } else if (imageType.value == 'logo') {
      logoUrl.value = await referenceImageToUpload.getDownloadURL();
    }
  } on FirebaseException catch (e) {
    print(e);
  }
}
