import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/data/repository/web_title_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/views/account_button.dart';
import 'package:kyouen_flutter/src/features/title/views/my_app_bar.dart';
import 'package:kyouen_flutter/src/features/title/views/my_drawer.dart';

class WebTitlePage extends ConsumerWidget {
  const WebTitlePage({super.key});

  // route name is the same as TitlePage

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      appBar: const MyAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Main Title
                const Text(
                  '共円',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                const Text(
                  '共円とは、４つの石を通る円のことです。\nこのページでは、盤上に置かれた石から共円を指摘する、「詰め共円」が多数登録されています。',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),

                const SizedBox(height: 40),

                // Stage Count Display
                Center(child: _WebStageCountDisplay()),

                const SizedBox(height: 40),

                // Navigation Links
                _buildNavigationSection(context),

                const SizedBox(height: 60),

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

                const SizedBox(height: 40),

                // Footer
                _buildFooter(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Start Game Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.restorablePushNamed(context, StagePage.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'ステージ一覧へ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Account Button (changes based on auth state)
            const OutlinedAccountButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestRegistrationsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最新の登録',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _RecentStagesDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'アクティビティ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _ActivitiesDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Copyright 2013-2024 noboru All Rights Reserved.',
        style: TextStyle(fontSize: 12, color: Colors.black45),
      ),
    );
  }
}

class _RecentStagesDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentStagesAsync = ref.watch(recentStagesProvider);

    return recentStagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, trace) {
        return Text(
          'エラーが発生しました',
          style: TextStyle(fontSize: 14, color: Colors.red.shade700),
        );
      },
      data:
          (stages) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                stages
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
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${stage.creator} - ${stage.registDate}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        // Error fetching activities: $error
        return Text(
          'エラーが発生しました',
          style: TextStyle(fontSize: 14, color: Colors.red.shade700),
        );
      },
      data:
          (activities) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                activities
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
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 32,
                                      height: 32,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.person, size: 16),
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
                                    ),
                                  ),
                                  Text(
                                    '${activity.clearedStages.length}ステージクリア',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
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

    return stageRepositoryAsync.when(
      loading:
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'ステージ情報を読み込み中...',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
      error:
          (error, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Text(
              'ステージ情報取得エラー',
              style: TextStyle(fontSize: 14, color: Colors.red.shade700),
            ),
          ),
      data:
          (repository) => FutureBuilder<Map<String, int>>(
            future: repository.getStageCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'ステージ情報を読み込み中...',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    'ステージ情報取得エラー',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                  ),
                );
              }

              final stageCount = snapshot.data ?? {};
              final clearedCount = stageCount['clear_count'] ?? 0;
              final totalCount = stageCount['count'] ?? 0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  'クリアステージ数: $clearedCount / $totalCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
    );
  }
}
