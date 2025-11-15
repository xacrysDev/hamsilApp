mixin Validators {
  // Validación de email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final regex =
        RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!regex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  // Validación de contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    final regex = RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    if (!regex.hasMatch(value)) {
      return "Password must contain letters and numbers";
    }
    return null;
  }

  // Validación de nombre
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }
    if (value.length < 4) {
      return "Name must be at least 4 characters";
    }
    return null;
  }

  // Validación de teléfono (formato 123-456-7890)
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone is required";
    }
    final regex = RegExp(r'^[2-9]\d{2}-\d{3}-\d{4}$');
    if (!regex.hasMatch(value)) {
      return "Ex. valid phone 123-456-7890";
    }
    return null;
  }

  // Validación genérica de texto
  String? validateText(String? value, {int minLength = 1}) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    if (value.length < minLength) {
      return "Minimum $minLength characters required";
    }
    return null;
  }

  String? evalName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    return null;
  }

  String? evalChar(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? evalPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    final phoneRegExp = RegExp(r'^[0-9]{7,15}$');
    if (!phoneRegExp.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  String? evalPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    final regex = RegExp(r'^(?=.*[a-z])(?=.*\d).{8,}$');
    if (!regex.hasMatch(value)) {
      return "Please enter an 8-character alphanumeric password";
    }

    return null;
  }

  String? evalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!regex.hasMatch(value)) {
      return "Please enter a valid email";
    }

    return null;
  }
}
