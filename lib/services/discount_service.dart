// discount_service.dart
import '../models/cart_item.dart';
import '../models/discount.dart';

class DiscountCalculator {
  static double applyDiscounts(List<CartItem> items, List<DiscountCampaign> campaigns) {
    double total = items.fold(0, (sum, item) => sum + item.price);

    DiscountCampaign? coupon = campaigns.firstWhere(
      (c) => c.category == DiscountCategory.coupon
    );

    DiscountCampaign? onTop = campaigns.firstWhere(
      (c) => c.category == DiscountCategory.onTop
    );

    DiscountCampaign? seasonal = campaigns.firstWhere(
      (c) => c.category == DiscountCategory.seasonal
    );

    if (coupon != null) {
      total = applyCoupon(total, coupon);
    }

    if (onTop != null) {
      total = applyOnTop(total, items, onTop);
    }

    if (seasonal != null) {
      total = applySeasonal(total, seasonal);
    }

    return total;
  }

  static double applyCoupon(double total, DiscountCampaign campaign) {
    if (campaign.type == DiscountType.fixed) {
      return (total - campaign.params['amount']).clamp(0, double.infinity);
    } else if (campaign.type == DiscountType.percentage) {
      return total * (1 - (campaign.params['percentage'] / 100));
    }
    return total;
  }

  static double applyOnTop(double total, List<CartItem> items, DiscountCampaign campaign) {
    if (campaign.type == DiscountType.categoryPercentage) {
      String cat = campaign.params['category'];
      double percent = campaign.params['amount'];
      double categoryTotal = items
          .where((i) => i.category == cat)
          .fold(0, (sum, item) => sum + item.price);
      return total - (categoryTotal * percent / 100);
    } else if (campaign.type == DiscountType.points) {
      int points = campaign.params['points'];
      double maxDiscount = total * 0.2;
      return total - points.clamp(0, maxDiscount);
    }
    return total;
  }

  static double applySeasonal(double total, DiscountCampaign campaign) {
    double every = campaign.params['every'];
    double discount = campaign.params['discount'];
    int times = (total / every).floor();
    return total - (discount * times);
  }
}
