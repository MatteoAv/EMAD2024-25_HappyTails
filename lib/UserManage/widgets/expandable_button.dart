import 'package:animated_text_kit/animated_text_kit.dart';
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
        curve: Curves.easeInOutQuad,
        width: isExpanded ? 150 : 80, // Larghezza dinamica
        height: 50,
        decoration: BoxDecoration(
          color: isExpanded ? Colors.deepOrange[400] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isExpanded ? Colors.white : Colors.black,
              size: 25
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(label,
                    textStyle: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white
                    ),
                    speed: const Duration(milliseconds: 15),
                    
                    ),
                ],
                isRepeatingAnimation: false,
                ),
              ),
             if(!isExpanded) 
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
              ),
          ],
        ),
      ),
    );
  }
}