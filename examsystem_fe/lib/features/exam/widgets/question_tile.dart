import 'package:flutter/material.dart';
import '../models/exam_question_model.dart';

class QuestionTile extends StatelessWidget {
  final ExamQuestionModel question;
  final int index;
  final VoidCallback? onRemove;

  const QuestionTile({
    super.key,
    required this.question,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF97316).withOpacity(0.1),
          child: Text('$index', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        title: Text(
          question.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              _buildSmallBadge(question.difficulty, _getDifficultyColor(question.difficulty)),
              const SizedBox(width: 8),
              _buildSmallBadge('${question.score} Pts', Colors.orange),
            ],
          ),
        ),
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: onRemove,
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ...question.options.map((opt) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            opt.isCorrect == true ? Icons.check_circle : Icons.circle_outlined,
                            size: 16,
                            color: opt.isCorrect == true ? Colors.green : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(opt.optionText, style: TextStyle(color: opt.isCorrect == true ? Colors.green[700] : Colors.black87, fontSize: 13))),
                        ],
                      ),
                    )),
                if (question.explanation != null) ...[
                  const Divider(height: 24),
                  Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(question.explanation!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _getDifficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.blue;
      case 'hard': return Colors.red;
      default: return Colors.grey;
    }
  }
}
