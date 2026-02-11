import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

final jumpDetailProvider =
    FutureProvider.family<Jump?, String>((ref, jumpId) {
  final repo = ref.watch(jumpRepositoryProvider);
  return repo.getJumpById(jumpId);
});
