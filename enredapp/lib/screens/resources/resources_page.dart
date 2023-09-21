import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enredapp/auth/auth_controller.dart';
import 'package:enredapp/services/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../login/login_page.dart';
import 'components/resource_form.dart';
import 'components/resource_model.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.isLoggedIn.value = SharedPreferencesService.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final validityController = TextEditingController();
    final typeController = TextEditingController();
    final photoController = TextEditingController();
    final logoController = TextEditingController();

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Listado de Recursos'),
        actions: [
          Obx(() {
            print("HOLA ${authController.isLoggedIn.value}");
            return authController.isLoggedIn.value
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      authController.signOut();
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      Get.offAll(() => LoginPage());
                    },
                  );
          }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showResourceForm(context, nameController, locationController, validityController, typeController, photoController, logoController);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Resource>>(
        stream: readResources(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final resources = snapshot.data!;
            return ListView(
              children: resources
                  .map((resource) => buildResource(context, resource, formKey, nameController, locationController, validityController, typeController, photoController, logoController))
                  .toList(),
            );
          } else if (snapshot.hasError) {
            print("ERROR: ${snapshot.error}");
            return const Center(
              child: Text('Error al leer los recursos'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}

void _showResourceForm(BuildContext context, TextEditingController nameController, TextEditingController locationController, TextEditingController validityController, TextEditingController typeController, TextEditingController photoController, TextEditingController logoController, [Resource? resource, bool isEditMode = false]) {

  String id = resource?.id ?? '';
  if (resource != null) {
    nameController.text = resource.name;
    locationController.text = resource.location;
    validityController.text = resource.validity;
    typeController.text = resource.type;
    photoController.text = resource.photo ?? '';
    logoController.text = resource.logo ?? '';
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
              TextField(
                controller: photoController,
                decoration: const InputDecoration(labelText: 'Foto'),
              ),
              TextField(
                controller: logoController,
                decoration: const InputDecoration(labelText: 'Logo'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              final resource = Resource(
                  id: id,
                  name: nameController.text,
                  location: locationController.text,
                  validity: validityController.text,
                  type: typeController.text,
                  photo: photoController.text,
                  logo: logoController.text);
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
    },
  );
}

Image? getResourceImage(Resource resource) => resource.logo != null && resource.logo!.isNotEmpty
    ? Image.network(resource.logo!)
    : resource.photo != null && resource.photo!.isNotEmpty
    ? Image.network(resource.photo!)
    : null;

void _showDraggableScrollableSheet(BuildContext context,
    Resource resource, TextEditingController nameController,
    TextEditingController locationController, TextEditingController validityController,
    TextEditingController typeController, TextEditingController photoController,
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
        initialChildSize: 0.65,
        minChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
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
                  Text('Nombre: ${resource.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Text('Lugar: ${resource.location}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Text('Validez: ${resource.validity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Text('Tipo: ${resource.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showResourceForm(context, nameController, locationController, validityController, typeController, photoController, logoController, resource, true);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        )
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Agrega la lógica de eliminación aquí
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildResource(BuildContext context, Resource resource, GlobalKey formKey, TextEditingController nameController, TextEditingController locationController, TextEditingController validityController, TextEditingController typeController, TextEditingController photoController, TextEditingController logoController) {

  return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          title: Text(resource.name),
          subtitle: Text(resource.location),
          leading: null,//getResourceImage(resource),
          onTap: () {
            return _showDraggableScrollableSheet(context, resource, nameController, locationController, validityController, typeController, photoController, logoController);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showResourceForm(context, nameController, locationController, validityController, typeController, photoController, logoController, resource, true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  deleteResource(resource.id);
                },
              ),
            ],
          ),
        );
      });
}


Future<Resource?> readResource(String id) async {
  final docResource = FirebaseFirestore.instance
      .collection('resources')
      .doc(id);

  final snapshot = await docResource.get();

  if (snapshot.exists) {
    return Resource.fromJson(snapshot.data()!);
  } else {
    return null;
  }
}

Stream<List<Resource>> readResources() =>
   FirebaseFirestore.instance
      .collection('resources')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Resource.fromJson(doc.data()))
          .toList());

Future deleteResource(String id) async {
  final docResource = FirebaseFirestore.instance
      .collection('resources')
      .doc(id);

  await docResource.delete();
}
