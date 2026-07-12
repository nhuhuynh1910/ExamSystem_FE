import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionTile extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback? onPublish;
  final VoidCallback? onDraft;

  const QuestionTile({
    super.key,
    required this.question,
    required this.index,
    this.onPublish,
    this.onDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Text('$index', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        title: Text(
          question.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            _buildBadge(question.difficulty, _getDifficultyColor(question.difficulty)),
            const SizedBox(width: 8),
            _buildBadge('${question.score} Pts', Colors.orange),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...question.options.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(opt.isCorrect ? Icons.check_circle : Icons.circle_outlined, size: 16, color: opt.isCorrect ? Colors.green : Colors.grey[300]),
                      const SizedBox(width: 12),
                      Expanded(child: Text(opt.optionText, style: TextStyle(fontSize: 13, color: opt.isCorrect ? Colors.green[700] : Colors.black87))),
                    ],
                  ),
                )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (question.status == 'Draft' && onPublish != null)
                      TextButton.icon(
                        onPressed: onPublish,
                        icon: const Icon(Icons.publish, size: 18),
                        label: const Text('PUBLISH'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFF97316)),
                      ),
                    if (question.status == 'Published' && onDraft != null)
                      TextButton.icon(
                        onPressed: onDraft,
                        icon: const Icon(Icons.drafts_outlined, size: 18),
                        label: const Text('SET TO DRAFT'),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
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
