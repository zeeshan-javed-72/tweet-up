import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

formField({TextEditingController? controller, title, context, inputFormatters}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: TextFormField(
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      validator: ((value) => value!.isEmpty ? 'Enter a value' : null),
      controller: controller,
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
