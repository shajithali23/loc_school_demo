import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key? key,
    required this.name,
    required TextEditingController nameController,
    required this.textInputType,
  })  : _nameController = nameController,
        super(key: key);

  final String name;
  final TextEditingController _nameController;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Colors.black, style: BorderStyle.none)),
            ),
            keyboardType: textInputType,
          ),
        ],
      ),
    );
  }
}