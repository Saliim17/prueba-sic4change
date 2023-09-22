import 'package:enredapp/auth/auth_controller.dart';
import 'package:enredapp/screens/resources/components/resource_form.dart';
import 'package:enredapp/screens/resources/resource_utils.dart';
import 'package:enredapp/services/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/resource_model.dart';

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
              return getAuthButton(authController);
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            nameController.value = TextEditingValue.empty;
            locationController.value = TextEditingValue.empty;
            validityController.value = TextEditingValue.empty;
            typeController.value = TextEditingValue.empty;
            photoController.value = TextEditingValue.empty;
            logoController.value = TextEditingValue.empty;

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
                logoController);
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
                    .map((resource) => buildResource(
                        context,
                        resource,
                        imageType,
                        photoUrl,
                        logoUrl,
                        formKey,
                        nameController,
                        locationController,
                        validityController,
                        typeController,
                        photoController,
                        logoController))
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
        ));
  }
}
