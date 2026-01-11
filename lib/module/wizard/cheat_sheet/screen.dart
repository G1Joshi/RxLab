import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/common.dart';
import '../../operators/operators.dart';
import 'cheat_sheet.dart';

class CheatSheetExplorer extends StatelessWidget {
  final List<CheatSheetCategory> categories;

  const CheatSheetExplorer({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('cheatsheet'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category, index: index);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CheatSheetCategory category;
  final int index;

  const _CategoryCard({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: category.colorValue.withValues(alpha: 0.23),
            ),
          ),
          child: ExpansionTile(
            title: Text(
              category.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            leading: Icon(category.iconData, color: category.colorValue),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: category.operators.map((op) {
                  return InkWell(
                    onTap: () {
                      final definition = Operators.all.firstWhere(
                        (d) => d.name.toLowerCase() == op.name.toLowerCase(),
                        orElse: () => Operators.all.firstWhere(
                          (d) => d.name.toLowerCase().contains(
                            op.name.toLowerCase(),
                          ),
                          orElse: () => Operators.all.first,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OperatorDetailScreen(operator_: definition),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category.colorValue.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            op.name,
                            style: TextStyle(
                              color: category.colorValue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            op.oneLiner,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn()
        .slideY(begin: 0.1, end: 0);
  }
}
