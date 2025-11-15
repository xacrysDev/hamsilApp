import 'package:flutter/material.dart';

class CustomFormRoundedTxt extends StatelessWidget {
  final Stream<String?>? streamBloc;
  final TextEditingController controller;
  final bool obscureTxt;
  final ValueChanged<String>? onChangeTxt;
  final Widget? iconTxt;
  final String? hintTxt;
  final String? labelTxt;

  const CustomFormRoundedTxt({
    super.key,
    this.streamBloc,
    required this.controller,
    this.obscureTxt = false,
    this.onChangeTxt,
    this.iconTxt,
    this.hintTxt,
    this.labelTxt,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: streamBloc,
      builder: (context, snapshot) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(top: 25),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.blueAccent,
            maxLength: 50,
            obscureText: obscureTxt,
            onChanged: onChangeTxt,
            decoration: InputDecoration(
              icon: iconTxt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hintText: hintTxt,
              labelText: labelTxt,
              errorText: snapshot.error?.toString(),
            ),
          ),
        );
      },
    );
  }
}

class CustomFormTxt extends StatelessWidget {
  final Stream<String?>? streamBloc;
  final int? boxLength;
  final bool obscureTxt;
  final ValueChanged<String>? onChangeTxt;
  final Widget? iconTxt;
  final String? hintTxt;
  final String? labelTxt;

  const CustomFormTxt({
    super.key,
    this.streamBloc,
    this.boxLength,
    this.obscureTxt = false,
    this.onChangeTxt,
    this.iconTxt,
    this.hintTxt,
    this.labelTxt,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: streamBloc,
      builder: (context, snapshot) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(top: 5),
          child: TextFormField(
            cursorColor: Colors.blueAccent,
            maxLength: boxLength,
            obscureText: obscureTxt,
            onChanged: onChangeTxt,
            decoration: InputDecoration(
              icon: iconTxt,
              hintText: hintTxt,
              labelText: labelTxt,
              errorText: snapshot.error?.toString(),
            ),
          ),
        );
      },
    );
  }
}

class CustomFormDataTxt extends StatelessWidget {
  final String? dbData;
  final bool isEnabled;
  final Stream<String?>? streamBloc;
  final int? boxLength;
  final bool obscureTxt;
  final ValueChanged<String>? onChangeTxt;
  final Widget? iconTxt;
  final String? hintTxt;
  final String? labelTxt;

  const CustomFormDataTxt({
    super.key,
    this.dbData,
    this.isEnabled = true,
    this.streamBloc,
    this.boxLength,
    this.obscureTxt = false,
    this.onChangeTxt,
    this.iconTxt,
    this.hintTxt,
    this.labelTxt,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: dbData ?? '');
    return StreamBuilder<String?>(
      stream: streamBloc,
      builder: (context, snapshot) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(top: 5),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.blueAccent,
            enabled: isEnabled,
            maxLength: boxLength,
            obscureText: obscureTxt,
            onChanged: onChangeTxt,
            decoration: InputDecoration(
              icon: iconTxt,
              hintText: hintTxt,
              labelText: labelTxt,
              errorText: snapshot.error?.toString(),
            ),
          ),
        );
      },
    );
  }
}

class CustomInput extends StatelessWidget {
  final String? dbData;
  final int? boxLength;
  final bool isEnabled;
  final bool obscureTxt;
  final Widget? iconTxt;
  final String? hintTxt;
  final String? labelTxt;

  const CustomInput({
    super.key,
    this.dbData,
    this.boxLength,
    this.isEnabled = true,
    this.obscureTxt = false,
    this.iconTxt,
    this.hintTxt,
    this.labelTxt,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: dbData ?? '');
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 5),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        cursorColor: Colors.blueAccent,
        maxLength: boxLength,
        obscureText: obscureTxt,
        decoration: InputDecoration(
          icon: iconTxt,
          hintText: hintTxt,
          labelText: labelTxt,
        ),
      ),
    );
  }
}
