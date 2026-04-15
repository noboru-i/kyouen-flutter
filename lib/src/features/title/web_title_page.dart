import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/data/repository/web_title_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/total_stage_count_provider.dart';
import 'package:kyouen_flutter/src/features/title/views/account_button.dart';
import 'package:kyouen_flutter/src/features/title/views/my_app_bar.dart';
import 'package:kyouen_flutter/src/features/title/views/my_drawer.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class WebTitlePage extends ConsumerWidget {
  const WebTitlePage({super.key});

  // route name is the same as TitlePage

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const MyDrawer(),
        appBar: const MyAppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Main Title
                  const Text(
                    '共円',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    '共円とは、４つの石を通る円のことです。\nこのページでは、盤上に置かれた石から共円を指摘する、「詰め共円」が多数登録されています。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white54),
                  ),

                  const SizedBox(height: 32),

                  // Stage Count Display
                  Center(child: _WebStageCountDisplay()),

                  const SizedBox(height: 40),

                  // Navigation Links
                  _buildNavigationSection(context),

                  const SizedBox(height: 48),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      // Latest Registrations Section
                      _buildLatestRegistrationsSection(),

                      // Activity Section
                      _buildActivitySection(),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  _buildFooter(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start Game Button
          FilledButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, StagePage.routeName);
            },
            child: const Text('ステージ一覧へ'),
          ),

          const SizedBox(height: 12),

          // Account Button (changes based on auth state)
          AccountButton(
            height: 52,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestRegistrationsSection() {
    return Container(
      constraints: const BoxConstraints(minWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新の登録',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _RecentStagesDisplay(),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      constraints: const BoxConstraints(minWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'アクティビティ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _ActivitiesDisplay(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Copyright 2013-2024 noboru All Rights Reserved.',
        style: TextStyle(fontSize: 12, color: Colors.white38),
      ),
    );
  }
}

class _RecentStagesDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentStagesAsync = ref.watch(recentStagesProvider);

    return recentStagesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
      error: (error, trace) {
        return const Text(
          'エラーが発生しました',
          style: TextStyle(fontSize: 14, color: Color(0xFFE53935)),
        );
      },
      data: (stages) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stages
            .take(5)
            .map(
              (stage) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '${stage.stageNo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${stage.creator} - ${stage.registDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActivitiesDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);

    return activitiesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
      error: (error, _) {
        return const Text(
          'エラーが発生しました',
          style: TextStyle(fontSize: 14, color: Color(0xFFE53935)),
        );
      },
      data: (activities) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activities
            .take(5)
            .map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        activity.image,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.screenName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${activity.clearedStages.length}ステージクリア',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WebStageCountDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageRepositoryAsync = ref.watch(stageRepositoryProvider);
    final totalAsync = ref.watch(totalStageCountProvider);

    final totalCount = totalAsync.asData?.value ?? 0;

    return stageRepositoryAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Text(
          'ステージ情報を読み込み中...',
          style: TextStyle(fontSize: 14, color: Colors.white54),
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.4),
          ),
        ),
        child: const Text(
          'ステージ情報取得エラー',
          style: TextStyle(fontSize: 14, color: Color(0xFFE53935)),
        ),
      ),
      data: (repository) => FutureBuilder<Map<String, int>>(
        future: repository.getStageCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              totalCount == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: const Text(
                'ステージ情報を読み込み中...',
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE53935).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'ステージ情報取得エラー',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE53935),
                ),
              ),
            );
          }

          final stageCount = snapshot.data ?? {};
          final clearedCount = stageCount['clear_count'] ?? 0;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'クリアステージ数: $clearedCount / $totalCount',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
