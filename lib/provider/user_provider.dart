import 'package:controller/api/supabase_api.dart';
import 'package:controller/schema/user/user_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userProvider =
    FutureProvider.autoDispose.family<UserModel, int>((ref, id) async {
  final res = await SupabaseApi.getUserData(id);
  return res;
});
