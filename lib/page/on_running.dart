import 'dart:convert';

import 'package:controller/extension/correct_answer.dart';
import 'package:controller/provider/big_question_storage.dart';
import 'package:controller/provider/projector/timer_provider.dart';
import 'package:controller/schema/state/state.dart';
import 'package:controller/schema/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../extension/position_color.dart';

class OnRunningPage extends HookConsumerWidget {
  const OnRunningPage({required this.stateItem, super.key});
  final StateItem stateItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correctAnswer = useState<int>(1);

    final timerStream = ref.watch(onQuestionTimerProvdier(stateItem.position))
      ..whenData((value) {
        HapticFeedback.vibrate();
        if (stateItem.bigQuestionGroupId == null) {
          return;
        }
        if (value == OnQuestionTimerState.question1) {
          correctAnswer.value = ref
              .read(questionProvider)
              .firstWhere((e) => e.id == stateItem.bigQuestionGroupId)
              .questions[0]
              .questions[0]
              .correctAnswerIndex;
        } else if (value == OnQuestionTimerState.question2) {
          correctAnswer.value = ref
              .read(questionProvider)
              .firstWhere((e) => e.id == stateItem.bigQuestionGroupId)
              .questions[0]
              .questions[1]
              .correctAnswerIndex;
        } else if (value == OnQuestionTimerState.question3) {
          correctAnswer.value = ref
              .read(questionProvider)
              .firstWhere((e) => e.id == stateItem.bigQuestionGroupId)
              .questions[0]
              .questions[2]
              .correctAnswerIndex;
        }
      });

    final resultCounter =
        useState<Map<int, QuestionResult>>(<int, QuestionResult>{
      1: QuestionResult(correctCount: 0, wrongCount: 0),
      2: QuestionResult(correctCount: 0, wrongCount: 0),
      3: QuestionResult(correctCount: 0, wrongCount: 0),
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('OnRunningPage'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: stateItem.position.onPrimary
                  .map((e) => e.withOpacity(0.7))
                  .toList(),
            ),
          ),
        ),
      ),
      body: timerStream.when<Widget>(
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
        data: (data) => Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(),
                Text(
                  data.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (stateItem.bigQuestionGroupId != null)
                  Card(
                    child: Column(
                      children: [
                        Row(),
                        Text(
                          '大問1 (${ref.read(questionProvider).firstWhere(
                                (e) => e.id == stateItem.bigQuestionGroupId,
                              ).questions[stateItem.position.index].questions[0].correctAnswerIndex})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        // 正答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[1]?.correctCount.toString(),
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              labelText: '正答数',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: ref
                                  .read(questionProvider)
                                  .firstWhere(
                                    (e) => e.id == stateItem.bigQuestionGroupId,
                                  )
                                  .questions[stateItem.position.index]
                                  .questions[0]
                                  .correctAnswerIndex
                                  .correctAnswerColor
                                  .withOpacity(0.3),
                            ),
                          ),
                        ),
                        // 誤答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[1]?.wrongCount.toString(),
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              labelText: '誤答数',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (stateItem.bigQuestionGroupId != null)
                  Card(
                    child: Column(
                      children: [
                        Row(),
                        Text(
                          '大問2 (${ref.read(questionProvider).firstWhere(
                                (e) => e.id == stateItem.bigQuestionGroupId,
                              ).questions[stateItem.position.index].questions[1].correctAnswerIndex})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        // 正答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[2]?.correctCount.toString(),
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              labelText: '正答数',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: ref
                                  .read(questionProvider)
                                  .firstWhere(
                                    (e) => e.id == stateItem.bigQuestionGroupId,
                                  )
                                  .questions[stateItem.position.index]
                                  .questions[1]
                                  .correctAnswerIndex
                                  .correctAnswerColor
                                  .withOpacity(0.3),
                            ),
                          ),
                        ),
                        // 誤答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[2]?.wrongCount.toString(),
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              labelText: '誤答数',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (stateItem.bigQuestionGroupId != null)
                  Card(
                    child: Column(
                      children: [
                        Row(),
                        Text(
                          '大問3 (${ref.read(questionProvider).firstWhere(
                                (e) => e.id == stateItem.bigQuestionGroupId,
                              ).questions[stateItem.position.index].questions[2].correctAnswerIndex})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        // 正答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[3]?.correctCount.toString(),
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              labelText: '正答数',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: ref
                                  .read(questionProvider)
                                  .firstWhere(
                                    (e) => e.id == stateItem.bigQuestionGroupId,
                                  )
                                  .questions[stateItem.position.index]
                                  .questions[2]
                                  .correctAnswerIndex
                                  .correctAnswerColor
                                  .withOpacity(0.3),
                            ),
                          ),
                        ),
                        // 誤答カウント用TextFormField
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue:
                                resultCounter.value[3]?.wrongCount.toString(),
                            onChanged: (value) => resultCounter.value = {
                              ...resultCounter.value,
                              3: QuestionResult(
                                correctCount: int.tryParse(value) ?? 0,
                                wrongCount:
                                    resultCounter.value[3]?.wrongCount ?? 0,
                              ),
                            },
                            decoration: const InputDecoration(
                              labelText: '誤答数',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (data == OnQuestionTimerState.end)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        // resultCounterの内容確認
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('確認'),
                              content: Text(resultCounter.value.toString()),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('キャンセル'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final supabase = Supabase.instance.client;
                                      if (stateItem.userId != null) {
                                        final res = await supabase
                                            .from('users')
                                            .select()
                                            .eq('id', stateItem.userId)
                                            .execute();
                                        if (res.hasError) {
                                          print(res.error!.toJson());
                                          throw Exception(
                                            res.error!.toJson().toString(),
                                          );
                                        }
                                        final user = UserModel.fromJson(
                                          (res.data as List)[0]
                                              as Map<String, dynamic>,
                                        );

                                        final result = QuestionsResult(
                                          items: [
                                            ...user.result.items,
                                            ...resultCounter.value.values
                                          ],
                                        );
                                        final res2 = await supabase
                                            .from('users')
                                            .update(<String, dynamic>{
                                              'result': result.toJson(),
                                            })
                                            .eq('id', user.id)
                                            .execute();
                                        if (res2.hasError) {
                                          print(res2.error!.toJson());
                                          throw Exception(
                                            res2.error!.toJson().toString(),
                                          );
                                        }
                                      }
                                      final res3 = await supabase
                                          .from('state')
                                          .update(<String, dynamic>{
                                            'big_question_group_id': null,
                                            'big_question_state':
                                                BigQuestionState
                                                    .waitingForController.name,
                                            'user_id': null,
                                          })
                                          .eq(
                                            'position',
                                            stateItem.position.name,
                                          )
                                          .execute();
                                      Navigator.of(context).pop();
                                      // snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('保存しました'),
                                        ),
                                      );
                                    } catch (e) {
                                      print(e);
                                      Navigator.of(context).pop();
                                      // snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('エラー発生\n$e'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: const Text('送信'),
                      icon: const Icon(Icons.send),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  const JsonEncoder.withIndent('  ').convert(
                    stateItem.toJson(),
                  ),
                ),
                Text(
                  data.toString(),
                ),
                Text(
                  resultCounter.value.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ProgressBarのAnimation
/// [duration] は、アニメーションの時間(ms)
/// [showPercent] パーセンテージを表示するか
class AnimatedProgressBar extends StatefulHookConsumerWidget {
  const AnimatedProgressBar({
    this.showPercent = true,
    required this.duration,
    super.key,
  });

  /// 待機時間(ms)
  final int duration;

  /// パーセンテージを表示するか
  final bool showPercent;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends ConsumerState<AnimatedProgressBar> {
  @override
  Widget build(BuildContext context) {
    final duration = widget.duration;
    final showPercent = widget.showPercent;

    final controller = useAnimationController(
      duration: Duration(milliseconds: duration),
    );

    final animatable = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.linear));

    final animation = animatable.animate(controller);

    // 描画されたらAnimation開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forward();
    });

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (showPercent) {
          return Row(
            children: [
              Text('${(animation.value * 100).toStringAsFixed(0)}%'),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: animation.value,
                  minHeight: 8,
                ),
              ),
            ],
          );
        }
        return LinearProgressIndicator(
          value: animation.value,
        );
      },
    );
  }
}
