import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/destination_model.dart';
import 'destination_display.dart';
import 'favorite_button.dart';

class DestinationResultTile extends StatelessWidget {
  const DestinationResultTile(
      {super.key, required this.destination, required this.language});
  final DestinationModel destination;
  final String language;

  @override
  Widget build(BuildContext context) {
    final id = destination.id;
    final url = destinationImageUrl(destination.imageUrl);
    const placeholder =
        SizedBox(width: 52, height: 52, child: Icon(Icons.place_outlined));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: url == null
          ? placeholder
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => placeholder),
            ),
      title: Text(destinationName(destination, language),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: AppText(
          '${destinationCategoryName(destination, language)} · ${formatDestinationPrice(destination.priceMinVnd, destination.priceMaxVnd)}'),
      trailing: id == null ? null : FavoriteButton(id: id),
      onTap: id == null ? null : () => context.push('/destinations/$id'),
    );
  }
}
