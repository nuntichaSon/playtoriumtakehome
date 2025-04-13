import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cart_item.dart';
import '../models/discount.dart';
import '../services/discount_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tent Lee's Lovely Purple Theme Colors
  final Color _primaryPurple = const Color(0xFF8A4FFF);
  final Color _lightPurple = const Color(0xFFB9A0FF);
  final Color _darkPurple = const Color(0xFF6A1B9A);
  final Color _accentPink = const Color(0xFFFF6EC7);
  final Color _softWhite = const Color(0xFFF5F5F5);

  final List<CartItem> allItems = [
   CartItem(name: 'T-Shirt', category: 'Clothing', price: 350),
    CartItem(name: 'Hoodie', category: 'Clothing', price: 700),
    CartItem(name: 'Watch', category: 'Accessories', price: 850),
    CartItem(name: 'Bag', category: 'Accessories', price: 640),
    CartItem(name: 'Belt', category: 'Accessories', price: 230),
    CartItem(name: 'Sneakers', category: 'Footwear', price: 1200),
    CartItem(name: 'Sandals', category: 'Footwear', price: 450),
    CartItem(name: 'Jeans', category: 'Clothing', price: 800),
    CartItem(name: 'Sunglasses', category: 'Accessories', price: 550),
  ];

  List<DiscountCampaign> allCoupons = [
    DiscountCampaign(
      category: DiscountCategory.coupon,
      type: DiscountType.fixed,
      params: {'amount': 50.0},
    ),
    DiscountCampaign(
      category: DiscountCategory.coupon,
      type: DiscountType.percentage,
      params: {'percentage': 10.0},
    ),
  ];

  List<DiscountCampaign> allOnTops = [
    DiscountCampaign(
      category: DiscountCategory.onTop,
      type: DiscountType.categoryPercentage,
      params: {'category': 'Clothing', 'amount': 15.0},
    ),
    DiscountCampaign(
      category: DiscountCategory.onTop,
      type: DiscountType.points,
      params: {'points': 68},
    ),
  ];

  List<DiscountCampaign> allSeasonals = [
    DiscountCampaign(
      category: DiscountCategory.seasonal,
      type: DiscountType.seasonal,
      params: {'every': 300.0, 'discount': 40.0},
    ),
  ];

  List<CartItem> selectedItems = [];
  DiscountCampaign? selectedCoupon;
  DiscountCampaign? selectedOnTop;
  DiscountCampaign? selectedSeasonal;

  double totalPrice = 0;
  double subtotal = 0;
  List<String> appliedDiscounts = [];

  // Add discount dialog controllers
  final TextEditingController _discountAmountController = TextEditingController();
  final TextEditingController _discountPercentageController = TextEditingController();
  final TextEditingController _discountCategoryController = TextEditingController();
  final TextEditingController _discountPointsController = TextEditingController();
  final TextEditingController _discountEveryController = TextEditingController();
  final TextEditingController _discountValueController = TextEditingController();
  DiscountCategory? _selectedDiscountCategory;
  DiscountType? _selectedDiscountType;

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  @override
  void dispose() {
    _discountAmountController.dispose();
    _discountPercentageController.dispose();
    _discountCategoryController.dispose();
    _discountEveryController.dispose();
    _discountPointsController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  void calculateTotal() {
    subtotal = selectedItems.fold(0, (sum, item) => sum + item.price);
    appliedDiscounts = [];
    totalPrice = subtotal;

    if (selectedItems.isEmpty) {
      setState(() {
        totalPrice = 0;
        appliedDiscounts = [];
      });
      return;
    }

    // Apply coupon discount first
    if (selectedCoupon != null) {
      double before = totalPrice;
      totalPrice = DiscountCalculator.applyCoupon(totalPrice, selectedCoupon!);
      appliedDiscounts.add('Coupon: -${(before - totalPrice).toStringAsFixed(2)} ฿');
    }

    // Apply on top discount
    if (selectedOnTop != null) {
      double before = totalPrice;
      totalPrice = DiscountCalculator.applyOnTop(totalPrice, selectedItems, selectedOnTop!);
      appliedDiscounts.add('OnTop: -${(before - totalPrice).toStringAsFixed(2)} ฿');
    }

    // Apply seasonal discount last
    if (selectedSeasonal != null) {
      double before = totalPrice;
      totalPrice = DiscountCalculator.applySeasonal(totalPrice, selectedSeasonal!);
      appliedDiscounts.add('Seasonal: -${(before - totalPrice).toStringAsFixed(2)} ฿');
    }

    setState(() {});
  }

  Future<void> _showAddDiscountDialog(DiscountCategory category) async {
    _selectedDiscountCategory = category;
    _selectedDiscountType = null;
    _discountAmountController.clear();
    _discountPercentageController.clear();
    _discountPointsController.clear();
    _discountEveryController.clear();
    _discountValueController.clear();
    _discountCategoryController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add ${category.name} Discount',
                style: TextStyle(color: _darkPurple),
              ),
              backgroundColor: _softWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _lightPurple),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<DiscountType>(
                        value: _selectedDiscountType,
                        hint: Text('Select discount type', style: TextStyle(color: _darkPurple)),
                        isExpanded: true,
                        items: _getDiscountTypesForCategory(category).map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              _getDiscountTypeName(type),
                              style: TextStyle(color: _darkPurple),
                            ),
                          );
                        }).toList(),
                        onChanged: (type) {
                          setState(() {
                            _selectedDiscountType = type;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedDiscountType != null) ...[
                      _buildDiscountInputFields(),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: _darkPurple)),
                ),
                ElevatedButton(
                  onPressed: _selectedDiscountType == null ? null : () {
                    _addNewDiscount(category);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<DiscountType> _getDiscountTypesForCategory(DiscountCategory category) {
    switch (category) {
      case DiscountCategory.coupon:
        return [DiscountType.fixed, DiscountType.percentage];
      case DiscountCategory.onTop:
        return [DiscountType.categoryPercentage, DiscountType.points];
      case DiscountCategory.seasonal:
        return [DiscountType.seasonal];
    }
  }

  String _getDiscountTypeName(DiscountType type) {
    switch (type) {
      case DiscountType.fixed:
        return 'Fixed Amount';
      case DiscountType.percentage:
        return 'Percentage Off';
      case DiscountType.categoryPercentage:
        return 'Category Percentage';
      case DiscountType.points:
        return 'Points Discount';
      case DiscountType.seasonal:
        return 'Seasonal Fixed';
    }
  }

  Widget _buildDiscountInputFields() {
    switch (_selectedDiscountType) {
      case DiscountType.fixed:
        return TextField(
          controller: _discountAmountController,
          decoration: InputDecoration(
            labelText: 'Discount Amount',
            hintText: 'e.g. 50',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _lightPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryPurple),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case DiscountType.percentage:
        return TextField(
          controller: _discountPercentageController,
          decoration: InputDecoration(
            labelText: 'Discount Percentage',
            hintText: 'e.g. 10',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _lightPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryPurple),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case DiscountType.categoryPercentage:
        return Column(
          children: [
            TextField(
              controller: _discountCategoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Clothing',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _lightPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountValueController,
              decoration: InputDecoration(
                labelText: 'Discount Percentage',
                hintText: 'e.g. 15',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _lightPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryPurple),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        );
      case DiscountType.points:
        return TextField(
          controller: _discountPointsController,
          decoration: InputDecoration(
            labelText: 'Points',
            hintText: 'e.g. 68',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _lightPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryPurple),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case DiscountType.seasonal:
        return Column(
          children: [
            TextField(
              controller: _discountEveryController,
              decoration: InputDecoration(
                labelText: 'Every X THB',
                hintText: 'e.g. 300',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _lightPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryPurple),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountValueController,
              decoration: InputDecoration(
                labelText: 'Discount Amount',
                hintText: 'e.g. 40',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _lightPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryPurple),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _addNewDiscount(DiscountCategory category) {
    Map<String, dynamic> params = {};

    switch (_selectedDiscountType!) {
      case DiscountType.fixed:
        params = {'amount': double.parse(_discountAmountController.text)};
        break;
      case DiscountType.percentage:
        params = {'percentage': double.parse(_discountPercentageController.text)};
        break;
      case DiscountType.categoryPercentage:
        params = {
          'category': _discountCategoryController.text,
          'amount': double.parse(_discountValueController.text),
        };
        break;
      case DiscountType.points:
        params = {'points': int.parse(_discountPointsController.text)};
        break;
      case DiscountType.seasonal:
        params = {
          'every': double.parse(_discountEveryController.text),
          'discount': double.parse(_discountValueController.text),
        };
        break;
    }

    final newDiscount = DiscountCampaign(
      category: category,
      type: _selectedDiscountType!,
      params: params,
    );

    setState(() {
      switch (category) {
        case DiscountCategory.coupon:
          allCoupons.add(newDiscount);
          break;
        case DiscountCategory.onTop:
          allOnTops.add(newDiscount);
          break;
        case DiscountCategory.seasonal:
          allSeasonals.add(newDiscount);
          break;
      }
    });
    calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softWhite,
      appBar: AppBar(
        title: const Text('Discount Calculator'),
        centerTitle: true,
        backgroundColor: _primaryPurple,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items Section
            _buildSectionHeader('Select Items', icon: Icons.shopping_bag),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return _buildItemCard(item);
                },
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Coupons Section
            _buildDiscountSection(
              title: 'Coupon Discounts',
              icon: Icons.local_offer,
              discountList: allCoupons,
              selectedDiscount: selectedCoupon,
              onSelected: (c) {
                setState(() {
                  selectedCoupon = c;
                  calculateTotal();
                });
              },
              onAdd: () => _showAddDiscountDialog(DiscountCategory.coupon),
            ),
            
            const SizedBox(height: 24),
            
            // OnTop Section
            _buildDiscountSection(
              title: 'OnTop Discounts',
              icon: Icons.star,
              discountList: allOnTops,
              selectedDiscount: selectedOnTop,
              onSelected: (c) {
                setState(() {
                  selectedOnTop = c;
                  calculateTotal();
                });
              },
              onAdd: () => _showAddDiscountDialog(DiscountCategory.onTop),
            ),
            
            const SizedBox(height: 24),
            
            // Seasonal Section
            _buildDiscountSection(
              title: 'Seasonal Discounts',
              icon: Icons.wb_sunny,
              discountList: allSeasonals,
              selectedDiscount: selectedSeasonal,
              onSelected: (c) {
                setState(() {
                  selectedSeasonal = c;
                  calculateTotal();
                });
              },
              onAdd: () => _showAddDiscountDialog(DiscountCategory.seasonal),
            ),
            
            const SizedBox(height: 28),
            
            // Summary Section
            _buildSectionHeader('Order Summary', icon: Icons.receipt),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal:', '${subtotal.toStringAsFixed(2)} ฿'),
                  const Divider(height: 24, color: Colors.black12),
                  if (appliedDiscounts.isNotEmpty) ...[
                    ...appliedDiscounts.map((discount) => 
                      _buildSummaryRow(discount.split(':')[0] + ':', 
                      discount.split(':')[1].trim(),
                      isDiscount: true,
                    )).toList(),
                    const Divider(height: 24, color: Colors.black12),
                  ],
                  _buildSummaryRow(
                    'Total:',
                    '${totalPrice.toStringAsFixed(2)} ฿',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection({
    required String title,
    required IconData icon,
    required List<DiscountCampaign> discountList,
    required DiscountCampaign? selectedDiscount,
    required Function(DiscountCampaign?) onSelected,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionHeader(title, icon: icon),
            const Spacer(),
            FloatingActionButton(
              onPressed: onAdd,
              mini: true,
              backgroundColor: _primaryPurple,
              child: Icon(Icons.add, color: _softWhite),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDiscountChips(discountList, selectedDiscount, onSelected),
      ],
    );
  }

  Widget _buildSectionHeader(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: _darkPurple, size: 24),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkPurple,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(CartItem item) {
    bool isSelected = selectedItems.contains(item);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? selectedItems.remove(item) : selectedItems.add(item);
          calculateTotal();
        });
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isSelected ? _lightPurple.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryPurple : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(item.category),
              size: 32,
              color: isSelected ? _primaryPurple : _darkPurple,
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? _primaryPurple : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${item.price.toStringAsFixed(2)} ฿',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? _primaryPurple : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Clothing':
        return Icons.checkroom;
      case 'Accessories':
        return Icons.watch;
      default:
        return Icons.shopping_basket;
    }
  }

  Widget _buildDiscountChips(
    List<DiscountCampaign> discounts,
    DiscountCampaign? selected,
    Function(DiscountCampaign?) onSelected,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: discounts.map((discount) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ChoiceChip(
            label: Text(
              _getDiscountLabel(discount),
              style: TextStyle(
                color: selected == discount ? Colors.white : _darkPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: selected == discount,
            onSelected: (selected) => onSelected(selected ? discount : null),
            selectedColor: _primaryPurple,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected == discount ? _primaryPurple : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
        );
      }).toList(),
    );
  }

  String _getDiscountLabel(DiscountCampaign discount) {
    switch (discount.type) {
      case DiscountType.fixed:
        return '${discount.params['amount']} ฿ OFF';
      case DiscountType.percentage:
        return '${discount.params['percentage']}% OFF';
      case DiscountType.categoryPercentage:
        return '${discount.params['amount']}% ${discount.params['category']}';
      case DiscountType.points:
        return '${discount.params['points']} Points';
      case DiscountType.seasonal:
        return 'Get ${_discountValueController.text} ฿ off , Every ${_discountEveryController.text} ฿ spent';
      default:
        return 'Discount';
    }
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? _accentPink : _darkPurple,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? _accentPink : _darkPurple,
            ),
          ),
        ],
      ),
    );
  }
}