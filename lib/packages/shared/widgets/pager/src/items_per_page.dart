import 'package:flutter/material.dart';

class ItemsPerPage extends StatefulWidget {
  const ItemsPerPage({
    required this.currentItemsPerPage,
    required this.itemsPerPage,
    required this.onChanged,
    super.key,
    this.itemsPerPageText,
    this.itemsPerPageTextStyle,
    this.dropDownMenuItemTextStyle,
  });
  final int currentItemsPerPage;
  final List<int> itemsPerPage;
  final Function(int) onChanged;
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle, dropDownMenuItemTextStyle;

  @override
  State<ItemsPerPage> createState() => _ItemsPerPageState();
}

class _ItemsPerPageState extends State<ItemsPerPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.itemsPerPageText ?? 'Items per page: ',
          style:
              widget.itemsPerPageTextStyle ??
              const TextStyle(color: Colors.grey),
        ),
        SizedBox(width: 16),
        DropdownButton(
          value: widget.currentItemsPerPage,
          focusColor: Colors.transparent,
          items: widget.itemsPerPage.map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                value.toString(),
                style:
                    widget.dropDownMenuItemTextStyle ??
                    const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              widget.onChanged(value as int);
            });
          },
        ),
      ],
    );
  }
}
