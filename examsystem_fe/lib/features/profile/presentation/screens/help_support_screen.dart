import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/support_ticket_dialog.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// HelpSupportScreen — Help & Support Center
/// ════════════════════════════════════════════════════════════════════════════
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Online Exam',
    'Account',
    'Subject Enrollment',
    'Teachers',
  ];

  final List<_FaqItem> _allFaqs = [
    _FaqItem(
      category: 'Online Exam',
      question: 'How do I start a multiple-choice exam?',
      answer:
          'Go to the "Home" screen or "My Subjects" list, select the subject you need to take an exam in and click on the available exam. After reading the instructions carefully, click "Start Exam".',
    ),
    _FaqItem(
      category: 'Online Exam',
      question: 'What happens if I lose internet connection during an exam?',
      answer:
          'ExamSystem automatically saves your answers in real-time. When your connection is restored, simply reload the page/app and continue. The countdown timer will continue running.',
    ),
    _FaqItem(
      category: 'Account',
      question: 'How do I recover a forgotten password?',
      answer:
          'On the Login screen, click "Forgot password?". Enter your registered Email to receive a verification OTP, then proceed to create a new password.',
    ),
    _FaqItem(
      category: 'Account',
      question: 'Can a Google-linked account change its password?',
      answer:
          'Yes! If you signed up with Google, the system does not have a local password by default. Go to "Profile" -> "Change Password", enter the new password and confirm without needing the old password.',
    ),
    _FaqItem(
      category: 'Subject Enrollment',
      question: 'How do I enroll in a new subject?',
      answer:
          'Go to "Subject Enrollment" on the Feature Hub or Student Home, select an available subject and click "Enroll". Once successful, the subject will appear in your subject list.',
    ),
    _FaqItem(
      category: 'Teachers',
      question: 'How do I submit a request to become a subject instructor?',
      answer:
          'Teachers go to "Teaching Subject Enrollment" in Profile or Dashboard, select the desired subject and submit the request. The Admin will review your request.',
    ),
    _FaqItem(
      category: 'Online Exam',
      question: 'Where can I view my exam results after finishing?',
      answer:
          'Immediately after submitting or when time runs out, the system automatically grades and displays detailed results. You can also review your exam history on the "Exam Results" screen.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    return _allFaqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $label: $text'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSupportTicketModal() {
    showDialog(
      context: context,
      builder: (_) => SupportTicketDialog(
        onSubmit: (category, subject, message, priority) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request "$subject" submitted! Ticket: #TK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D3557), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 24),

            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 12),
            _buildContactGrid(),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
                Text(
                  '${_filteredFaqs.length} questions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildCategoryFilterChips(),
            const SizedBox(height: 16),
            _buildFaqList(),

            const SizedBox(height: 32),
            _buildFooterInfo(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D3557), Color(0xFF457B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3557).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: 'Search keywords (e.g. password, exam, submit)...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF15A22)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF9CA3AF)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFF15A22), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactGrid() {
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            icon: Icons.confirmation_number_rounded,
            iconColor: const Color(0xFFF15A22),
            bgColor: const Color(0xFFFFF3EE),
            title: 'Submit Ticket',
            subtitle: 'Reply via Email',
            onTap: _openSupportTicketModal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            icon: Icons.phone_in_talk_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            title: 'Hotline 24/7',
            subtitle: '1900 6868',
            onTap: () => _copyToClipboard('1900 6868', 'Hotline'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            title: 'Support Email',
            subtitle: 'support@exam.edu',
            onTap: () => _copyToClipboard('support@examsystem.edu.vn', 'Email'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: const Color(0xFFF15A22),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFF15A22) : const Color(0xFFE5E7EB),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqList() {
    final faqs = _filteredFaqs;

    if (faqs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'No matching questions found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try different keywords or click "Submit Ticket".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: faqs.map((faq) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFFF15A22),
                  size: 20,
                ),
              ),
              title: Text(
                faq.question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  faq.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFF15A22),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedAlignment: Alignment.centerLeft,
              children: [
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 12),
                Text(
                  faq.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDkjuVzVcYsKpzjWu50v7GrxIhms3Ht071Ukj4M0xvWimL32hVzhyPQ91c4_uBLcAk4gSqDFyc9vndErcgymigMCtutHjWes2bMLbZMBS4YT0KFpFkj_GwStus7jdObLiaGA5guyYveAxlff9gnl2s8Owu0-a7NXlPPowYRF8TdCo6H8GDGg7UlvWMG9IOXuvNIpb_ErAFDN75oaWd0pOQI0rBZ_Fr7L5UemYD8yRQynqpnrhsoneSA0K_yUUC6pK_u1C13BKUSX7A',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: Color(0xFFF15A22), size: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                'ExamSystem Platform v1.0.4',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Online Exam Management System for Teachers & Students',
            style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF3F4F6), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _showPolicyDialog('Terms of Use', 'All exam activities on ExamSystem must comply with the school\'s security regulations and exam rules.'),
                child: const Text('Terms of Use', style: TextStyle(fontSize: 12, color: Color(0xFF457B9D))),
              ),
              const Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
              TextButton(
                onPressed: () => _showPolicyDialog('Privacy Policy', 'Your personal data and exam submissions are securely encrypted per JWT & HTTPS security standards.'),
                child: const Text('Privacy Policy', style: TextStyle(fontSize: 12, color: Color(0xFF457B9D))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Color(0xFF1D3557), fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(content, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFFF15A22))),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
