import 'package:enredapp/screens/resources/resource_utils.dart';
import 'package:enredapp/screens/resources/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/resource_model.dart';

void showResourceForm(
    BuildContext context,
    RxString imageType,
    RxString photoUrl,
    RxString logoUrl,
    TextEditingController nameController,
    TextEditingController locationController,
    TextEditingController validityController,
    TextEditingController typeController,
    TextEditingController photoController,
    TextEditingController logoController,
    [Resource? resource,
    bool isEditMode = false]) {
  String id = resource?.id ?? '';
  if (resource != null) {
    nameController.text = resource.name;
    locationController.text = resource.location;
    validityController.text = resource.validity;
    typeController.text = resource.type;
    photoController.text = resource.getPhotoUrl() ?? '';
    logoController.text = resource.getLogoUrl() ?? '';
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String nameButton = isEditMode ? 'Actualizar' : 'Crear';
      return AlertDialog(
        title: const Text('Nuevo recurso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lugar'),
              ),
              TextField(
                controller: validityController,
                decoration: const InputDecoration(labelText: 'Validez'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 20.0),
              Obx(() => photoUrl.value.isEmpty
                  ? TextButton.icon(
                      onPressed: () {
                        imageType.value = 'photo';
                        showUploadPhotoOptions(
                            context, imageType, photoUrl, logoUrl);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      icon: const Icon(Icons.photo),
                      label: const Text('Foto'))
                  : const Row(
                      children: [
                        Icon(Icons.attach_file),
                        Text("Foto cargada"),
                      ],
                    )),
              const SizedBox(height: 20.0),
              Obx(() => logoUrl.value.isEmpty
                  ? TextButton.icon(
                      onPressed: () {
                        imageType.value = 'logo';
                        showUploadPhotoOptions(
                            context, imageType, photoUrl, logoUrl);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      icon: const Icon(Icons.photo),
                      label: const Text('Logo'))
                  : const Row(
                      children: [
                        Icon(Icons.attach_file),
                        Text("Logo cargado"),
                      ],
                    )),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              final newResource = Resource(
                  id: id,
                  name: nameController.text,
                  location: locationController.text,
                  validity: validityController.text,
                  type: typeController.text,
                  photo: photoUrl.value.isNotEmpty
                      ? photoUrl.value
                      : photoController.text,
                  logo: logoUrl.value.isNotEmpty
                      ? logoUrl.value
                      : logoController.text);
              if (isEditMode) {
                // Actualizar el recurso
                updateResource(newResource);
              } else {
                // Crear el recurso

                createResource(newResource);
              }

              photoUrl.value = '';
              logoUrl.value = '';
              Navigator.of(context).pop();
            },
            child: Text(nameButton),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );
}
