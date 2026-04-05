import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> showEditValueDialog(
  BuildContext context, {
  required String title,
  required int currentValue,
  String hint = "Valor",
}) {
  final controller = TextEditingController(text: "$currentValue");
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            final newVal = int.tryParse(controller.text) ?? currentValue;
            Navigator.of(ctx).pop(newVal);
          },
          child: const Text("Salvar"),
        ),
      ],
    ),
  );
}
