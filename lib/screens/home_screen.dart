import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/favorites_screen.dart';
import 'package:flutter_application_1/screens/support_screen.dart';
import 'product_detail_screen.dart';
import 'main_navigation_screen.dart';
import 'CategoryProductsScreen.dart';
import 'all_categories_screen.dart';
import 'all_featured_products_screen.dart';
import 'search_results_screen.dart';
import 'special_offers_screen.dart';
import 'deals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Expanded categories list with all 15 main categories
  final List<Map<String, dynamic>> categories = [
    {
      "title": "Diapers",
      "image": "assets/images/diapers.png",
      "color": const Color(0xFFE3F2FD), // Light blue
      "icon": Icons.baby_changing_station,
      "description": "Diapers, wipes & changing essentials"
    },
    {
      "title": "Baby Food",
      "image": "assets/images/food.webp",
      "color": const Color(0xFFE8F5E8), // Light green
      "icon": Icons.restaurant_menu,
      "description": "Feeding bottles, food & utensils"
    },
    {
      "title": "Clothing",
      "image": "assets/images/clothes.png",
      "color": const Color(0xFFF3E5F5), // Light purple
      "icon": Icons.checkroom,
      "description": "Onesies, blankets & baby wear"
    },
    {
      "title": "Toys",
      "image": "assets/images/toys.png",
      "color": const Color(0xFFFFF3E0), // Light orange
      "icon": Icons.toys,
      "description": "Educational & fun toys"
    },
    {
      "title": "Baby Care",
      "image": "assets/images/care.jpg",
      "color": const Color(0xFFE0F2F1), // Light teal
      "icon": Icons.health_and_safety,
      "description": "Health & grooming products"
    },
    {
      "title": "Safety",
      "image": "assets/images/safety.jpg",
      "color": const Color(0xFFFFEBEE), // Light red
      "icon": Icons.security,
      "description": "Baby proofing & safety gear"
    },
    {
      "title": "Strollers",
      "image": "assets/images/stroller.jpg",
      "color": const Color(0xFFE8EAF6), // Light indigo
      "icon": Icons.directions_walk,
      "description": "Strollers, car seats & carriers"
    },
    {
      "title": "Nursery",
      "image": "assets/images/nursery.jpg",
      "color": const Color(0xFFFCE4EC), // Light pink
      "icon": Icons.bed,
      "description": "Cribs, furniture & decor"
    },
    {
      "title": "Bath",
      "image": "assets/images/bath1.jpg",
      "color": const Color(0xFFE0F7FA), // Light cyan
      "icon": Icons.bathtub,
      "description": "Bath time essentials"
    },
    {
      "title": "Books",
      "image": "assets/images/books.jpg",
      "color": const Color(0xFFFFF8E1), // Light amber
      "icon": Icons.menu_book,
      "description": "Educational books & learning"
    },
  ];

  final List<Map<String, dynamic>> featuredProducts = [
    {
      "title": "Soft Baby Blanket",
      "image": "assets/images/blankets.webp",
      "description": "A warm and soft blanket made from organic cotton.",
      "price": "25.0",
      "originalPrice": "30.0",
      "rating": 4.8,
      "reviewCount": 124,
      "discount": 17,
      "category": "Clothing",
      "badge": "Bestseller"
    },
    {
      "title": "Organic Baby Lotion",
      "image": "assets/images/lotion.webp",
      "description": "Gentle, moisturizing lotion safe for newborns.",
      "price": "12.5",
      "rating": 4.6,
      "reviewCount": 89,
      "discount": 0,
      "category": "Baby Care",
      "badge": "Organic"
    },
    {
      "title": "Colorful Rattle",
      "image": "assets/images/rattle.jpg",
      "description": "A lightweight and fun toy to develop motor skills.",
      "price": "8.0",
      "originalPrice": "10.0",
      "rating": 4.9,
      "reviewCount": 156,
      "discount": 20,
      "category": "Toys",
      "badge": "Top Rated"
    },
    {
      "title": "Premium Baby Bottle Set",
      "image": "assets/images/bottle1.jpg",
      "description": "Anti-colic baby bottles with natural flow nipples.",
      "price": "22.0",
      "originalPrice": "28.0",
      "rating": 4.5,
      "reviewCount": 78,
      "discount": 21,
      "category": "Baby Food",
      "badge": "Premium"
    },
    {
      "title": "Convertible Car Seat",
      "image": "assets/images/convert.webp",
      "description": "All-in-one car seat that grows with your child.",
      "price": "180.0",
      "rating": 4.8,
      "reviewCount": 156,
      "discount": 0,
      "category": "Strollers",
      "badge": "Safety Certified"
    },
    {
      "title": "Baby Activity Gym",
      "image": "assets/images/activity.webp",
      "description": "Colorful play gym with hanging toys to stimulate senses.",
      "price": "45.0",
      "originalPrice": "60.0",
      "rating": 4.6,
      "reviewCount": 87,
      "discount": 25,
      "category": "Toys",
      "badge": "Educational"
    },
    {
      "title": "Huggies Diapers - Pack of 50",
      "image": "assets/images/diapers.png",
      "description": "Super absorbent diapers with 12-hour protection.",
      "price": "18.0",
      "rating": 4.7,
      "reviewCount": 203,
      "discount": 0,
      "category": "Diapers",
      "badge": "Most Popular"
    },
    {
      "title": "Baby Thermometer",
      "image": "assets/images/thermometer.jpg",
      "description": "Digital thermometer with quick and accurate readings.",
      "price": "15.0",
      "rating": 4.5,
      "reviewCount": 123,
      "discount": 0,
      "category": "Baby Care",
      "badge": "Essential"
    },
    {
      "title": "Lightweight Stroller",
      "image": "assets/images/stroller.jpg",
      "description": "Compact and lightweight stroller perfect for everyday use.",
      "price": "120.0",
      "originalPrice": "150.0",
      "rating": 4.5,
      "reviewCount": 89,
      "discount": 20,
      "category": "Strollers",
      "badge": "Compact"
    },
    {
      "title": "Baby Crib",
      "image": "assets/images/crib.jpg",
      "description": "Convertible crib that transforms into a toddler bed.",
      "price": "220.0",
      "originalPrice": "280.0",
      "rating": 4.6,
      "reviewCount": 78,
      "discount": 21,
      "category": "Nursery",
      "badge": "Convertible"
    },
    {
      "title": "Baby Bathtub",
      "image": "assets/images/bathtub.jpg",
      "description": "Ergonomic baby bathtub with non-slip surface.",
      "price": "28.0",
      "rating": 4.6,
      "reviewCount": 123,
      "discount": 0,
      "category": "Bath",
      "badge": "Safe"
    },
    {
      "title": "Baby's First Books Set",
      "image": "assets/images/first.jpg",
      "description": "Set of 6 colorful board books perfect for development.",
      "price": "16.0",
      "rating": 4.7,
      "reviewCount": 198,
      "discount": 0,
      "category": "Books",
      "badge": "Educational"
    },
    {
      "title": "Nursing Pillow",
      "image": "assets/images/pillow.webp",
      "description": "Comfortable nursing pillow for feeding support.",
      "price": "35.0",
      "originalPrice": "45.0",
      "rating": 4.5,
      "reviewCount": 145,
      "discount": 22,
      "category": "Maternity",
      "badge": "Comfort"
    },
    {
      "title": "Video Baby Monitor",
      "image": "assets/images/moniter.jpg",
      "description": "HD video baby monitor with night vision.",
      "price": "85.0",
      "originalPrice": "110.0",
      "rating": 4.6,
      "reviewCount": 134,
      "discount": 23,
      "category": "Monitors",
      "badge": "HD Quality"
    },
    {
      "title": "Travel Crib",
      "image": "assets/images/babytravel.jpg",
      "description": "Portable travel crib that folds compactly.",
      "price": "75.0",
      "originalPrice": "95.0",
      "rating": 4.5,
      "reviewCount": 123,
      "discount": 21,
      "category": "Travel",
      "badge": "Portable"
    },
    {
      "title": "Baby Memory Book",
      "image": "assets/images/memory.jpg",
      "description": "Beautiful memory book to record baby's milestones.",
      "price": "22.0",
      "rating": 4.8,
      "reviewCount": 156,
      "discount": 0,
      "category": "Gifts",
      "badge": "Keepsake"
    },
    {
      "title": "Baby Safety Gate",
      "image": "assets/images/gate.webp",
      "description": "Adjustable safety gate for doorways and stairs.",
      "price": "45.0",
      "rating": 4.6,
      "reviewCount": 98,
      "discount": 0,
      "category": "Safety",
      "badge": "Safety First"
    },
    {
      "title": "Musical Mobile",
      "image": "assets/images/mobile.webp",
      "description": "Soothing musical mobile with rotating animals.",
      "price": "38.0",
      "originalPrice": "48.0",
      "rating": 4.7,
      "reviewCount": 156,
      "discount": 21,
      "category": "Toys",
      "badge": "Soothing"
    },
    {
      "title": "Baby Food Maker",
      "image": "assets/images/foodmaker.jpg",
      "description": "Steam and blend fresh baby food easily.",
      "price": "65.0",
      "rating": 4.7,
      "reviewCount": 98,
      "discount": 0,
      "category": "Baby Food",
      "badge": "Fresh Food"
    },
  ];

  final List<String> bannerImages = [
    "assets/images/baby3.jpg",
    "assets/images/banner1.jpg",
    "assets/images/banner3.jpeg",
  ];

  late final AnimationController _productAnimationController;
  late final AnimationController _categoryAnimationController;
  late final AnimationController _bannerAnimationController;
  
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _productAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _categoryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _bannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _productAnimationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _categoryAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _categoryAnimationController.forward();
    _productAnimationController.forward();
    _bannerAnimationController.forward();

    // Auto-scroll banner
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
        });
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            searchQuery: query,
            allProducts: featuredProducts,
            categories: categories,
          ),
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Products",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.take(8).map((category) {
                      return FilterChip(
                        label: Text(category["title"]),
                        onSelected: (selected) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsScreen(
                                categoryTitle: category["title"],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Price Range",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text("Under \$20"),
                        onSelected: (selected) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultsScreen(
                                searchQuery: "Under \$20",
                                allProducts: featuredProducts.where((p) => double.parse(p["price"]) < 20).toList(),
                                categories: categories,
                              ),
                            ),
                          );
                        },
                      ),
                      FilterChip(
                        label: const Text("\$20 - \$50"),
                        onSelected: (selected) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultsScreen(
                                searchQuery: "\$20 - \$50",
                                allProducts: featuredProducts.where((p) {
                                  final price = double.parse(p["price"]);
                                  return price >= 20 && price <= 50;
                                }).toList(),
                                categories: categories,
                              ),
                            ),
                          );
                        },
                      ),
                      FilterChip(
                        label: const Text("Over \$50"),
                        onSelected: (selected) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultsScreen(
                                searchQuery: "Over \$50",
                                allProducts: featuredProducts.where((p) => double.parse(p["price"]) > 50).toList(),
                                categories: categories,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productAnimationController.dispose();
    _categoryAnimationController.dispose();
    _bannerAnimationController.dispose();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Light background
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _productAnimationController.reset();
          _categoryAnimationController.reset();
          _productAnimationController.forward();
          _categoryAnimationController.forward();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              _buildPromoBanner(),
              _buildSearchBar(),
              _buildCategoriesSection(),
              _buildFeaturedProductsSection(),
              _buildSpecialOffersSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              // color: const Color(0xFFE1F5FE), // Light blue
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/logo2.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.baby_changing_station,
                  color: const Color(0xFF81C784), // Light green
                  size: 24,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "BabyShopHub",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_outline, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FavoritesScreen()),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.support_agent, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SupportScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hello, Parent! 👋",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Find everything your baby needs",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: bannerImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF81C784), // Light green
                  const Color(0xFF64B5F6), // Light blue
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Banner image background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Dark overlay for better text visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16), // Reduced from 20
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Special Offer!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22, // Reduced from 24
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced from 8
                      Flexible(
                        child: Text(
                          "Up to 50% off on\nselected baby items",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Reduced from 16
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12), // Reduced from 16
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpecialOffersScreen(
                                allProducts: featuredProducts,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF81C784), // Light green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(100, 32), // Smaller button
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          "Shop Now",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _performSearch(),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Search for baby products...",
          prefixIcon: GestureDetector(
            onTap: _performSearch,
            child: Icon(Icons.search, color: Colors.grey.shade400),
          ),
          suffixIcon: GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Icon(Icons.filter_list, color: Colors.grey.shade400),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllCategoriesScreen(categories: categories),
                    ),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: const Color(0xFF81C784), // Light green
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length > 8 ? 8 : categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return AnimatedBuilder(
                    animation: _categoryAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _categoryAnimationController.value,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryProductsScreen(
                                  categoryTitle: category["title"],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: category["color"],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: category["image"] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.asset(
                                            category["image"],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  category["icon"],
                                                  size: 32,
                                                  color: Colors.grey.shade700,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          category["icon"],
                                          size: 32,
                                          color: Colors.grey.shade700,
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category["title"],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Featured Products",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllFeaturedProductsScreen(products: featuredProducts),
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: const Color(0xFF81C784), // Light green
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length > 6 ? 6 : featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                title: product["title"],
                                image: product['image'],
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
                          width: 180,
                          margin: const EdgeInsets.only(right: 16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Container(
                                      height: 140,
                                      width: double.infinity,
                                      color: Colors.grey.shade100,
                                      child: product["image"] != null
                                          ? Image.asset(
                                              product["image"],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                );
                                              },
                                            )
                                          : Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.grey.shade400,
                                            ),
                                    ),
                                  ),
                                  if (product["discount"] != null && product["discount"] > 0)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
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
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["title"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
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
                                              "(${product["reviewCount"]})",
                                              style: TextStyle(
                                                fontSize: 10,
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF81C784), // Light green
                                                ),
                                              ),
                                              if (product["originalPrice"] != null)
                                                Text(
                                                  "\$${product["originalPrice"]}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
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
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF3E0), // Light orange
            const Color(0xFFE1F5FE), // Light blue
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Special Deals",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Get up to 30% off on baby essentials",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DealsScreen(
                          allProducts: featuredProducts,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784), // Light green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Explore Deals"),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.local_offer,
              size: 40,
              color: const Color(0xFF81C784), // Light green
            ),
          ),
        ],
      ),
    );
  }
}