// ignore_for_file: use_build_context_synchronously

import 'package:controller/provider/users.dart';
import 'package:controller/schema/state/state.dart';
import 'package:controller/schema/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnUserChoicePage extends HookConsumerWidget {
  const OnUserChoicePage({required this.stateItem, super.key});
  final StateItem stateItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUser = useState<UserModel?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OnUserChoicePage'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ユーザ選択
            const Text('移動が完了してから続行処理をしてください'),
            ref.watch(usersFutureProvider).when<Widget>(
                  loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(error.toString()),
                  ),
                  data: (data) => Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<UserModel?>(
                          value: null,
                          groupValue: selectedUser.value,
                          title: const Text('ユーザなし'),
                          subtitle: const Text('null'),
                          secondary: const Icon(Icons.person_add_disabled),
                          onChanged: (_) => selectedUser.value = _,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final user = data[index];
                            return RadioListTile<UserModel?>(
                              groupValue: selectedUser.value,
                              title: Text('ユーザID: ${user.id}'),
                              value: user,
                              secondary: Text('RIDE: ${user.rideId}'),
                              subtitle: Text(
                                DateFormat('yyyy/MM/dd HH:mm:ss')
                                    .format(user.createdAt),
                              ),
                              onChanged: (v) => selectedUser.value = v,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Supabase.instance.client
              .from('state')
              .update(<String, dynamic>{
                'big_question_state': BigQuestionState.waitingForAdmin.name,
              })
              .eq('position', stateItem.position.name)
              .execute();
          if (res.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.error!.message),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('更新しました'),
              ),
            );
          }

          // TODO(YumNumm): ここで、ユーザの選択を反映させる
        },
        label: const Text('続行'),
      ),
    );
  }
}