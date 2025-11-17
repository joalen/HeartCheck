import 'package:flutter/material.dart';
import 'package:language_code/language_code.dart';

class EditableSettingItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onUpdate;

  const EditableSettingItem({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditableSettingItem> createState() => _EditableSettingItemState();
}

class _EditableSettingItemState extends State<EditableSettingItem> {
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (isEditing) {
        widget.onUpdate(_controller.text);
      }
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            isEditing
                ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _toggleEdit(),
                    ),
                  )
                : Text(
                    _controller.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

Widget buildDropdownSettingItem(String label, ValueNotifier<String> selectedLanguageNotifier) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: selectedLanguageNotifier,
          builder: (context, value, child) {
            return DropdownButton<String>(
              value: value,
              dropdownColor: Colors.grey[200],
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
              iconSize: 24,
              items: LanguageCodes.values
                .map((lang) => DropdownMenuItem(
                  value: lang.code,
                  child: Text(lang.englishName, overflow: TextOverflow.ellipsis,),
                )).toList(),
              onChanged: (newValue) {
                selectedLanguageNotifier.value = newValue!;
              },
              underline: const SizedBox(),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w500,
                
              ),
            );
          },
        ),
      ],
    ),
  );
}