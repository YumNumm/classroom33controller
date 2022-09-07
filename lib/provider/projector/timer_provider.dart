import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../schema/state/state.dart';

final onQuestionTimerProvdier =
    StreamProvider.autoDispose.family<OnQuestionTimerState, DevicePosition>(
  (ref, position) async* {
    for (final state in OnQuestionTimerState.values) {
      yield state;
      log(state.toString(), name: 'onQuestionTimerProvdier');
      await Future<void>.delayed(Duration(milliseconds: state.duration));
    }
    // TODO(YumNumm): 終了処理
  },
);

// TODO(YumNumm): パラメータの調節
enum OnQuestionTimerState {
  wait1(0, '開始待機中...'),
  question1(2000, '小問1(20sec)'),
  wait2(2500, '小問2待機(2.5sec)'),
  question2(2000, '小問2(20sec)'),
  wait3(2500, '小問3待機(2.5sec)'),
  question3(2000, '小問3(20sec)'),
  end(0, 'お疲れさまでした～');

  const OnQuestionTimerState(this.duration, this.title);

  /// 待機時間(ms)
  final int duration;

  /// タイトル(表示しない)
  final String title;
}
