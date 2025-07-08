import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';

class WebTitlePage extends ConsumerWidget {
  const WebTitlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Main Title
              Center(
                child: Text(
                  '共円',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Center(
                child: Text(
                  '4つの石を通る円のこと',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 40),

              // Stage Count Display
              Center(child: _WebStageCountDisplay()),

              const SizedBox(height: 40),

              // Navigation Links
              _buildNavigationSection(context),

              const SizedBox(height: 60),

              // Latest Registrations Section
              _buildLatestRegistrationsSection(),

              const SizedBox(height: 40),

              // Activity Section
              _buildActivitySection(),

              const SizedBox(height: 40),

              // Footer
              _buildFooter(),

              const SizedBox(height: 40),
            ],
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
            Text(
              'ゲームを始める',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

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

            // Login Button
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.restorablePushNamed(context, SignInPage.routeName);
                },
                child: const Text(
                  'ログイン',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
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
            Text(
              '最新の登録',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '最新の登録情報はこちらに表示されます。',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
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
            Text(
              'アクティビティ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'アクティビティ情報はこちらに表示されます。',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright 2013-2024 noboru All Rights Reserved.',
        style: TextStyle(fontSize: 12, color: Colors.black45),
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
            child: Text(
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
                  child: Text(
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
