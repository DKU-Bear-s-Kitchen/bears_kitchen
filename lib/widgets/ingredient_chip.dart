// lib/widgets/ingredient_chip.dart

import 'package:flutter/material.dart';

class IngredientChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const IngredientChip({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(name),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87, // 선택 시 흰색
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isSelected 
          ? Theme.of(context).primaryColor // 선택 시 강조색 (0xFFFFA000 주황색)
          : Colors.grey[200], // 비선택 시 연한 회색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: 1.0,
        ),
      ),
    );
  }
}