import 'package:flutter/material.dart';

import '../data/question_api_khanh.dart';
import '../models/question_model_khanh.dart';

class UpdateQuestionScreenKhanh extends StatefulWidget {
  final QuestionModelKhanh question;

  const UpdateQuestionScreenKhanh({
    super.key,
    required this.question,
  });

  @override
  State<UpdateQuestionScreenKhanh> createState() =>
      _UpdateQuestionScreenKhanhState();
}

class _UpdateQuestionScreenKhanhState
    extends State<UpdateQuestionScreenKhanh> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final QuestionApiKhanh _api = QuestionApiKhanh();

  late final TextEditingController _questionController;
  late final TextEditingController _explanationController;
  late String _selectedDifficulty;
  late double _score;

  final List<TextEditingController> _optionControllers = [];

  // Existing options have an ID.
  // Newly added options use null.
  final List<int?> _optionIds = [];

  final List<dynamic> _optionRowVersions = [];
  final List<int> _deletedOptionIds = [];

  int _correctIndex = 0;
  bool _isSaving = false;

  static const Color primaryColor = Color(0xfff15a22);
  static const Color backgroundColor = Color(0xfff6f7fb);
  static const Color textColor = Color(0xff183153);

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(
      text: widget.question.content,
    );
    _explanationController = TextEditingController(
      text: widget.question.explanation ?? '',
    );
    _selectedDifficulty =
    widget.question.difficulty?.isNotEmpty == true
        ? widget.question.difficulty!
        : 'Easy';
    _score = widget.question.score.toDouble();

    for (int i = 0; i < widget.question.options.length; i++) {
      final option = widget.question.options[i];

      _optionControllers.add(
        TextEditingController(
          text: option.optionText,
        ),
      );

      _optionIds.add(option.optionId);
      _optionRowVersions.add(option.rowVersion);

      if (option.isCorrect == true) {
        _correctIndex = i;
      }
    }

    // Ensure there are at least two answer options.
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
      _optionIds.add(null);
      _optionRowVersions.add(null);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();

    for (final controller in _optionControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  /* Add a new answer option. */
  void _addOption() {
    if (_isSaving) return;

    setState(() {
      _optionControllers.add(TextEditingController());
      _optionIds.add(null);
      _optionRowVersions.add(null);
    });
  }

  /* Remove an answer option and keep option IDs correctly mapped. */
  void _removeOption(int index) {
    if (_isSaving) return;

    if (_optionControllers.length <= 2) {
      _showMessage(
        'Question must have at least 2 options',
        isError: true,
      );
      return;
    }

    final optionId = _optionIds[index];

    if (optionId != null) {
      _deletedOptionIds.add(optionId);
    }

    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _optionIds.removeAt(index);
      _optionRowVersions.removeAt(index);

      if (index < _correctIndex) {
        _correctIndex--;
      } else if (index == _correctIndex) {
        _correctIndex = 0;
      }

      if (_correctIndex >= _optionControllers.length) {
        _correctIndex = 0;
      }
    });
  }

  /* Check whether answer options contain duplicate text. */
  bool _hasDuplicateOptions() {
    final options = _optionControllers
        .map(
          (controller) =>
          controller.text.trim().toLowerCase(),
    )
        .where((option) => option.isNotEmpty)
        .toList();

    return options.toSet().length != options.length;
  }

  /* Update the question, delete removed options and save all options. */
  Future<void> _saveUpdate() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    final isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    if (_hasDuplicateOptions()) {
      _showMessage(
        'Answer options must not be duplicated',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final questionBody = <String, dynamic>{
        'content': _questionController.text.trim(),
        'questionType': 'MultipleChoice',
        'difficulty': _selectedDifficulty,
        'score': _score,
        'explanation': _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        'rowVersion': widget.question.rowVersion,
      };

      await _api.updateQuestion(
        questionId: widget.question.questionId,
        body: questionBody,
      );

      for (final optionId in _deletedOptionIds) {
        await _api.deleteOption(optionId);
      }

      for (int i = 0; i < _optionControllers.length; i++) {
        final optionBody = <String, dynamic>{
          'optionText': _optionControllers[i].text.trim(),
          'isCorrect': i == _correctIndex,
          'optionOrder': i + 1,
        };

        final optionId = _optionIds[i];
        final rowVersion = _optionRowVersions[i];

        if (optionId != null) {
          if (rowVersion != null) {
            optionBody['rowVersion'] = rowVersion;
          }

          await _api.updateOption(
            optionId: optionId,
            body: optionBody,
          );
        } else {
          await _api.addOption(
            questionId: widget.question.questionId,
            body: optionBody,
          );
        }
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Update failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.redAccent : Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSaving) {
          _showMessage(
            'Please wait while the question is being updated',
            isError: true,
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior
                            .onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          18,
                          16,
                          24,
                        ),
                        children: [
                          const _LabelKhanh(
                            text: 'Subject',
                          ),
                          _buildSubjectField(),
                          const SizedBox(height: 18),
                          const _LabelKhanh(
                            text: 'Question',
                          ),
                          _buildQuestionField(),
                          const SizedBox(height: 18),

                          const _LabelKhanh(
                            text: 'Difficulty',
                          ),

                          _buildDifficultyField(),

                          const SizedBox(height: 18),
                          const SizedBox(height: 18),

                          const _LabelKhanh(
                            text: 'Score',
                          ),

                          _buildScoreField(),

                          const SizedBox(height: 18),
                          const _LabelKhanh(
                            text: 'Explanation',
                          ),

                          _buildExplanationField(),

                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          const Text(
                            'ANSWER OPTIONS',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),


                          const SizedBox(height: 6),
                          const Text(
                            'Select the correct answer using the radio button.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _optionControllers.length,
                                (index) {
                              return _OptionRowKhanh(
                                index: index,
                                controller:
                                _optionControllers[index],
                                isCorrect:
                                _correctIndex == index,
                                canDelete:
                                _optionControllers.length >
                                    2,
                                enabled: !_isSaving,
                                onCorrectTap: () {
                                  if (_isSaving) return;

                                  setState(() {
                                    _correctIndex = index;
                                  });
                                },
                                onDeleteTap: () {
                                  _removeOption(index);
                                },
                              );
                            },
                          ),
                          TextButton.icon(
                            onPressed:
                            _isSaving ? null : _addOption,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 18,
                            ),
                            label: const Text('Add Option'),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      color: primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: _isSaving
                ? null
                : () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Update Question',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffe6e8ef),
        ),
      ),
      child: Text(
        widget.question.subjectName,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuestionField() {
    return TextFormField(
      controller: _questionController,
      enabled: !_isSaving,
      minLines: 4,
      maxLines: 6,
      maxLength: 1000,
      textInputAction: TextInputAction.newline,
      validator: (value) {
        final content = value?.trim() ?? '';

        if (content.isEmpty) {
          return 'Please enter question';
        }

        if (content.length < 5) {
          return 'Question must contain at least 5 characters';
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: 'Enter question content...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xffe6e8ef),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
      ),
    );
  }
  Widget _buildScoreField() {
    final scores =
    List.generate(10, (index) => (index + 1).toDouble());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffe6e8ef),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: _score,
          isExpanded: true,
          items: scores.map((score) {
            return DropdownMenuItem<double>(
              value: score,
              child: Text(
                score.toStringAsFixed(0),
              ),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (value) {
            if (value == null) return;

            setState(() {
              _score = value;
            });
          },
        ),
      ),
    );
  }
  Widget _buildDifficultyField() {
    const difficulties = [
      'Easy',
      'Medium',
      'Hard',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffe6e8ef),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDifficulty,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: primaryColor,
          ),
          items: difficulties.map((difficulty) {
            return DropdownMenuItem<String>(
              value: difficulty,
              child: Text(
                difficulty,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (value) {
            if (value == null) return;

            setState(() {
              _selectedDifficulty = value;
            });
          },
        ),
      ),
    );
  }
  Widget _buildExplanationField() {
    return TextFormField(
      controller: _explanationController,
      enabled: !_isSaving,
      minLines: 3,
      maxLines: 5,
      maxLength: 1000,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: 'Enter explanation for the correct answer...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xffe6e8ef),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          primaryColor.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Updating...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : const Text(
          'Save Update',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LabelKhanh extends StatelessWidget {
  final String text;

  const _LabelKhanh({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff183153),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OptionRowKhanh extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool isCorrect;
  final bool canDelete;
  final bool enabled;
  final VoidCallback onCorrectTap;
  final VoidCallback onDeleteTap;

  const _OptionRowKhanh({
    required this.index,
    required this.controller,
    required this.isCorrect,
    required this.canDelete,
    required this.enabled,
    required this.onCorrectTap,
    required this.onDeleteTap,
  });

  static const Color primaryColor = Color(0xfff15a22);

  @override
  Widget build(BuildContext context) {
    final label = String.fromCharCode(65 + index);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? primaryColor
              : const Color(0xffe6e8ef),
          width: isCorrect ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isCorrect
                ? primaryColor
                : const Color(0xffeef1f6),
            child: Text(
              label,
              style: TextStyle(
                color:
                isCorrect ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              maxLength: 500,
              validator: (value) {
                final option = value?.trim() ?? '';

                if (option.isEmpty) {
                  return 'Enter option $label';
                }

                return null;
              },
              decoration: InputDecoration(
                hintText: 'Option $label',
                counterText: '',
                border: InputBorder.none,
                errorMaxLines: 2,
              ),
            ),
          ),
          InkWell(
            onTap: enabled ? onCorrectTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isCorrect
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isCorrect
                    ? primaryColor
                    : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (canDelete)
            InkWell(
              onTap: enabled ? onDeleteTap : null,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}