import 'dart:developer';

import 'package:controller/page/main.dart';
import 'package:controller/provider/db_provider.dart';
import 'package:controller/schema/state/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'private/key.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    debug: kDebugMode,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const PositionSelectPage(),
      ),
    );
  }
}

class PositionSelectPage extends HookConsumerWidget {
  const PositionSelectPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDeviceId =
        useState<DevicePosition>(DevicePosition.projector1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Selector'),
      ),
      body: Column(
        children: [
          // DevicePositionの一覧
          for (final item in DevicePosition.values)
            RadioListTile(
              value: item,
              groupValue: selectedDeviceId.value,
              onChanged: (_) {
                selectedDeviceId.value = item;
              },
              title: Text(item.toString()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedDeviceIdProvider.notifier).state =
              selectedDeviceId.value;
          log(ref.read(selectedDeviceIdProvider).toString());
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => const TopPage(),
            ),
          );
        },
        label: const Text('開始'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

List<Color> colorFromPosision(DevicePosition position) {
  switch (position) {
    case DevicePosition.projector1:
      return [
        const Color.fromARGB(255, 89, 191, 179),
        const Color.fromARGB(255, 65, 92, 179),
      ];
    case DevicePosition.projector2:
      return [
        const Color.fromARGB(255, 65, 92, 179),
        const Color.fromARGB(255, 179, 115, 179),
      ];
    case DevicePosition.projector3:
      return [
        const Color.fromARGB(255, 255, 114, 16),
        const Color.fromARGB(255, 191, 184, 43),
      ];
    default:
      return [
        const Color.fromARGB(255, 17, 91, 175),
        const Color.fromARGB(255, 73, 173, 255),
      ];
  }
}
