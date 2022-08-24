import 'package:controller/main.dart';
import 'package:controller/provider/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopPage extends HookConsumerWidget {
  const TopPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller'),
        elevation: 8,
        backgroundColor: colorFromPosision(
          ref.watch(selectedDeviceIdProvider.notifier).state!,
        )[0]
            .withAlpha(127),
      ),
      body: ref.watch(deviceStateStreamProvider).when<Widget>(
            data: (data) => Text(data.toJson().toString()),
            error: (error, stackTrace) => Center(child: Text('error: $error')),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
    );
  }
}
