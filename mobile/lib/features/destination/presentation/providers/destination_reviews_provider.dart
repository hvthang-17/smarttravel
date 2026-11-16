import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttravel_mobile/core/network/api_client.dart';
import '../../data/models/destination_review.dart';
import '../../data/repositories/destination_review_repository.dart';

final reviewRepositoryProvider =
    Provider((ref) => DestinationReviewRepository(ref.watch(dioProvider)));

final destinationReviewsProvider =
    FutureProvider.autoDispose.family<ReviewPage, int>(
  (ref, id) => ref.watch(reviewRepositoryProvider).list(id, 0),
);

final myDestinationReviewProvider =
    FutureProvider.autoDispose.family<DestinationReview?, (int, String)>(
  (ref, key) => ref.watch(reviewRepositoryProvider).mine(key.$1, key.$2),
);
