import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import '../providers/favorite_provider.dart';

Future<void> toggleFavorite(BuildContext context, WidgetRef ref, int id) async {
  if (!ref.read(authNotifierProvider).isAuthenticated) {
    context.push('/login');
    return;
  }
  final notifier = ref.read(favoritesProvider.notifier);
  if (ref.read(favoritesProvider).hasError) {
    await notifier.reload();
    if (!context.mounted) return;
  }
  try {
    await notifier.toggle(id);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AppText(error.toString().replaceFirst('Exception: ', '')),
      ));
    }
  }
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final saved = favorites.valueOrNull?.any((item) => item.id == id) ?? false;
    return IconButton(
      tooltip: AppLanguage.text(context, saved ? 'Bỏ lưu địa điểm' : 'Lưu địa điểm'),
      onPressed:
          favorites.isLoading ? null : () => toggleFavorite(context, ref, id),
      icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
    );
  }
}
