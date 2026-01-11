import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/common.dart';
import '../../widget/widget.dart';
import 'quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin, DataLoadingMixin {
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _quizComplete = false;
  String _difficulty = 'all';
  String _category = 'all';
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _questions = [];
  late AnimationController _streakController;

  @override
  void initState() {
    super.initState();
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    loadData(() async {
      _allQuestions = QuizQuestion.all;
      _resetQuiz();
    });
  }

  @override
  void dispose() {
    _streakController.dispose();
    super.dispose();
  }

  void _resetQuiz() {
    var questions = List<QuizQuestion>.from(_allQuestions);

    if (_difficulty != 'all') {
      questions = questions.where((q) => q.difficulty == _difficulty).toList();
    }

    if (_category != 'all') {
      questions = questions.where((q) => q.category == _category).toList();
    }

    questions.shuffle(Random());
    _questions = questions.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _streak = 0;
    _selectedAnswer = null;
    _showResult = false;
    _quizComplete = false;
    setState(() {});
  }

  void _selectAnswer(int index) {
    if (_showResult) return;
    HapticFeedback.lightImpact();

    final isCorrect = index == _questions[_currentIndex].correctIndex;

    setState(() {
      _selectedAnswer = index;
      _showResult = true;
      if (isCorrect) {
        _score++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _streakController.forward(from: 0);
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      setState(() => _quizComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _quizComplete
              ? _buildResults()
              : _buildQuiz(),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No questions match your filters',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _difficulty = 'all';
                _category = 'all';
                _resetQuiz();
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    final question = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(question),
          const SizedBox(height: 16),
          _buildQuestion(question),
          const SizedBox(height: 20),
          Expanded(child: _buildAnswers(question)),
          if (_showResult) _buildExplanation(question),
        ],
      ),
    );
  }

  Widget _buildHeader(QuizQuestion question) {
    return Column(
      children: [
        ModuleHeader(
          title: 'RxLab Quiz',
          subtitle: 'Question ${_currentIndex + 1}/${_questions.length}',
          icon: Icons.quiz_rounded,
          gradientColors: const [Colors.orange, Colors.deepOrange],
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_score pts',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_streak > 1)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                      CurvedAnimation(
                        parent: _streakController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🔥 $_streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation(AppTheme.primary),
            minHeight: 4,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuestion(QuizQuestion question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [question.categoryColor.withAlpha(30), AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: question.categoryColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: question.categoryColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.category,
                  style: TextStyle(
                    color: question.categoryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (question.type != 'multiple_choice')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(question.typeIcon, size: 12, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text(
                        question.type == 'predict_output'
                            ? 'Predict'
                            : 'Find Bug',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                '+${question.points}',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),

          if (question.input != null || question.code != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (question.input != null)
                    Text(
                      'Input: ${question.input}',
                      style: GoogleFonts.sourceCodePro(
                        color: AppTheme.success,
                        fontSize: 12,
                      ),
                    ),
                  if (question.operator != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '.${question.operator}',
                      style: GoogleFonts.sourceCodePro(
                        color: const Color(0xFFE6EDF3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (question.code != null)
                    Text(
                      question.code!,
                      style: GoogleFonts.sourceCodePro(
                        color: const Color(0xFFE6EDF3),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildAnswers(QuizQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedAnswer == index;
        final isCorrect = index == question.correctIndex;

        Color bgColor = AppTheme.surfaceLight;
        Color borderColor = Colors.transparent;
        IconData? icon;

        if (_showResult) {
          if (isCorrect) {
            bgColor = AppTheme.success.withAlpha(30);
            borderColor = AppTheme.success;
            icon = Icons.check_circle;
          } else if (isSelected) {
            bgColor = AppTheme.error.withAlpha(30);
            borderColor = AppTheme.error;
            icon = Icons.cancel;
          }
        } else if (isSelected) {
          bgColor = AppTheme.primary.withAlpha(30);
          borderColor = AppTheme.primary;
        }

        return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _selectAnswer(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isCorrect || !_showResult
                                    ? AppTheme.primary
                                    : Colors.red)
                              : AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.textMuted.withAlpha(80),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (icon != null)
                        Icon(
                          icon,
                          color: isCorrect ? AppTheme.success : AppTheme.error,
                        ),
                    ],
                  ),
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn()
            .slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildExplanation(QuizQuestion question) {
    final isCorrect = _selectedAnswer == question.correctIndex;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.info.withAlpha(50)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.explanation,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _nextQuestion,
            icon: Icon(isCorrect ? Icons.arrow_forward : Icons.refresh),
            label: Text(
              _currentIndex < _questions.length - 1
                  ? 'Next Question'
                  : 'See Results',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? AppTheme.success : AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final percentage = (_score / _questions.length * 100).round();
    String title;
    String subtitle;
    Color color;
    IconData icon;

    if (percentage >= 90) {
      title = '🎉 Rx Master!';
      subtitle = 'Outstanding performance!';
      color = AppTheme.success;
      icon = Icons.emoji_events;
    } else if (percentage >= 70) {
      title = '👏 Great Job!';
      subtitle = 'You know your Rx well!';
      color = AppTheme.info;
      icon = Icons.thumb_up;
    } else if (percentage >= 50) {
      title = '📚 Keep Learning';
      subtitle = 'You\'re getting there!';
      color = Colors.orange;
      icon = Icons.school;
    } else {
      title = '💪 Practice More';
      subtitle = 'Every expert was once a beginner';
      color = Colors.red;
      icon = Icons.refresh;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: color),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(
                  label: 'Score',
                  value: '$_score/${_questions.length}',
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  label: 'Accuracy',
                  value: '$percentage%',
                  color: color,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  label: 'Best Streak',
                  value: '🔥 $_bestStreak',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassDecoration,
              child: Column(
                children: [
                  Text(
                    'Filter by difficulty:',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Easy',
                        isSelected: _difficulty == 'easy',
                        onTap: () => setState(
                          () => _difficulty = _difficulty == 'easy'
                              ? 'all'
                              : 'easy',
                        ),
                        color: Colors.green,
                      ),
                      _FilterChip(
                        label: 'Medium',
                        isSelected: _difficulty == 'medium',
                        onTap: () => setState(
                          () => _difficulty = _difficulty == 'medium'
                              ? 'all'
                              : 'medium',
                        ),
                        color: Colors.orange,
                      ),
                      _FilterChip(
                        label: 'Hard',
                        isSelected: _difficulty == 'hard',
                        onTap: () => setState(
                          () => _difficulty = _difficulty == 'hard'
                              ? 'all'
                              : 'hard',
                        ),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
