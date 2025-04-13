enum DiscountCategory { coupon, onTop, seasonal }
enum DiscountType { fixed, percentage, categoryPercentage, points, seasonal }
enum DiscountCategoryItem { clothing, accessories }

class DiscountCampaign {
  final DiscountCategory category;
  final DiscountType type;
  final Map<String, dynamic> params;

  DiscountCampaign({
    required this.category,
    required this.type,
    required this.params,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'type': type.name,
        'params': params,
      };

  factory DiscountCampaign.fromJson(Map<String, dynamic> json) => DiscountCampaign(
        category: DiscountCategory.values
            .firstWhere((e) => e.name == json['category']),
        type: DiscountType.values
            .firstWhere((e) => e.name == json['type']),
        params: Map<String, dynamic>.from(json['params']),
      );
}
