import 'package:kyouen/kyouen.dart';
import 'package:kyouen_flutter/src/data/api/entity/new_stage.dart';
import 'package:kyouen_flutter/src/data/local/last_creator_service.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/title/total_stage_count_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_stage_service.g.dart';

// sentinel for copyWith nullable fields
const _unset = Object();

class CreateStageState {
  const CreateStageState({
    required this.size,
    required this.stage,
    required this.placedIndexes,
    this.kyouen,
    required this.creator,
    this.isSubmitting = false,
    this.hasSubmitted = false,
  });

  final int size;
  final String stage;
  final List<int> placedIndexes;
  final KyouenData? kyouen;
  final String creator;
  final bool isSubmitting;
  final bool hasSubmitted;

  CreateStageState copyWith({
    int? size,
    String? stage,
    List<int>? placedIndexes,
    Object? kyouen = _unset,
    String? creator,
    bool? isSubmitting,
    bool? hasSubmitted,
  }) {
    return CreateStageState(
      size: size ?? this.size,
      stage: stage ?? this.stage,
      placedIndexes: placedIndexes ?? this.placedIndexes,
      kyouen: identical(kyouen, _unset) ? this.kyouen : kyouen as KyouenData?,
      creator: creator ?? this.creator,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }
}

@riverpod
class CreateStage extends _$CreateStage {
  @override
  Future<CreateStageState> build() async {
    final lastCreator = await ref
        .read(lastCreatorServiceProvider)
        .getLastCreator();
    return CreateStageState(
      size: 6,
      stage: StoneState.none.value * 36,
      placedIndexes: const [],
      creator: lastCreator ?? 'no name',
    );
  }

  void setSize(int size) {
    final currentData = state.asData?.value;
    if (currentData == null) {
      return;
    }
    if (currentData.stage.contains(StoneState.white.value)) {
      return;
    }

    final cellCount = size * size;
    state = AsyncData(
      currentData.copyWith(
        size: size,
        stage: StoneState.none.value * cellCount,
        placedIndexes: const [],
      ),
    );
  }

  void tapCell(int index) {
    final currentData = state.asData?.value;
    if (currentData == null) {
      return;
    }
    if (currentData.kyouen != null) {
      return;
    }

    final stageList = currentData.stage.split('');
    if (stageList[index] != StoneState.none.value) {
      return;
    }

    stageList[index] = StoneState.black.value;
    final newStage = stageList.join();

    final kyouenData = _checkKyouen(newStage);
    if (kyouenData != null) {
      for (final point in kyouenData.points) {
        final pointIndex = point.x.toInt() + point.y.toInt() * currentData.size;
        stageList[pointIndex] = StoneState.white.value;
      }
    }

    state = AsyncData(
      currentData.copyWith(
        stage: stageList.join(),
        placedIndexes: [...currentData.placedIndexes, index],
        kyouen: kyouenData,
      ),
    );
  }

  void undo() {
    final currentData = state.asData?.value;
    if (currentData == null || currentData.placedIndexes.isEmpty) {
      return;
    }

    final stageList = currentData.stage.split('');
    final placedIndexes = [...currentData.placedIndexes];
    final lastIndex = placedIndexes.removeLast();

    for (var i = 0; i < stageList.length; i++) {
      if (stageList[i] == StoneState.white.value) {
        stageList[i] = StoneState.black.value;
      }
    }
    stageList[lastIndex] = StoneState.none.value;

    state = AsyncData(
      currentData.copyWith(
        stage: stageList.join(),
        placedIndexes: placedIndexes,
        kyouen: null,
        hasSubmitted: false,
      ),
    );
  }

  void reset() {
    final currentData = state.asData?.value;
    if (currentData == null) {
      return;
    }

    final cellCount = currentData.size * currentData.size;
    state = AsyncData(
      currentData.copyWith(
        stage: StoneState.none.value * cellCount,
        placedIndexes: const [],
        kyouen: null,
        hasSubmitted: false,
      ),
    );
  }

  void setCreator(String name) {
    final currentData = state.asData?.value;
    if (currentData == null) {
      return;
    }
    state = AsyncData(currentData.copyWith(creator: name));
  }

  Future<void> submit() async {
    final currentData = state.asData?.value;
    if (currentData == null) {
      return;
    }
    if (currentData.isSubmitting || currentData.hasSubmitted) {
      return;
    }

    state = AsyncData(currentData.copyWith(isSubmitting: true));

    try {
      final repository = await ref.read(stageRepositoryProvider.future);
      final submittedStage = currentData.stage.replaceAll(
        StoneState.white.value,
        StoneState.black.value,
      );
      await repository.createStage(
        NewStage(
          size: currentData.size,
          stage: submittedStage,
          creator: currentData.creator,
        ),
      );

      await ref
          .read(lastCreatorServiceProvider)
          .saveLastCreator(currentData.creator);
      ref.invalidate(totalStageCountProvider);

      state = AsyncData(
        currentData.copyWith(isSubmitting: false, hasSubmitted: true),
      );
    } on Exception {
      state = AsyncData(currentData.copyWith(isSubmitting: false));
      rethrow;
    }
  }

  KyouenData? _checkKyouen(String stage) {
    final stones = stonesFromString(
      stage.replaceAll(StoneState.black.value, StoneState.white.value),
    );
    if (stones.length < 4) {
      return null;
    }
    return Kyouen(stones).hasKyouen();
  }
}
