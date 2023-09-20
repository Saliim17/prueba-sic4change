import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enredapp/resource_model.dart';
import 'package:enredapp/user_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  @override
  Widget build(BuildContext context) {

    final FirebaseAuth auth = FirebaseAuth.instance;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final validityController = TextEditingController();
    final typeController = TextEditingController();
    final photoController = TextEditingController();
    final logoController = TextEditingController();
    bool isFormEnabled = true;

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bienvenido a enREDapp'),
        leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer(); // Abre el Drawer
              },
            ),
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
                  .map((resource) => buildResource(context, resource, nameController, locationController, validityController, typeController, photoController, logoController))
                  .toList(),
            );

          } else if (snapshot.hasError) {
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

Widget buildResource(BuildContext context, Resource resource, TextEditingController nameController, TextEditingController locationController, TextEditingController validityController, TextEditingController typeController, TextEditingController photoController, TextEditingController logoController) {

  return StatefulBuilder(
    builder: (context, setState) {
      return ListTile(
        title: Text(resource.name),
        subtitle: Text(resource.location),
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

Future deleteResource(String id) async {
  final docResource = FirebaseFirestore.instance
      .collection('resources')
      .doc(id);

  await docResource.delete();
}
