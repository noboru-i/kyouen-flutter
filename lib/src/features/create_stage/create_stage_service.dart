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
    this.kyouen,
    required this.creator,
    this.isSubmitting = false,
    this.hasSubmitted = false,
  });

  final int size;
  final String stage;
  final KyouenData? kyouen;
  final String creator;
  final bool isSubmitting;
  final bool hasSubmitted;

  CreateStageState copyWith({
    int? size,
    String? stage,
    Object? kyouen = _unset,
    String? creator,
    bool? isSubmitting,
    bool? hasSubmitted,
  }) {
    return CreateStageState(
      size: size ?? this.size,
      stage: stage ?? this.stage,
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
    stageList[index] = stageList[index] == StoneState.none.value
        ? StoneState.white.value
        : StoneState.none.value;
    final newStage = stageList.join();

    final kyouenData = _checkKyouen(newStage);
    state = AsyncData(
      currentData.copyWith(stage: newStage, kyouen: kyouenData),
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
    final stones = stonesFromString(stage);
    if (stones.length < 4) {
      return null;
    }
    return Kyouen(stones).hasKyouen();
  }
}
