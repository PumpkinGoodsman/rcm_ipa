import 'package:flutter/material.dart';
import 'package:ACM/Widgets/reusable_text_widget.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final String hintText;
  final void Function(List<String>) onChanged;

  MultiSelectDropdown({
    required this.items,
    required this.selectedItems,
    required this.hintText,
    required this.onChanged,
  });

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  List<String> _tempSelectedItems = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          _showMultiSelectDialog(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _tempSelectedItems.isEmpty
                    ? widget.hintText
                    : _tempSelectedItems.join(', '),
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis, // This ensures the text truncates with '...'
                maxLines: 1, // Limits the text to a single line
              ),
            ),

            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    List<String> _dialogSelectedItems = List.from(_tempSelectedItems);
    bool _selectAll = _dialogSelectedItems.length == widget.items.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(widget.hintText),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric( vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: CheckboxListTile(
                        value: _selectAll,
                        title: ReusableText(
                            text: 'Select All',
                            size: 18,
                            fw: FontWeight.bold),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setDialogState(() {
                            _selectAll = checked ?? false;
                            if (_selectAll) {
                              _dialogSelectedItems = List.from(widget.items);
                            } else {
                              _dialogSelectedItems.clear();
                            }
                          });
                        },
                      ),
                    ),
                    ...widget.items.map((String item) {
                      return CheckboxListTile(
                        value: _dialogSelectedItems.contains(item),
                        title: ReusableText(
                            text: item, size: 16, fw: FontWeight.w500),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setDialogState(() {
                            if (checked == true) {
                              _dialogSelectedItems.add(item);
                              if (_dialogSelectedItems.length ==
                                  widget.items.length) {
                                _selectAll = true;
                              }
                            } else {
                              _dialogSelectedItems.remove(item);
                              _selectAll = false;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: ReusableText(
                      text: 'Cancel', size: 16, fw: FontWeight.bold),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: ReusableText(text: 'OK', size: 16, fw: FontWeight.bold),
                  onPressed: () {
                    setState(() {
                      _tempSelectedItems = List.from(_dialogSelectedItems);
                    });
                    widget.onChanged(_tempSelectedItems);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
