import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class SpecialOffersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts;

  const SpecialOffersScreen({
    super.key,
    required this.allProducts,
  });

  @override
  State<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _sortBy = 'discount';
  bool _isGridView = true;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get specialOfferProducts {
    // Filter products with discounts or special badges
    var filtered = widget.allProducts.where((product) {
      return (product["discount"] != null && product["discount"] > 0) ||
             (product["badge"] != null && 
              (product["badge"].toString().toLowerCase().contains("special") ||
               product["badge"].toString().toLowerCase().contains("offer") ||
               product["badge"].toString().toLowerCase().contains("bestseller") ||
               product["badge"].toString().toLowerCase().contains("premium")));
    }).toList();
    
    // Sort by discount percentage
    switch (_sortBy) {
      case 'discount':
        filtered.sort((a, b) => (b["discount"] ?? 0).compareTo(a["discount"] ?? 0));
        break;
      case 'price_low':
        filtered.sort((a, b) => double.parse(a["price"]).compareTo(double.parse(b["price"])));
        break;
      case 'price_high':
        filtered.sort((a, b) => double.parse(b["price"]).compareTo(double.parse(a["price"])));
        break;
      case 'rating':
        filtered.sort((a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final products = specialOfferProducts;
    
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F5), // Light cream background
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildHeaderSection(products.length),
          ),
          SliverToBoxAdapter(
            child: _buildFilterSection(),
          ),
          SliverToBoxAdapter(
            child: _buildOfferBanner(),
          ),
          products.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : _isGridView
                  ? _buildGridView(products)
                  : _buildListView(products),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF8B7355)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Color(0xFF8B7355),
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(int offerCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE4E1), // Light pink
            Color(0xFFF0E6FF), // Light lavender
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFB6C1).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_offer,
                  color: Color(0xFFFF69B4),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Special Offers",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Discover amazing deals on $offerCount baby products with up to 50% off!",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.sort, color: Color(0xFF8B7355), size: 20),
          const SizedBox(width: 8),
          Text(
            "Sort by:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF69B4)),
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF69B4),
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'discount', child: Text('Highest Discount')),
                  DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                  DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                  DropdownMenuItem(value: 'rating', child: Text('Highest Rating')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB6C1), // Light pink
            Color(0xFFDDA0DD), // Plum
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFB6C1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🎉 Limited Time Offer!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Save big on premium baby products. Hurry, offers end soon!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "UP TO\n50% OFF",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: Color(0xFFDDA0DD),
          ),
          const SizedBox(height: 16),
          Text(
            "No special offers available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for amazing deals on baby products!",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildProductCard(products[index], true),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildProductCard(products[index], false),
                ),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isGrid) {
    final bool hasDiscount = product["discount"] != null && product["discount"] > 0;
    final double savings = hasDiscount && product["originalPrice"] != null
        ? double.parse(product["originalPrice"]) - double.parse(product["price"])
        : 0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              title: product["title"],
              image: product["image"],
              description: product["description"],
              price: double.parse(product["price"]),
              originalPrice: product["originalPrice"] != null 
                  ? double.parse(product["originalPrice"]) 
                  : null,
              rating: product["rating"]?.toDouble(),
              reviewCount: product["reviewCount"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isGrid ? _buildGridCard(product, hasDiscount, savings) : _buildListCard(product, hasDiscount, savings),
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> product, bool hasDiscount, double savings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: Color(0xFFFFF8F5),
                  child: Image.asset(
                    product["image"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Color(0xFFDDA0DD),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF69B4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${product["discount"]}% OFF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (product["badge"] != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0xFFDDA0DD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product["badge"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (savings > 0)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0xFF98FB98),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Save \$${savings.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF8B7355),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product["rating"] != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${product["rating"]}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${product["price"]}",
                          style: TextStyle(
                            color: Color(0xFFFF69B4),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasDiscount && product["originalPrice"] != null)
                          Text(
                            "\$${product["originalPrice"]}",
                            style: TextStyle(
                              color: Color(0xFF8B7355),
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF69B4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(Map<String, dynamic> product, bool hasDiscount, double savings) {
    return Container(
      height: 120,
      child: Row(
        children: [
          Container(
            width: 120,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color(0xFFFFF8F5),
                    child: Image.asset(
                      product["image"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Color(0xFFDDA0DD),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF69B4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${product["discount"]}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product["title"],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF8B7355),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (savings > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF98FB98).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Save \$${savings.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Color(0xFF228B22),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product["rating"] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${product["rating"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$${product["price"]}",
                            style: TextStyle(
                              color: Color(0xFFFF69B4),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (hasDiscount && product["originalPrice"] != null)
                            Text(
                              "\$${product["originalPrice"]}",
                              style: TextStyle(
                                color: Color(0xFF8B7355),
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF69B4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Buy Now", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
