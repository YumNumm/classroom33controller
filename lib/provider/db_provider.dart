import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../api/supabase_api.dart';
import '../schema/state/state.dart';

final selectedDeviceIdProvider = StateProvider<DevicePosition?>((ref) => null);

final deviceStateStreamProvider =
    StreamProvider.autoDispose<DeviceStateItem>((ref) async* {
  await for (final item in SupabaseApi.getDeviceStateItemStream()) {
    log(item.toString(), name: 'deviceStateStreamProvider');
    if (ref.read(selectedDeviceIdProvider)?.name == item.position.name) {
      yield item;
    }
  }
});

final usersFutureProvider = FutureProvider(
  (ref) async => SupabaseApi.getUsers(),
);
