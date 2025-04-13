import '../models/cart_item.dart';
import '../models/discount.dart';

final List<CartItem> sampleCartItems = [
  CartItem(name: 'T-Shirt', category: 'Clothing', price: 350),
  CartItem(name: 'Hoodie', category: 'Clothing', price: 700),
  CartItem(name: 'Watch', category: 'Accessories', price: 850),
  CartItem(name: 'Bag', category: 'Accessories', price: 640),
];

final List<DiscountCampaign> sampleCampaigns = [
  // Coupon: 10% off
  DiscountCampaign(
    category: DiscountCategory.coupon,
    type: DiscountType.percentage,
    params: {'percentage': 10},
  ),

  // On Top: 15% off on Clothing
  DiscountCampaign(
    category: DiscountCategory.onTop,
    type: DiscountType.categoryPercentage,
    params: {'category': 'Clothing', 'amount': 15.0},
  ),

  // Seasonal: 40 THB off every 300 THB
  DiscountCampaign(
    category: DiscountCategory.seasonal,
    type: DiscountType.seasonal,
    params: {'every': 300.0, 'discount': 40.0},
  ),
];
