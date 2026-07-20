import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor = Colors.white;
    
    switch (status) {
      case 'Published':
        color = Colors.green;
        break;
      case 'Draft':
        color = Colors.grey[400]!;
        break;
      case 'Closed':
        color = Colors.redAccent;
        break;
      case 'Deleted':
        color = Colors.blueGrey[800]!;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color, 
          fontSize: 11, 
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
