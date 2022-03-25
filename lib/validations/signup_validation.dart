class SignUpValidation {
  static final RegExp name =
  RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$");

  static final RegExp userName = RegExp(r"^[\w]*$");

  static String? userNameValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "Please enter your name";
    } else if (value.length >= 10) {
      return "Name is too long";
    } else if (!userName.hasMatch(value)) {
      return "Only letters, digits and _ are allowed.";
    }
    return null;
  }

  static String? nameValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "Please enter your name";
    } else if (value.length > 25) {
      return "Name is too long";
    } else if (!name.hasMatch(value)) {
      return "Please enter valid name";
    }
    return null;
  }

  static String? passwordValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "Please enter your password";
    } else if (value.length < 7) {
      return "Please enter at least 6 characters.";
    }
    return null;
  }
}