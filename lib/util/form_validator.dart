class FormValidator{
 static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll Number is required';
    }

    // Define a regular expression for the desired format
    RegExp regex = RegExp(r'^[A-Z]{5}-\d{2}-\d{2}$');

    // Check if the input matches the regex
    if (!regex.hasMatch(value)) {
      return 'Invalid Roll Number Format';
    }

    // Return null if the input is valid
    return null;
  }
}