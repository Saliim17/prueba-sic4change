import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enredapp/auth/auth_controller.dart';
import 'package:enredapp/services/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  RxString logoUrl = ''.obs;
  RxString photoUrl = ''.obs;
  RxString imageType = ''.obs;

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
          _showResourceForm(context, imageType, photoUrl, logoUrl, nameController, locationController, validityController, typeController, photoController, logoController);
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
                  .map((resource) => buildResource(context, resource, imageType, photoUrl, logoUrl, formKey, nameController, locationController, validityController, typeController, photoController, logoController))
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

void _showResourceForm(BuildContext context, RxString imageType, RxString photoUrl, RxString logoUrl, TextEditingController nameController, TextEditingController locationController, TextEditingController validityController, TextEditingController typeController, TextEditingController photoController, TextEditingController logoController, [Resource? resource, bool isEditMode = false]) {

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
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => photoUrl.value.isEmpty
                      ? TextButton.icon(
                          onPressed: () {
                            imageType.value = 'photo';
                            _showUploadPhotoOptions(context, imageType, photoUrl, logoUrl);
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
                      )
                  ),
                  Obx(() => logoUrl.value.isEmpty
                        ? TextButton.icon(
                            onPressed: () {
                              imageType.value = 'logo';
                              _showUploadPhotoOptions(context, imageType, photoUrl, logoUrl);
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
                      )
                  ),
                ],
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
                  photo: photoUrl.value,
                  logo: logoUrl.value);
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
    ? Image.network(resource.logo!, width: 100, height: 100)
    : resource.photo != null && resource.photo!.isNotEmpty
    ? Image.network(resource.photo!, width: 100, height: 100)
    : null;

Image? getResourceLogo(Resource resource) => resource.logo != null && resource.logo!.isNotEmpty
    ? Image.network(resource.logo!, width: 100, height: 100)
    : null;

Image? getResourcePhoto(Resource resource) => resource.photo != null && resource.photo!.isNotEmpty
    ? Image.network(resource.photo!, width: 100, height: 100)
    : null;

void _showDeleteConfirmationDialog(BuildContext context, Resource resource) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar recurso'),
        content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
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

void _showUploadPhotoOptions(BuildContext context, RxString imageType, RxString photoUrl, RxString logoUrl) {

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
                  onPressed: (){
                    Navigator.of(context).pop();
                    print("TIPO DE IMAGEN: ${imageType.value}");
                    print("INIT PHOTO URL: ${photoUrl.value}");
                    print("INIT LOGO URL: ${logoUrl.value}");
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
                  onPressed: (){
                    Navigator.of(context).pop();
                    //uploadFileFromFirebaseStorage(imageUrl);
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

void uploadFileFromCamera(RxString imageType, RxString photoUrl, RxString logoUrl) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
  if (file == null) return;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  try{
    await referenceImageToUpload.putFile(File(file.path));
    if(imageType.value == 'photo') {
      photoUrl.value = await referenceImageToUpload.getDownloadURL();
    } else if (imageType.value == 'logo') {
      logoUrl.value = await referenceImageToUpload.getDownloadURL();
    }
  } on FirebaseException catch (e) {
    print(e);
  }
}

void uploadFileFromGallery(RxString imageType, RxString photoUrl, RxString logoUrl) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file == null) return;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  try{
    await referenceImageToUpload.putFile(File(file.path));
    if(imageType.value == 'photo') {
      photoUrl.value = await referenceImageToUpload.getDownloadURL();
    } else if (imageType.value == 'logo') {
      logoUrl.value = await referenceImageToUpload.getDownloadURL();
    }

    print("IMAGE TYPE: ${imageType.value}");
    print("PHOTO URL: ${photoUrl.value}");
    print("LOGO URL: ${logoUrl.value}");
  } on FirebaseException catch (e) {
    print(e);
  }
}

void _showDraggableScrollableSheet(BuildContext context,
    Resource resource, RxString imageType, RxString photoUrl, RxString logoUrl, TextEditingController nameController,
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
                    Text('Nombre: ${resource.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    getResourceLogo(resource) ?? const Text('No hay logo'),
                    const SizedBox(height: 20.0),
                    Text('Lugar: ${resource.location}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    Text('Validez: ${resource.validity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    Text('Tipo: ${resource.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    const Text('Foto:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20.0),
                    getResourcePhoto(resource) ?? const Text('No hay foto'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showResourceForm(context, imageType, photoUrl, logoUrl, nameController, locationController, validityController, typeController, photoController, logoController, resource, true);
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
                            _showDeleteConfirmationDialog(context, resource);
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
            ),
          );
        },
      );
    },
  );
}

Widget buildResource(BuildContext context, Resource resource, RxString imageType, RxString photoUrl, RxString logoUrl, GlobalKey formKey, TextEditingController nameController, TextEditingController locationController, TextEditingController validityController, TextEditingController typeController, TextEditingController photoController, TextEditingController logoController) {

  return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          title: Text(resource.name),
          subtitle: Text(resource.location),
          leading: getResourceImage(resource),
          onTap: () {
            return _showDraggableScrollableSheet(context, resource, imageType, photoUrl, logoUrl, nameController, locationController, validityController, typeController, photoController, logoController);
          },
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
