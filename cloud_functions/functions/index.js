const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.createUser = functions.https.onCall(async (data, context) => {
  const { email, password } = data;

  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
    });

    console.log("Usuario creado exitosamente:", userRecord.uid);
    return { result: "Usuario creado exitosamente" };
  } catch (error) {
    console.error("Error al crear usuario:", error);
    throw new functions.https.HttpsError("internal", "Error al crear usuario");
  }
});

exports.createAnonymousUser = functions.https.onCall(async (data, context) => {
  try {
    const userRecord = await admin.auth().signInAnonymously();

    console.log("Usuario anónimo creado exitosamente:", userRecord.uid);
    return { result: "Usuario anónimo creado exitosamente" };
  } catch (error) {
    console.error("Error al crear usuario anónimo:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error al crear usuario anónimo",
    );
  }
});
