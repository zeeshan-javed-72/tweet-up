import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

formField({
  TextEditingController? controller,
  title, context,
  inputFormatters,
   onChange,
  validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: TextFormField(
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      validator: validator,
      controller: controller,
      onChanged: onChange,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          filled: true,
          fillColor: Colors.black12,
          hintText: title,
      ),
    ),
  );
}
