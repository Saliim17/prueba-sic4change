import 'package:enredapp/firebase_storage/utils.dart';
import 'package:enredapp/models/resource_model.dart';
import 'package:enredapp/screens/resources/components/resource_form.dart';
import 'package:enredapp/screens/resources/resource_utils.dart';
import 'package:enredapp/screens/resources/utils/dialog_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDraggableScrollableSheet(
    BuildContext context,
    Resource resource,
    RxString imageType,
    RxString photoUrl,
    RxString logoUrl,
    TextEditingController nameController,
    TextEditingController locationController,
    TextEditingController validityController,
    TextEditingController typeController,
    TextEditingController photoController,
    TextEditingController logoController,
    [bool isEditMode = false]) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                        alignment: Alignment.center,
                        child: Text('Detalles del recurso')),
                    const Divider(
                      color: Colors.grey,
                      height: 20,
                      thickness: 1,
                      indent: 1,
                      endIndent: 1,
                    ),
                    Text('Nombre: ${resource.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    getResourceLogo(resource) ?? const Text('No hay logo'),
                    const SizedBox(height: 20.0),
                    Text('Lugar: ${resource.location}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    Text('Validez: ${resource.validity}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    Text('Tipo: ${resource.type}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    const Text('Foto:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    getResourcePhoto(resource) ?? const Text('No hay foto'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showResourceForm(
                                  context,
                                  imageType,
                                  photoUrl,
                                  logoUrl,
                                  nameController,
                                  locationController,
                                  validityController,
                                  typeController,
                                  photoController,
                                  logoController,
                                  resource,
                                  true);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            )),
                        TextButton.icon(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, resource);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showDraggableFirebaseStorageImages(BuildContext context, RxString imageType,
    RxString photoUrl, RxString logoUrl) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                        alignment: Alignment.center,
                        child: Text('Imágenes de Firebase Storage')),
                    const Divider(
                      color: Colors.grey,
                      height: 20,
                      thickness: 1,
                      indent: 1,
                      endIndent: 1,
                    ),
                    const SizedBox(height: 20.0),
                    FutureBuilder<List<String>>(
                      future: getImagesFromFirebaseStorage(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final images = snapshot.data!;
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (imageType.value == 'photo') {
                                    photoUrl.value = images[index];
                                  } else if (imageType.value == 'logo') {
                                    logoUrl.value = images[index];
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Image.network(images[index]),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error al leer las imágenes'),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
