class PostValidation {
  static final RegExp phone = RegExp(r"^0?[6-9]\d{9}$");

  String? blisPlaceNameValidation(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "This field is required.";
    } else if (value.length < 5) {
      return "At least 5 characters expected.";
    }
    return null;
  }

  String? fieldValidation(String? value, {bool? min10}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "This field is required.";
    }
    if (min10 == true && value.length < 10) {
      return "please enter at least 10 characters.";
    }
    return null;
  }

  String? phoneValidation(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!phone.hasMatch(value)) {
        return "Enter valid phone number.";
      }
    }
    return null;
  }

  String? reqPhoneValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required.";
    } else if (!phone.hasMatch(value)) {
      return "Enter valid phone number.";
    }
    return null;
  }

  String? photoValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Image is required";
    }
    return null;
  }
}