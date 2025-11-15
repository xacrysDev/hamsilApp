import 'dart:async';
import 'package:flutter/material.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../models/datamodel.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';

class Person extends StatefulWidget {
  static const routeName = '/person';

  const Person({super.key});
  @override
  PersonState createState() => PersonState();
}

class PersonState extends State<Person> with Validators {
  final AuthBloc authBloc = AuthBloc();

  final _formKey = GlobalKey<FormState>();

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  bool _btnEnabled = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _citiesTravelledController =
      TextEditingController();
  final TextEditingController _siblingsController = TextEditingController();
  final TextEditingController _familyMembersController =
      TextEditingController();
  final TextEditingController _socialActivenessController =
      TextEditingController();
  final TextEditingController _declineParticipationController =
      TextEditingController();

  // Dropdown values
  String idTypeValue = 'DrivingLicense';
  String sirTypeValue = 'SIR_Type';
  String warriorTypeValue = 'CORONA_Warrior';
  String genderTypeValue = 'Others';

  // Form data
  late PersonDataModel formData;

  @override
  void initState() {
    super.initState();
    // Inicializar con valores vacíos
    formData = PersonDataModel(
      name: '',
      idType: idTypeValue,
      id: '',
      sir: sirTypeValue,
      occupation: '',
      warrior: warriorTypeValue,
      dob: '',
      gender: genderTypeValue,
      medicalHistory: '',
      race: '',
      address: '',
      zipcode: '',
      citiesTravelled: '',
      siblings: '',
      familyMembers: '',
      socialActiveness: '',
      declineParticipation: '',
      author: '',
    );
    _loadPersonData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _occupationController.dispose();
    _dobController.dispose();
    _medicalHistoryController.dispose();
    _raceController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _citiesTravelledController.dispose();
    _siblingsController.dispose();
    _familyMembersController.dispose();
    _socialActivenessController.dispose();
    _declineParticipationController.dispose();
    authBloc.dispose();
    super.dispose();
  }

  Future<void> _loadPersonData() async {
    toggleSpinner();
    try {
      final res = await authBloc.getPersonData(authBloc.getUID());
      if (res != null && res.exists) {
        setState(() {
          formData = PersonDataModel.fromJson(res.data()!);
          _updateControllers();
        });
      } else {
        showMessage(true, "error", "User information is not available.");
      }
    } catch (e) {
      showMessage(true, "error", e.toString());
    } finally {
      toggleSpinner();
    }
  }

  void _updateControllers() {
    _nameController.text = formData.name;
    idTypeValue = formData.idType;
    _idController.text = formData.id;
    sirTypeValue = formData.sir;
    _occupationController.text = formData.occupation;
    warriorTypeValue = formData.warrior;
    _dobController.text = formData.dob;
    genderTypeValue = formData.gender;
    _medicalHistoryController.text = formData.medicalHistory;
    _raceController.text = formData.race;
    _addressController.text = formData.address;
    _zipcodeController.text = formData.zipcode;
    _citiesTravelledController.text = formData.citiesTravelled;
    _siblingsController.text = formData.siblings;
    _familyMembersController.text = formData.familyMembers;
    _socialActivenessController.text = formData.socialActiveness;
    _declineParticipationController.text = formData.declineParticipation;
  }

  void toggleSpinner() {
    setState(() => spinnerVisible = !spinnerVisible);
  }

  void showMessage(bool visible, String type, String msg) {
    setState(() {
      messageVisible = visible;
      messageType =
          type == "error" ? CMessageType.error : CMessageType.success;
      messageTxt = msg;
    });
  }

  Future<void> _saveData() async {
    toggleSpinner();
    try {
      await authBloc.setPersonData(formData: formData);
      showMessage(true, "success", "Data is saved.");
    } catch (e) {
      showMessage(true, "error", e.toString());
    } finally {
      toggleSpinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cPerson)),
      drawer: isAdmin ? CustomAdminDrawer() : CustomGuestDrawer(),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: authBloc.isSignedIn() ? _buildForm() : _loginPage(context),
        ),
      ),
    );
  }

  Widget _loginPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text('Click here to go to Login page'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ListView(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          onChanged: () => setState(() => _btnEnabled = _formKey.currentState?.validate() ?? false),
          child: Column(
            children: [
              Text("Update Personal Data", style: cHeaderDarkText),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Name *", "your name", evalName, Icons.person,
                  (value) => formData.name = value),
              _buildDropdown("ID Type", idTypeValue, <String>[
                'DrivingLicense',
                'AadharCard',
                'PAN',
                'SSN',
                'StudentID',
                'BirthCard'
              ], (value) {
                setState(() => idTypeValue = value);
                formData.idType = value;
              }),
              _buildTextField(_idController, "ID # *", "SSN Card #", evalName,
                  Icons.person_add_alt_1_sharp, (value) => formData.id = value),
              _buildDropdown("SIR Type", sirTypeValue, <String>[
                'SIR_Type',
                'S_uspected',
                'I_nfected',
                'R_ecovered',
                'NONE'
              ], (value) {
                setState(() => sirTypeValue = value);
                formData.sir = value;
              }),
              _buildTextField(_occupationController, "Occupation *", "Occupation",
                  evalName, Icons.desktop_windows, (value) => formData.occupation = value),
              _buildDropdown("Warrior Type", warriorTypeValue, <String>[
                'CORONA_Warrior',
                'Healthcare worker',
                'FrontLine worker',
                'Law Enforcement',
                'Senior'
              ], (value) {
                setState(() => warriorTypeValue = value);
                formData.warrior = value;
              }),
              _buildTextField(_dobController, "Date of Birth *", "DOB", evalName,
                  Icons.calendar_today, (value) => formData.dob = value),
              _buildDropdown("Gender Type", genderTypeValue, <String>[
                'Others',
                'Male',
                'Female',
                'Decline to answer'
              ], (value) {
                setState(() => genderTypeValue = value);
                formData.gender = value;
              }),
              _buildTextField(_medicalHistoryController, "Past Medical History *",
                  "Past Medical History", evalName, Icons.healing,
                  (value) => formData.medicalHistory = value),
              _buildTextField(_raceController, "Ethnicity *", "Ethnicity", evalName,
                  Icons.recent_actors, (value) => formData.race = value),
              _buildTextField(_addressController, "Address *", "Address", evalName,
                  Icons.home, (value) => formData.address = value),
              _buildTextField(_zipcodeController, "Zipcode *", "Zipcode", evalName,
                  Icons.gps_off, (value) => formData.zipcode = value),
              _buildTextField(_citiesTravelledController, "4 week travel history *",
                  "Cities Traveled", evalName, Icons.location_city,
                  (value) => formData.citiesTravelled = value),
              _buildTextField(_siblingsController, "Siblings *", "Siblings", evalChar,
                  Icons.family_restroom_rounded, (value) => formData.siblings = value),
              _buildTextField(
                  _familyMembersController,
                  "Family members in house *",
                  "Family Members",
                  evalChar,
                  Icons.family_restroom_rounded,
                  (value) => formData.familyMembers = value),
              _buildTextField(
                  _socialActivenessController,
                  "Past social gatherings *",
                  "Social Activities",
                  evalChar,
                  Icons.gps_fixed,
                  (value) => formData.socialActiveness = value),
              _buildTextField(
                  _declineParticipationController,
                  "Do you want to participate in Research *",
                  "Do you want to participate in Research",
                  evalChar,
                  Icons.surround_sound,
                  (value) => formData.declineParticipation = value),
              SizedBox(height: 20),
              CustomSpinner(toggleSpinner: spinnerVisible),
              CustomMessage(
                  toggleMessage: messageVisible,
                  toggleMessageType: messageType,
                  toggleMessageTxt: messageTxt),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _btnEnabled ? _saveData : null,
                child: Text('Save'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint,
      String? Function(String?) validator,
      IconData icon,
      Function(String) onChanged) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 25),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        maxLength: 50,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: hint,
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items,
      Function(String) onChanged) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 25),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}
