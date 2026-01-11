import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/common.dart';
import 'flash_cards.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin, DataLoadingMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  List<FlashcardData> _flashcards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    _loadData();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  Future<void> _loadData() async {
    loadData(() async {
      _flashcards = FlashcardData.all;
    });
  }

  void _nextCard() {
    _flipController.reset();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _showAnswer = false;
    });
  }

  void _previousCard() {
    _flipController.reset();
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _flashcards.isEmpty
              ? const Center(child: Text('No flashcards found'))
              : Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _flashcards.length,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Card ${_currentIndex + 1} of ${_flashcards.length}',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const Spacer(),
                    _buildFlipCard(),
                    const Spacer(),
                    _buildControls(),
                    const SizedBox(height: 40),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 24, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: AppTheme.textPrimary,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.style_rounded,
              color: Colors.white,
              size: 24,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RxLab Flashcards',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Quick memory training',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildFlipCard() {
    final card = _flashcards[_currentIndex];
    return Container(
      height: 480,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          for (int i = 2; i > 0; i--)
            Positioned(
              bottom: -i * 12.0,
              child: Container(
                width: MediaQuery.of(context).size.width - (48 + i * 20),
                height: 450,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withAlpha(255 - (i * 40)),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 100) {
                _previousCard();
              } else if (details.primaryVelocity! < -100) {
                _nextCard();
              }
            },
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final value = _flipAnimation.value;
                final isFront = value < 0.5;
                final rotation = value * math.pi;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(rotation),
                  alignment: Alignment.center,
                  child: isFront
                      ? _buildCardSide(
                          key: const ValueKey('question'),
                          title: 'QUESTION',
                          content: card.question,
                          tags: card.tags,
                          color: AppTheme.accent,
                        )
                      : Transform(
                          transform: Matrix4.rotationY(math.pi),
                          alignment: Alignment.center,
                          child: _buildCardSide(
                            key: const ValueKey('answer'),
                            title: 'ANSWER',
                            content: card.answer,
                            note: card.note,
                            info: card.info,
                            tags: card.tags,
                            color: AppTheme.primary,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide({
    required Key key,
    required String title,
    required String content,
    String? note,
    String? info,
    List<String>? tags,
    required Color color,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      height: 450,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/paper-fibers.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [color.withAlpha(60), Colors.transparent],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withAlpha(100)),
                        ),
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Icon(
                        title == 'QUESTION'
                            ? Icons.help_outline
                            : Icons.check_circle_outline,
                        color: color.withAlpha(100),
                        size: 20,
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),

                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),

                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(15)),
                      ),
                      child: Text(
                        note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  if (info != null && info.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      info,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const Spacer(flex: 3),

                  if (tags != null && tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withAlpha(15),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Tap card to flip',
                    style: TextStyle(
                      color: color.withAlpha(150),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: _previousCard,
          ),
          _buildControlButton(
            icon: Icons.refresh_rounded,
            onTap: _toggleFlip,
            isMain: true,
          ),
          _buildControlButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: _nextCard,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMain ? 20 : 16),
        decoration: BoxDecoration(
          color: isMain ? AppTheme.primary : AppTheme.surfaceLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isMain ? AppTheme.primary : Colors.black).withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isMain ? Colors.white : AppTheme.textPrimary,
          size: isMain ? 32 : 24,
        ),
      ),
    );
  }
}
