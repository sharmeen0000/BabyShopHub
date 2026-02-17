import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late AnimationController _emptyStateAnimationController;
  late AnimationController _headerAnimationController; // Added header animation controller
  late Animation<double> _emptyStateAnimation;
  late Animation<double> _headerPulseAnimation; // Added header pulse animation
  
  bool _isGridView = false;
  String _sortBy = 'name'; // 'name', 'date_added'

  @override
  void initState() {
    super.initState();
    
    _emptyStateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _emptyStateAnimation = CurvedAnimation(
      parent: _emptyStateAnimationController,
      curve: Curves.easeInOut,
    );

    _headerPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _emptyStateAnimationController.forward();
    _headerAnimationController.repeat(reverse: true); // Start header pulse animation
  }

  @override
  void dispose() {
    _emptyStateAnimationController.dispose();
    _headerAnimationController.dispose(); // Dispose header animation controller
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    HapticFeedback.lightImpact();
  }

  void _showSortOptions() {
    HapticFeedback.mediumImpact(); // Added haptic feedback
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Sort by",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.sort_by_alpha,
                color: _sortBy == 'name' ? const Color(0xFF81C784) : Colors.grey, // Light green
              ),
              title: const Text("Name"),
              trailing: _sortBy == 'name' 
                  ? Icon(Icons.check, color: const Color(0xFF81C784)) // Light green
                  : null,
              onTap: () {
                HapticFeedback.selectionClick(); // Added haptic feedback
                setState(() {
                  _sortBy = 'name';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: _sortBy == 'date_added' ? const Color(0xFF81C784) : Colors.grey, // Light green
              ),
              title: const Text("Date Added"),
              trailing: _sortBy == 'date_added' 
                  ? Icon(Icons.check, color: const Color(0xFF81C784)) // Light green
                  : null,
              onTap: () {
                HapticFeedback.selectionClick(); // Added haptic feedback
                setState(() {
                  _sortBy = 'date_added';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favorites = _getSortedFavorites(favoritesProvider.favorites);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Light background
      appBar: _buildAppBar(favorites.length),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : _isGridView
              ? _buildGridView(favorites, favoritesProvider)
              : _buildListView(favorites, favoritesProvider),
    );
  }

  PreferredSizeWidget _buildAppBar(int itemCount) {
    return AppBar(
      title: AnimatedBuilder( // Added animated title
        animation: _headerPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _headerPulseAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( // Added heart icon to title
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "My Favorites",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (itemCount > 0)
                  Text(
                    "$itemCount ${itemCount == 1 ? 'item' : 'items'}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (itemCount > 0) ...[
          Container( // Enhanced action buttons with containers
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.black87,
              ),
              onPressed: _toggleView,
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),
          ),
          Container( // Enhanced sort button
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.sort, color: Colors.black87),
              onPressed: _showSortOptions,
              tooltip: 'Sort',
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _emptyStateAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _emptyStateAnimation,
              child: Container(
                padding: const EdgeInsets.all(32), // Increased padding
                decoration: BoxDecoration(
                  gradient: LinearGradient( // Added gradient background
                    colors: [
                      const Color(0xFFE1F5FE),
                      const Color(0xFFE8F5E8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [ // Added shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_outline,
                  size: 80,
                  color: const Color(0xFF64B5F6), // Light blue
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No favorites yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start adding products to your favorites\nto see them here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact(); // Added haptic feedback
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Start Shopping"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81C784), // Light green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4, // Added elevation
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<FavoriteItem> favorites, FavoritesProvider provider) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: favorites.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        if (index >= favorites.length) return const SizedBox.shrink();
        
        final item = favorites[index];
        return _buildAnimatedListItem(item, index, animation, provider, false);
      },
    );
  }

  Widget _buildGridView(List<FavoriteItem> favorites, FavoritesProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return _buildGridItem(item, index, provider);
      },
    );
  }

  Widget _buildAnimatedListItem(
    FavoriteItem item,
    int index,
    Animation<double> animation,
    FavoritesProvider provider,
    bool isGrid,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: isGrid
            ? _buildGridItem(item, index, provider)
            : _buildListItem(item, index, provider),
      ),
    );
  }

  Widget _buildListItem(FavoriteItem item, int index, FavoritesProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Added haptic feedback
          _navigateToProductDetail(item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "4.5",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container( // Enhanced "Added recently" badge
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Added recently",
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF81C784),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container( // Enhanced favorite button
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => _removeFavorite(item, index, provider),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container( // Enhanced cart button
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        color: const Color(0xFF81C784), // Light green
                      ),
                      onPressed: () => _addToCart(item),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(FavoriteItem item, int index, FavoritesProvider provider) {
    return Container(
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
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Added haptic feedback
          _navigateToProductDetail(item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _removeFavorite(item, index, provider),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              "4.5",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient( // Added gradient to cart button
                              colors: [
                                const Color(0xFF81C784),
                                const Color(0xFF66BB6A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () => _addToCart(item),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
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
  }

  void _removeFavorite(FavoriteItem item, int index, FavoritesProvider provider) {
    HapticFeedback.lightImpact();
    
    provider.toggleFavorite(item);
    
    if (_listKey.currentState != null && !_isGridView) {
      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildAnimatedListItem(
          item,
          index,
          animation,
          provider,
          false,
        ),
        duration: const Duration(milliseconds: 300),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text("${item.title} removed from favorites"),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () {
            provider.toggleFavorite(item);
          },
        ),
      ),
    );
  }

  void _addToCart(FavoriteItem item) {
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text("${item.title} added to cart"),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF81C784), // Light green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _navigateToProductDetail(FavoriteItem item) {
    Navigator.push(
      context,
      PageRouteBuilder( // Enhanced page transition
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
          title: item.title,
          image: item.image,
          description: "A wonderful product for your baby",
          price: 25.99,
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
  }

  List<FavoriteItem> _getSortedFavorites(List<FavoriteItem> favorites) {
    final sortedList = List<FavoriteItem>.from(favorites);
    
    switch (_sortBy) {
      case 'name':
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'date_added':
        // Assuming you have a dateAdded field in FavoriteItem
        // sortedList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }
    
    return sortedList;
  }
}

