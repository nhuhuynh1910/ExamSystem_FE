import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../exam/models/exam_model.dart';
import '../bloc/attempt_bloc.dart';
import '../bloc/attempt_event.dart';
import '../bloc/attempt_state.dart';

class WaitingRoomScreen extends StatefulWidget {
  final ExamModel exam;
  const WaitingRoomScreen({super.key, required this.exam});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _codeController = TextEditingController();
  bool _isCodeValid = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onStart() {
    if (widget.exam.isPrivate && _codeController.text.isEmpty) {
      setState(() => _isCodeValid = false);
      return;
    }
    context.read<AttemptBloc>().add(StartExamAttemptEvent(
      widget.exam.examId,
      _codeController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Phòng chờ thi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<AttemptBloc, AttemptState>(
        listener: (context, state) {
          if (state is AttemptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.redAccent),
            );
          }
          if (state is AttemptStarted) {
            // Chuyển sang màn hình làm bài
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bắt đầu làm bài!'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildExamInfo(),
                const SizedBox(height: 32),
                if (widget.exam.isPrivate) _buildCodeInput(),
                const SizedBox(height: 40),
                _buildActionButtons(state.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFFFF7ED),
            child: Icon(Icons.assignment_outlined, color: Color(0xFFF97316), size: 32),
          ),
          const SizedBox(height: 16),
          Text(widget.exam.examName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(widget.exam.subjectName ?? 'Môn học', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w600)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(Icons.timer_outlined, '${widget.exam.durationMinutes} phút'),
              _statItem(Icons.help_outline, 'N/A câu'),
              _statItem(Icons.repeat, 'Max: ${widget.exam.maxAttempts}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MÃ TRUY CẬP (ACCESS CODE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Nhập mã đề thi tại đây',
            prefixIcon: const Icon(Icons.lock_open_rounded),
            filled: true,
            fillColor: Colors.white,
            errorText: _isCodeValid ? null : 'Mã không được để trống',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
          onChanged: (_) => setState(() => _isCodeValid = true),
        ),
        const SizedBox(height: 8),
        const Text('Đây là đề thi riêng tư, bạn cần mã từ giáo viên để vào thi.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : _onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('BẮT ĐẦU LÀM BÀI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quay lại', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
