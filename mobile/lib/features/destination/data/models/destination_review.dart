class DestinationReview {
  final int id;
  final int rating;
  final String? comment;
  final String? status;
  final DateTime createdAt;

  const DestinationReview(
      this.id, this.rating, this.comment, this.status, this.createdAt);

  factory DestinationReview.fromJson(Map<String, dynamic> json) =>
      DestinationReview(
        json['id'] as int,
        json['rating'] as int,
        json['comment'] as String?,
        json['status'] as String?,
        DateTime.parse(json['createdAt'] as String),
      );
}

typedef ReviewPage = ({List<DestinationReview> items, bool hasNext});
typedef ReviewInput = ({int rating, String? comment});

const reviewReportReasons = {
  'SPAM': 'Quảng cáo hoặc spam',
  'ABUSE': 'Nội dung xúc phạm',
  'IRRELEVANT': 'Không liên quan đến địa điểm',
  'OTHER': 'Lý do khác',
};
