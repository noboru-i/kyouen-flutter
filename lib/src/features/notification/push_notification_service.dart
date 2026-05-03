import 'dart:convert';

int? extractTargetStageNo(Map<String, dynamic> data) {
  final rawStageNos = data['stage_nos'];
  if (rawStageNos is! String || rawStageNos.isEmpty) {
    return null;
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(rawStageNos);
  } on FormatException {
    return null;
  }

  if (decoded is! List) {
    return null;
  }

  final stageNos = decoded
      .map((value) => value is int ? value : int.tryParse('$value'))
      .whereType<int>()
      .where((value) => value > 0)
      .toList();
  if (stageNos.isEmpty) {
    return null;
  }

  return stageNos.reduce((a, b) => a > b ? a : b);
}
