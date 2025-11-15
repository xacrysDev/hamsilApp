import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../validators.dart';
import '../../models/datamodel.dart';

class AuthBloc with Validators {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _person =
      FirebaseFirestore.instance.collection('person');
  final CollectionReference<Map<String, dynamic>> _appointments =
      FirebaseFirestore.instance.collection('appointments');
  final CollectionReference<Map<String, dynamic>> _vaccine =
      FirebaseFirestore.instance.collection('vaccine');

  CollectionReference<Map<String, dynamic>> get person => _person;
  CollectionReference<Map<String, dynamic>> get appointments => _appointments;

  // ------------------- Auth -------------------
  bool isSignedIn() => _auth.currentUser != null;

  String getUID() => _auth.currentUser?.uid ?? '';

  Future<String> signInWithEmail({required LoginDataModel formData}) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: formData.email, password: formData.password);
      return "";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: login popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        final GoogleSignInAccount? googleUser =
            await googleSignIn.authenticate();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Verifica que los tokens no sean nulos
        if (googleAuth.idToken == null) {
          throw Exception('Failed to get Google authentication tokens');
        }

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken!,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  Future<String> signUpWithEmail({required LoginDataModel formData}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: formData.email, password: formData.password);
      return "";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
  }

  // ------------------- Firestore Get -------------------
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserData() async {
    if (_auth.currentUser != null) {
      return _users.doc(_auth.currentUser!.uid).get();
    }
    return null;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getPersonData(
      String id) async {
    if (_auth.currentUser != null) {
      return _person.doc(id).get();
    }
    return null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAppointments() {
    return _appointments
        .where('appointmentDate', isGreaterThan: DateTime.now())
        .where('appointmentDate',
            isLessThan: DateTime.now().add(const Duration(days: 2)))
        .snapshots();
  }

  // ------------------- Firestore Set -------------------
  Future<void> setUserData({required SettingsDataModel formData}) async {
    await _users.doc(_auth.currentUser!.uid).set({
      'name': formData.name,
      'phone': formData.phone,
      'email': formData.email,
      'role': formData.role,
      'author': _auth.currentUser!.uid
    });
  }

  Future<void> setPersonData({required PersonDataModel formData}) async {
    await _person.doc(_auth.currentUser!.uid).set({
      'name': formData.name,
      'idType': formData.idType,
      'id': formData.id,
      'sir': formData.sir,
      'occupation': formData.occupation,
      'warrior': formData.warrior,
      'dob': formData.dob,
      'gender': formData.gender,
      'medicalHistory': formData.medicalHistory,
      'race': formData.race,
      'address': formData.address,
      'zipcode': formData.zipcode,
      'citiesTravelled': formData.citiesTravelled,
      'siblings': formData.siblings,
      'familyMembers': formData.familyMembers,
      'socialActiveness': formData.socialActiveness,
      'declineParticipation': formData.declineParticipation,
      'author': _auth.currentUser!.uid
    });
  }

  Future<void> setSubCollectionData({
    required String subCollection,
    required String patientId,
    required Map<String, dynamic> data,
  }) async {
    await _person.doc(patientId).collection(subCollection).add(data);
  }

  Future<void> updData(SettingsDataModel formData) async {
    if (formData.author.isEmpty) {
      throw Exception("Author ID is required to update user data.");
    }

    try {
      await _users.doc(formData.author).set({
        'name': formData.name ?? "",
        'phone': formData.phone ?? "",
        'email': formData.email ?? "",
        'role': formData.role ?? "none",
        'author': formData.author,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }

  Future<void> setLABData(LabDataModel formData) async {
    try {
      await person.doc(formData.patientId).collection("Lab").add({
        'labDate': FieldValue.serverTimestamp(),
        'from': formData.from,
        'status': formData.status,
        'lab': formData.lab,
        'results': formData.results,
        'descr': formData.descr,
        'comments': formData.comments,
        'author': formData.patientId,
      });
    } catch (e, st) {
      print("Error al guardar LAB data: $e\n$st");
      rethrow;
    }
  }

  Future<void> setAppointmentData({required AppointmentDataModel formData}) async {
  try {
    await appointments.doc(_auth.currentUser!.uid).set({
      'appointmentDate': formData.appointmentDate,
      'name': formData.name,
      'phone': formData.phone,
      'comments': formData.comments,
      'author': _auth.currentUser!.uid,
      'status': formData.status,
    });
  } catch (e, st) {
    print("Error al guardar Appointment data: $e\n$st");
    rethrow;
  }
}


  Future<void> setMessagesData({required MessagesDataModel formData}) async {
    try {
      await person.doc(formData.patientId).collection("OPD").add({
        'messagesDate': FieldValue.serverTimestamp(),
        'from': formData.from,
        'status': formData.status,
        'message': formData.message,
        'readReceipt': formData.readReceipt,
        'author': formData.patientId,
      });
    } catch (e, st) {
      print("Error al guardar mensaje: $e\n$st");
      rethrow;
    }
  }

  Future<void> setOPDData({required OPDDataModel formData}) async {
    try {
      await person.doc(formData.patientId).collection("OPD").add({
        'opdDate': FieldValue.serverTimestamp(),
        'symptoms': formData.symptoms,
        'diagnosis': formData.diagnosis,
        'treatment': formData.treatment,
        'rx': formData.rx,
        'lab': formData.lab,
        'comments': formData.comments,
        'author': formData.patientId,
      });
    } catch (e, st) {
      print("Error al guardar OPD data: $e\n$st");
      rethrow;
    }
  }

  Future<void> setRxData({required RxDataModel formData}) async {
    try {
      await person.doc(formData.patientId).collection("Rx").add({
        'rxDate': FieldValue.serverTimestamp(),
        'from': formData.from,
        'status': formData.status,
        'rx': formData.rx,
        'results': formData.results,
        'descr': formData.descr,
        'comments': formData.comments,
        'author': formData.patientId,
      });
    } catch (e, st) {
      print("Error al guardar Rx data: $e\n$st");
      rethrow;
    }
  }

  Future<void> setVaccineData({required VaccineDataModel formData}) async {
  try {
    await person.doc(formData.patientId).collection("Vaccine").add({
      'appointmentDate': formData.appointmentDate,
      'newAppointmentDate': formData.newAppointmentDate,
      'author': formData.patientId,
    });
  } catch (e, st) {
    print("Error al guardar Vaccine data: $e\n$st");
    rethrow;
  }
}

  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocData(
      String collectionName, String docId) async {
    if (_auth.currentUser == null) return null;

    try {
      CollectionReference<Map<String, dynamic>> collection;

      switch (collectionName) {
        case "users":
          collection = _users;
          break;
        case "person":
          collection = _person;
          break;
        case "appointments":
          collection = _appointments;
          break;
        case "vaccine":
          collection = _vaccine;
          break;
        default:
          return null;
      }

      final docSnapshot = await collection.doc(docId).get();
      return docSnapshot.exists ? docSnapshot : null;
    } catch (e) {
      print("Error en getDocData: $e");
      return null;
    }
  }

  // ------------------- Dispose -------------------
  void dispose() {}
}

final authBloc = AuthBloc();
