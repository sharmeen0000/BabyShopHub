import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> categories;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.allProducts,
    required this.categories,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _sortBy = 'relevance';
  String _filterCategory = 'All';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    
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
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    var filtered = widget.allProducts.where((product) {
      final matchesSearch = widget.searchQuery.isEmpty ||
          product["title"].toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          product["description"].toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          product["category"].toLowerCase().contains(widget.searchQuery.toLowerCase());
      
      final matchesCategory = _filterCategory == 'All' ||
          product["category"] == _filterCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    // Sort products
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
      case 'relevance':
      default:
        // Keep original order for relevance
        break;
    }
    
    return filtered;
  }

  List<String> get availableCategories {
    final categories = widget.allProducts
        .map((product) => product["category"] as String)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  void _performNewSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query != widget.searchQuery) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            searchQuery: query,
            allProducts: widget.allProducts,
            categories: widget.categories,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = filteredProducts;
    
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildHeaderSection(products.length),
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          SliverToBoxAdapter(
            child: _buildFilterSection(),
          ),
          products.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : _isGridView
                  ? _buildGridView(products)
                  : _buildListView(products),
          if (products.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSuggestionsSection(),
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

  Widget _buildHeaderSection(int resultCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE4E1),
            Color(0xFFF0E6FF),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: Color(0xFFFF69B4),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                "Search Results",
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
            "Found $resultCount ${resultCount == 1 ? 'result' : 'results'} for \"${widget.searchQuery}\"",
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _performNewSearch(),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Search for products...",
          hintStyle: TextStyle(color: Color(0xFF8B7355).withOpacity(0.5)),
          prefixIcon: GestureDetector(
            onTap: _performNewSearch,
            child: Icon(Icons.search, color: Color(0xFFFF69B4)),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFF8B7355).withOpacity(0.5)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
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
                  Icon(Icons.sort, color: Color(0xFF8B7355), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Sort:",
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
                          DropdownMenuItem(value: 'relevance', child: Text('Relevance')),
                          DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                          DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                          DropdownMenuItem(value: 'rating', child: Text('Rating')),
                          DropdownMenuItem(value: 'discount', child: Text('Discount')),
                          DropdownMenuItem(value: 'name', child: Text('Name')),
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
                  Icon(Icons.category, color: Color(0xFF8B7355), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Filter:",
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
                        value: _filterCategory,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF69B4)),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFF69B4),
                          fontWeight: FontWeight.w600,
                        ),
                        items: availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Color(0xFFDDA0DD),
          ),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords or check your spelling.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF69B4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
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
              if (product["badge"] != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0xFF98FB98),
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
                      if (product["reviewCount"] != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          "(${product["reviewCount"]})",
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF8B7355).withOpacity(0.7),
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
                            color: Color(0xFFFF69B4),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasDiscount && product["originalPrice"] != null)
                          Text(
                            "\$${product["originalPrice"]}",
                            style: TextStyle(
                              color: Color(0xFF8B7355).withOpacity(0.5),
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
                  Text(
                    product["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                        if (product["reviewCount"] != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            "(${product["reviewCount"]} reviews)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B7355).withOpacity(0.7),
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
                              color: Color(0xFFFF69B4),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (hasDiscount && product["originalPrice"] != null)
                            Text(
                              "\$${product["originalPrice"]}",
                              style: TextStyle(
                                color: Color(0xFF8B7355).withOpacity(0.5),
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
                          backgroundColor: Color(0xFFFF69B4),
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

  Widget _buildSuggestionsSection() {
    final suggestions = widget.categories.take(4).toList();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Try searching for:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((category) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultsScreen(
                        searchQuery: category["title"],
                        allProducts: widget.allProducts,
                        categories: widget.categories,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB6C1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFFFFB6C1)),
                  ),
                  child: Text(
                    category["title"],
                    style: TextStyle(
                      color: Color(0xFFFF69B4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
