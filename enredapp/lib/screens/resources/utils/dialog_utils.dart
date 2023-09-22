import 'package:enredapp/firebase_storage/utils.dart';
import 'package:enredapp/models/resource_model.dart';
import 'package:enredapp/screens/resources/resource_utils.dart';
import 'package:enredapp/screens/resources/utils/draggable_scrollable_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteConfirmationDialog(BuildContext context, Resource resource) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar recurso'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este elemento?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              deleteResource(resource.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showUploadPhotoOptions(BuildContext context, RxString imageType,
    RxString photoUrl, RxString logoUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Opciones de carga'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    uploadFileFromCamera(imageType, photoUrl, logoUrl);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  icon: const Icon(Icons.camera),
                  label: const Text('Cámara')),
              const SizedBox(height: 20.0),
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    uploadFileFromGallery(imageType, photoUrl, logoUrl);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería del teléfono')),
              const SizedBox(height: 20.0),
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDraggableFirebaseStorageImages(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  icon: const Icon(Icons.storage),
                  label: const Text('Firebase Storage')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
