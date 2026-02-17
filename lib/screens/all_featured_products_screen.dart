import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product_detail_screen.dart';

class AllFeaturedProductsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  
  const AllFeaturedProductsScreen({
    super.key,
    required this.products,
  });

  @override
  State<AllFeaturedProductsScreen> createState() => _AllFeaturedProductsScreenState();
}

class _AllFeaturedProductsScreenState extends State<AllFeaturedProductsScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _recommendationAnimationController;
  late AnimationController _searchAnimationController; // Added search animation controller
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _recommendationFadeAnimation;
  late Animation<double> _searchScaleAnimation; // Added search scale animation
  
  String _searchQuery = '';
  String _sortBy = 'featured';
  String _filterCategory = 'All';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Added focus node for search
  
  // Smart recommendations with complete product data
  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      "title": "Baby Bottle",
      "image": "assets/images/bottle.jpg",
      "description": "Premium baby bottle with anti-colic system and easy-grip design. Perfect for feeding your little one.",
      "price": "15.99",
      "rating": 4.8,
      "reviewCount": 234,
      "category": "Feeding",
      "additionalImages": ["assets/images/bottle.jpg", "assets/images/bottle.jpg"]
    },
    {
      "title": "Pacifier Set",
      "image": "assets/images/pacifier.webp",
      "description": "Orthodontic pacifier set designed for healthy oral development. BPA-free and safe for babies.",
      "price": "8.50",
      "rating": 4.6,
      "reviewCount": 189,
      "category": "Comfort",
      "additionalImages": ["assets/images/pacifier.jpg", "assets/images/pacifier-.jpg"]
    },
    {
      "title": "Baby Bib",
      "image": "assets/images/bib.webp",
      "description": "Waterproof baby bib with cute animal designs. Easy to clean and comfortable for daily use.",
      "price": "6.99",
      "rating": 4.7,
      "reviewCount": 156,
      "category": "Feeding",
      "additionalImages": ["assets/images/bib.webp", "assets/images/bib.webp"]
    },
    {
      "title": "Baby Care Kit",
      "image": "assets/images/care.jpg",
      "description": "Complete grooming kit with nail clippers, brush, thermometer, and more essentials.",
      "price": "28.99",
      "rating": 4.5,
      "reviewCount": 167,
      "category": "Care",
      "additionalImages": ["assets/images/care.jpg", "assets/images/care.jpg"]
    },
  ];

  // Recently viewed with complete data
  final List<Map<String, dynamic>> _recentlyViewed = [
    {
      "title": "Soft Baby Blanket",
      "image": "assets/images/blankets.webp",
      "description": "Ultra-soft blanket made from premium materials for maximum comfort.",
      "price": "25.00",
      "rating": 4.5,
      "reviewCount": 89,
      "category": "Clothing",
      "additionalImages": ["assets/images/blankets.webp"]
    },
    {
      "title": "Colorful Rattle",
      "image": "assets/images/rattle.jpg",
      "description": "Safe, colorful rattle designed to stimulate baby's senses and development.",
      "price": "8.00",
      "rating": 4.3,
      "reviewCount": 45,
      "category": "Toys",
      "additionalImages": ["assets/images/rattle.jpg"]
    },
    {
      "title": "Baby Lotion",
      "image": "assets/images/lotion.webp",
      "description": "Gentle, moisturizing lotion specially formulated for baby's delicate skin.",
      "price": "12.50",
      "rating": 4.7,
      "reviewCount": 123,
      "category": "Baby Care",
      "additionalImages": ["assets/images/lotion.webp"]
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _recommendationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    
    _recommendationFadeAnimation = CurvedAnimation(
      parent: _recommendationAnimationController,
      curve: Curves.easeInOut,
    );

    _searchScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });
    
    _animationController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _recommendationAnimationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _recommendationAnimationController.dispose();
    _searchAnimationController.dispose(); // Dispose search animation controller
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    var filtered = widget.products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product["title"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product["description"].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _filterCategory == 'All' ||
          product["category"] == _filterCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => double.parse(a["price"]).compareTo(double.parse(b["price"])));
        break;
      case 'price_high':
        filtered.sort((a, b) => double.parse(b["price"]).compareTo(double.parse(a["price"])));
        break;
      case 'rating':
        filtered.sort((a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0));
        break;
      case 'discount':
        filtered.sort((a, b) => (b["discount"] ?? 0).compareTo(a["discount"] ?? 0));
        break;
      case 'name':
        filtered.sort((a, b) => a["title"].compareTo(b["title"]));
        break;
      case 'featured':
      default:
        break;
    }
    
    return filtered;
  }

  List<String> get availableCategories {
    final categories = widget.products
        .map((product) => product["category"] as String)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final products = filteredProducts;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Light background
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildHeaderSection(),
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          SliverToBoxAdapter(
            child: _buildFilterSection(),
          ),
          SliverToBoxAdapter(
            child: _buildProductCount(products.length),
          ),
          products.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : _isGridView
                  ? _buildGridView(products)
                  : _buildListView(products),
          SliverToBoxAdapter(
            child: _buildRecommendationsSection(),
          ),
          SliverToBoxAdapter(
            child: _buildRecentlyViewedSection(),
          ),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            HapticFeedback.lightImpact(); // Added haptic feedback
            Navigator.pop(context);
          },
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
              color: Colors.black87,
            ),
            onPressed: () {
              HapticFeedback.lightImpact(); // Added haptic feedback
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE1F5FE), // Light blue
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container( // Enhanced icon container with gradient
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.amber.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Featured Products",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Discover our handpicked selection of top-rated baby products",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedBuilder( // Added animated search bar
        animation: _searchScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _searchScaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _searchFocusNode.hasFocus 
                        ? const Color(0xFF81C784).withOpacity(0.3) // Enhanced shadow when focused
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _searchFocusNode.hasFocus ? 15 : 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: _searchFocusNode.hasFocus // Added border when focused
                    ? Border.all(color: const Color(0xFF81C784), width: 2)
                    : null,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                
                decoration: InputDecoration(
                  hintText: "Search featured products...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search, 
                    color: _searchFocusNode.hasFocus 
                        ? const Color(0xFF81C784) 
                        : Colors.grey.shade400
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade400),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
                  Icon(Icons.sort, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Sort:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF81C784)), // Light green
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF81C784), // Light green
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'featured', child: Text('Featured')),
                          DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                          DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                          DropdownMenuItem(value: 'rating', child: Text('Rating')),
                          DropdownMenuItem(value: 'discount', child: Text('Discount')),
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                        ],
                        onChanged: (value) {
                          HapticFeedback.selectionClick(); // Added haptic feedback
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
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
                  Icon(Icons.category, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Category:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterCategory,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF81C784)), // Light green
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF81C784), // Light green
                          fontWeight: FontWeight.w600,
                        ),
                        items: availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          HapticFeedback.selectionClick(); // Added haptic feedback
                          setState(() {
                            _filterCategory = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$count ${count == 1 ? 'product' : 'products'} found",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_filterCategory != 'All' || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _filterCategory = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: Text(
                "Clear Filters",
                style: TextStyle(
                  color: const Color(0xFF81C784), // Light green
                  fontWeight: FontWeight.w600,
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
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters to find what you're looking for.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
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
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Added haptic feedback
        Navigator.push(
          context,
          PageRouteBuilder( // Enhanced page transition
            pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
              title: product["title"],
              image: product["image"],
              description: product["description"],
              price: double.parse(product["price"]),
              originalPrice: product["originalPrice"] != null 
                  ? double.parse(product["originalPrice"]) 
                  : null,
              rating: product["rating"]?.toDouble(),
              reviewCount: product["reviewCount"],
              additionalImages: [product["image"]],
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
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
        child: isGrid ? _buildGridCard(product, hasDiscount) : _buildListCard(product, hasDiscount),
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> product, bool hasDiscount) {
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
                  color: Colors.grey.shade100,
                  child: Image.asset(
                    product["image"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
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
                      color: Colors.red,
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
              if (product["badge"] != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784), // Light green
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
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${product["rating"]}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (product["reviewCount"] != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          "(${product["reviewCount"]})",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
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
                            color: const Color(0xFF81C784), // Light green
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasDiscount && product["originalPrice"] != null)
                          Text(
                            "\$${product["originalPrice"]}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784), // Light green
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
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

  Widget _buildListCard(Map<String, dynamic> product, bool hasDiscount) {
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
                    color: Colors.grey.shade100,
                    child: Image.asset(
                      product["image"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey.shade400,
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
                        color: Colors.red,
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
                if (product["badge"] != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784), // Light green
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
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey.shade400,
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
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${product["rating"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (product["reviewCount"] != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            "(${product["reviewCount"]} reviews)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
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
                              color: const Color(0xFF81C784), // Light green
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (hasDiscount && product["originalPrice"] != null)
                            Text(
                              "\$${product["originalPrice"]}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text("Add", style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81C784), // Light green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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

  Widget _buildRecommendationsSection() {
    return FadeTransition(
      opacity: _recommendationFadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container( // Enhanced recommendation icon with gradient
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF81C784),
                        const Color(0xFF66BB6A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF81C784).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.recommend,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "You might also like",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Handpicked recommendations based on your interests",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedProducts.length,
                itemBuilder: (context, index) {
                  final product = _recommendedProducts[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact(); // Added haptic feedback
                        Navigator.push(
                          context,
                          PageRouteBuilder( // Enhanced page transition
                            pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
                              title: product["title"],
                              image: product["image"],
                              description: product["description"],
                              price: double.parse(product["price"]),
                              rating: product["rating"]?.toDouble(),
                              reviewCount: product["reviewCount"],
                              additionalImages: product["additionalImages"] ?? [product["image"]],
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
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
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: Image.asset(
                                    product["image"],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
                                        fontSize: 12,
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
                                            color: Colors.amber.shade600,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            "${product["rating"]}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${product["price"]}",
                                          style: TextStyle(
                                            color: const Color(0xFF81C784), // Light green
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF81C784), // Light green
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 12,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: const Color(0xFF64B5F6), // Light blue
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "Recently Viewed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Continue where you left off",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentlyViewed.length,
              itemBuilder: (context, index) {
                final product = _recentlyViewed[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact(); // Added haptic feedback
                      print("Tapping recently viewed: ${product["title"]}"); // Debug print
                      Navigator.push(
                        context,
                        PageRouteBuilder( // Enhanced page transition
                          pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
                            title: product["title"],
                            image: product["image"],
                            description: product["description"],
                            price: double.parse(product["price"]),
                            rating: product["rating"]?.toDouble(),
                            reviewCount: product["reviewCount"],
                            additionalImages: product["additionalImages"] ?? [product["image"]],
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                product["image"],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 24,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${product["price"]}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF81C784), // Light green
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
