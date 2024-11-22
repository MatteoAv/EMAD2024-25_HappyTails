import 'package:flutter/material.dart';

class ExpandableButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const ExpandableButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isExpanded ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isExpanded ? Colors.white : Colors.black),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(label, style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
