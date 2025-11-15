class LoginDataModel {
  String email;
  String password;

  LoginDataModel({required this.email, required this.password});
}

class SettingsDataModel {
  String name;
  String email;
  String phone;
  String role;
  String author;

  SettingsDataModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.author,
  });

  factory SettingsDataModel.fromJson(Map<String, dynamic> json) {
    return SettingsDataModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'author': author,
    };
  }
}

class AppointmentDataModel {
  String appointmentDate;
  String name;
  String phone;
  String comments;
  String author;
  String status;

  AppointmentDataModel({
    required this.appointmentDate,
    required this.name,
    required this.phone,
    required this.comments,
    required this.author,
    required this.status,
  });

  factory AppointmentDataModel.fromJson(Map<String, dynamic> json) {
    return AppointmentDataModel(
      appointmentDate: json['appointmentDate'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      comments: json['comments'] ?? '',
      author: json['author'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentDate': appointmentDate,
      'name': name,
      'phone': phone,
      'comments': comments,
      'author': author,
      'status': status,
    };
  }
}

class PersonDataModel {
  String name;
  String idType;
  String id;
  String sir;
  String occupation;
  String warrior; // na, military, healthcareworker, police, firefighter, frontline worker, senior, educator
  String dob;
  String gender; // m, f, o
  String medicalHistory;
  String race; // n, s, e , w, decline
  String address;
  String zipcode;
  String citiesTravelled;
  String siblings;
  String familyMembers;
  String socialActiveness;
  String declineParticipation; // y, n
  String author;

  PersonDataModel({
    required this.name,
    required this.idType,
    required this.id,
    required this.sir,
    required this.occupation,
    required this.warrior,
    required this.dob,
    required this.gender,
    required this.medicalHistory,
    required this.race,
    required this.address,
    required this.zipcode,
    required this.citiesTravelled,
    required this.siblings,
    required this.familyMembers,
    required this.socialActiveness,
    required this.declineParticipation,
    required this.author,
  });

  factory PersonDataModel.fromJson(Map<String, dynamic> json) {
    return PersonDataModel(
      name: json['name'] ?? '',
      idType: json['idType'] ?? '',
      id: json['id'] ?? '',
      sir: json['sir'] ?? '',
      occupation: json['occupation'] ?? '',
      warrior: json['warrior'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      medicalHistory: json['medicalHistory'] ?? '',
      race: json['race'] ?? '',
      address: json['address'] ?? '',
      zipcode: json['zipcode'] ?? '',
      citiesTravelled: json['citiesTravelled'] ?? '',
      siblings: json['siblings'] ?? '',
      familyMembers: json['familyMembers'] ?? '',
      socialActiveness: json['socialActiveness'] ?? '',
      declineParticipation: json['declineParticipation'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idType': idType,
      'id': id,
      'sir': sir,
      'occupation': occupation,
      'warrior': warrior,
      'dob': dob,
      'gender': gender,
      'medicalHistory': medicalHistory,
      'race': race,
      'address': address,
      'zipcode': zipcode,
      'citiesTravelled': citiesTravelled,
      'siblings': siblings,
      'familyMembers': familyMembers,
      'socialActiveness': socialActiveness,
      'declineParticipation': declineParticipation,
      'author': author,
    };
  }
}

class VaccineDataModel {
  String patientId;
  String appointmentDate;
  String newAppointmentDate;
  String author;

  VaccineDataModel({
    required this.patientId,
    required this.appointmentDate,
    required this.newAppointmentDate,
    required this.author,
  });

  factory VaccineDataModel.fromJson(Map<String, dynamic> json) {
    return VaccineDataModel(
      patientId: json['patientId'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      newAppointmentDate: json['newAppointmentDate'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'appointmentDate': appointmentDate,
      'newAppointmentDate': newAppointmentDate,
      'author': author,
    };
  }
}

class ScreenArguments {
  final String patientID;
  ScreenArguments(this.patientID);
}

class ScreenPatientArguments {
  final String reportType;
  final String patientID;

  ScreenPatientArguments(this.reportType, this.patientID);
}

class DBDataModel {
  final int numRows;
  final bool error;
  final String message;
  final List<dynamic> data;

  const DBDataModel({
    required this.numRows,
    required this.error,
    required this.message,
    required this.data,
  });

  factory DBDataModel.fromJson(Map<String, dynamic> json) {
    return DBDataModel(
      numRows: json['numRows'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((value) => UserModel.fromJson(value))
              .toList() ??
          [],
    );
  }
}

class AddressDataModel {
  final int numRows;
  final bool error;
  final String message;
  final List<dynamic> data;

  const AddressDataModel({
    required this.numRows,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AddressDataModel.fromJson(Map<String, dynamic> json) {
    return AddressDataModel(
      numRows: json['numRows'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((value) => AddressBookModel.fromJson(value))
              .toList() ??
          [],
    );
  }
}

class UserModel {
  final String userid;
  final String name;
  final String? jwttoken;
  final String? createdAt;
  final String? updatedAt;
  final String? role;

  const UserModel({
    required this.userid,
    required this.name,
    this.jwttoken,
    this.createdAt,
    this.updatedAt,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userid: json['userid'] ?? '',
      name: json['name'] ?? '',
      jwttoken: json['jwttoken'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'name': name,
      'jwttoken': jwttoken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'role': role,
    };
  }
}

class AddressBookModel {
  final int addressid;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String address;
  final String city;
  final String country;
  final String zipCode;
  final String? emailid1;
  final String? emailid2;
  final String? phone1;
  final String? phone2;
  final String? createdAt;
  final String? updatedAt;

  const AddressBookModel({
    required this.addressid,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.country,
    required this.zipCode,
    this.emailid1,
    this.emailid2,
    this.phone1,
    this.phone2,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressBookModel.fromJson(Map<String, dynamic> json) {
    return AddressBookModel(
      addressid: json['addressid'] ?? 0,
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zipCode'] ?? '',
      emailid1: json['emailid1'],
      emailid2: json['emailid2'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressid': addressid,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
      'zipCode': zipCode,
      'emailid1': emailid1,
      'emailid2': emailid2,
      'phone1': phone1,
      'phone2': phone2,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class OPDDataModel {
  String patientId;
  String opdDate;
  String symptoms;
  String diagnosis;
  String treatment;
  String rx;
  String lab;
  String comments;
  String author;

  OPDDataModel({
    required this.patientId,
    required this.opdDate,
    required this.symptoms,
    required this.diagnosis,
    required this.treatment,
    required this.rx,
    required this.lab,
    required this.comments,
    required this.author,
  });

  factory OPDDataModel.fromJson(Map<String, dynamic> json) {
    return OPDDataModel(
      patientId: json['patientId'] ?? '',
      opdDate: json['opdDate'] ?? '',
      symptoms: json['symptoms'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      rx: json['rx'] ?? '',
      lab: json['lab'] ?? '',
      comments: json['comments'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'opdDate': opdDate,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'rx': rx,
      'lab': lab,
      'comments': comments,
      'author': author,
    };
  }
}

class LabDataModel {
  String patientId;
  String labDate;
  String from;
  String status;
  String lab;
  String results;
  String descr;
  String comments;
  String author;

  LabDataModel({
    required this.patientId,
    required this.labDate,
    required this.from,
    required this.status,
    required this.lab,
    required this.results,
    required this.descr,
    required this.comments,
    required this.author,
  });

  factory LabDataModel.fromJson(Map<String, dynamic> json) {
    return LabDataModel(
      patientId: json['patientId'] ?? '',
      labDate: json['labDate'] ?? '',
      from: json['from'] ?? '',
      status: json['status'] ?? '',
      lab: json['lab'] ?? '',
      results: json['results'] ?? '',
      descr: json['descr'] ?? '',
      comments: json['comments'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'labDate': labDate,
      'from': from,
      'status': status,
      'lab': lab,
      'results': results,
      'descr': descr,
      'comments': comments,
      'author': author,
    };
  }
}

class RxDataModel {
  String patientId;
  String rxDate;
  String from;
  String status;
  String rx;
  String results;
  String descr;
  String comments;
  String author;

  RxDataModel({
    required this.patientId,
    required this.rxDate,
    required this.from,
    required this.status,
    required this.rx,
    required this.results,
    required this.descr,
    required this.comments,
    required this.author,
  });

  factory RxDataModel.fromJson(Map<String, dynamic> json) {
    return RxDataModel(
      patientId: json['patientId'] ?? '',
      rxDate: json['rxDate'] ?? '',
      from: json['from'] ?? '',
      status: json['status'] ?? '',
      rx: json['rx'] ?? '',
      results: json['results'] ?? '',
      descr: json['descr'] ?? '',
      comments: json['comments'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'rxDate': rxDate,
      'from': from,
      'status': status,
      'rx': rx,
      'results': results,
      'descr': descr,
      'comments': comments,
      'author': author,
    };
  }
}


class MessagesDataModel {
  String patientId;
  String messagesDate;
  String from;
  String status;
  String message;
  bool readReceipt;
  String author;

  MessagesDataModel({
    required this.patientId,
    required this.messagesDate,
    required this.from,
    required this.status,
    required this.message,
    required this.readReceipt,
    required this.author,
  });

  factory MessagesDataModel.fromJson(Map<String, dynamic> json) {
    return MessagesDataModel(
      patientId: json['patientId'] ?? '',
      messagesDate: json['messagesDate'] ?? '',
      from: json['from'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      readReceipt: json['readReceipt'] ?? false,
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'messagesDate': messagesDate,
      'from': from,
      'status': status,
      'message': message,
      'readReceipt': readReceipt,
      'author': author,
    };
  }
}
