import 'package:flutter/material.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    required this.items,
    this.value, // Default value can be null
    required this.onChanged,
    required this.hintText,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.value, // Display the selected value
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          hint: widget.value == null
              ? ReusableText(
            color: Colors.grey.shade800,
              text: widget.hintText, size: 16, fw: FontWeight.w500)
              : ReusableText(text: widget.value!, size: 16, fw: FontWeight.w500), // Show selected value
          iconSize: 24,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: widget.items.map(buildItems).toList(),
          onChanged: (value) {
            setState(() {
              widget.onChanged(value);
            });
          },
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildItems(String item) => DropdownMenuItem(
    value: item,
    child: ReusableText(
        text: item, size: 16, fw: FontWeight.w500),
  );
}
