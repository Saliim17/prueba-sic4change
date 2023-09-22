import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enredapp/models/resource_model.dart';
import 'package:enredapp/screens/resources/utils/draggable_scrollable_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildResource(
    BuildContext context,
    Resource resource,
    RxString imageType,
    RxString photoUrl,
    RxString logoUrl,
    GlobalKey formKey,
    TextEditingController nameController,
    TextEditingController locationController,
    TextEditingController validityController,
    TextEditingController typeController,
    TextEditingController photoController,
    TextEditingController logoController) {
  return StatefulBuilder(builder: (context, setState) {
    return ListTile(
      title: Text(resource.name),
      subtitle: Text(resource.location),
      leading: getResourceImage(resource),
      onTap: () {
        return showDraggableScrollableSheet(
            context,
            resource,
            imageType,
            photoUrl,
            logoUrl,
            nameController,
            locationController,
            validityController,
            typeController,
            photoController,
            logoController);
      },
    );
  });
}

Image? getResourceImage(Resource resource) =>
    resource.logo != null && resource.logo!.isNotEmpty
        ? Image.network(resource.logo!, width: 100, height: 100)
        : resource.photo != null && resource.photo!.isNotEmpty
            ? Image.network(resource.photo!, width: 100, height: 100)
            : null;

Future<Resource?> readResource(String id) async {
  final docResource =
      FirebaseFirestore.instance.collection('resources').doc(id);

  final snapshot = await docResource.get();

  if (snapshot.exists) {
    return Resource.fromJson(snapshot.data()!);
  } else {
    return null;
  }
}

Stream<List<Resource>> readResources() => FirebaseFirestore.instance
    .collection('resources')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => Resource.fromJson(doc.data())).toList());

Future deleteResource(String id) async {
  final docResource =
      FirebaseFirestore.instance.collection('resources').doc(id);

  await docResource.delete();
}

Future createResource(Resource resource) async {
  // Reference to document
  final docResource = FirebaseFirestore.instance.collection('resources').doc();

  resource.id = docResource.id;

  final json = resource.toJson();

  await docResource.set(json);
}

Future updateResource(Resource resource) async {
  final docResource =
      FirebaseFirestore.instance.collection('resources').doc(resource.id);

  final json = resource.toJson();

  await docResource.update(json);
}

Image? getResourceLogo(Resource resource) =>
    resource.logo != null && resource.logo!.isNotEmpty
        ? Image.network(resource.logo!, width: 100, height: 100)
        : null;

Image? getResourcePhoto(Resource resource) =>
    resource.photo != null && resource.photo!.isNotEmpty
        ? Image.network(resource.photo!, width: 100, height: 100)
        : null;
