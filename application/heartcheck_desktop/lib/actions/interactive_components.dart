import 'package:flutter/material.dart';
import 'package:language_code/language_code.dart';

class EditableSettingItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onUpdate;

  const EditableSettingItem({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onUpdate,
  });

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
  void didUpdateWidget(covariant EditableSettingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue; // update the text field
    }
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
              isDense: true,
              underline: const SizedBox(),
              dropdownColor: Colors.grey[200],
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),

              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),

              items: LanguageCodes.values.map((lang) {
                return DropdownMenuItem(
                  value: lang.code,
                  child: Text(
                    lang.englishName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),

              onChanged: (newValue) {
                selectedLanguageNotifier.value = newValue!;
              },
            );
          },
        ),
      ],
    ),
  );
}

Widget buildDateTimePickerItem(String label, String value, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
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
          Text(
            value,
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

Widget buildTapItem(String label, String value, Future<void> Function() onTap)
{ 
    return InkWell(
    onTap: onTap,
    child: Padding(
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
          Text(
            value,
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

  Widget buildTextItem(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// dropdown
class DropDownInput extends StatelessWidget {
  final String currentValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const DropDownInput({
    super.key,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentValue,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      underline: const SizedBox(),
      isExpanded: true,
    );
  }
}