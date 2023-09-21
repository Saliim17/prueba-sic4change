import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enredapp/screens/resources/components/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResourceForm extends StatefulWidget {
  final Resource? resource;
  const ResourceForm({Key? key, this.resource}) : super(key: key);

  @override
  ResourceFormState createState() => ResourceFormState();
}

class ResourceFormState extends State<ResourceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _validityController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _validityController.dispose();
    _typeController.dispose();
    _photoController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  bool isEditMode = false;
  String nameButton = 'Crear';
  Resource? resource;
  String id = '';

  @override
  void initState() {
    super.initState();
    resource = widget.resource;
    isEditMode = widget.resource != null ? true : false;
    nameButton = isEditMode ? 'Actualizar' : 'Crear';
    id = resource?.id ?? '';
    if (resource != null) {
      _nameController.text = resource!.name;
      _locationController.text = resource!.location;
      _validityController.text = resource!.validity;
      _typeController.text = resource!.type;
      _photoController.text = resource!.photo ?? '';
      _logoController.text = resource!.logo ?? '';
    }
  }


  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text('Nuevo recurso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lugar'),
              ),
              TextField(
                controller: _validityController,
                decoration: const InputDecoration(labelText: 'Validez'),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      //getImage(1);
                    },
                    child: const Text('Adjuntar logo'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //getImage(2);
                    },
                    child: const Text('Adjuntar foto'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              /*selectedImage == null
                  ? const Text('No se ha seleccionado una imagen 1')
                  : Image.file(
                File(selectedImage!.path),
                height: 100.0,
                width: 100.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20.0),
              selectedImage2 == null
                  ? const Text('No se ha seleccionado una imagen 2')
                  : Image.file(
                File(selectedImage2!.path),
                height: 100.0,
                width: 100.0,
                fit: BoxFit.cover,
              ),*/
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            final resource = Resource(
                id: id,
                name: _nameController.text,
                location: _locationController.text,
                validity: _validityController.text,
                type: _typeController.text,
                photo: _photoController.text,
                logo: _logoController.text);
            if (isEditMode) {
              // Actualizar el recurso
              updateResource(resource);
            } else {
              // Crear el recurso
              createResource(resource);
            }
            Navigator.of(context).pop(); // Cerrar el diálogo
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
  }
}

Future createResource(Resource resource) async {
  // Reference to document
  final docResource = FirebaseFirestore.instance.collection('resources').doc();

  resource.id = docResource.id;

  final json = resource.toJson();

  await docResource.set(json);
}

Future updateResource(Resource resource) async {
  final docResource = FirebaseFirestore.instance
      .collection('resources')
      .doc(resource.id);

  final json = resource.toJson();

  await docResource.update(json);
}