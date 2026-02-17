import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'product_detail_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryTitle;
  
  const CategoryProductsScreen({
    super.key, 
    required this.categoryTitle
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _headerAnimationController; // Added header animation controller
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerScaleAnimation; // Added header scale animation
  
  String _sortBy = 'name';
  bool _isGridView = true;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _headerScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _headerAnimationController.forward(); // Start header animation
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose(); // Dispose header animation controller
    super.dispose();
  }

  // Sample products data - in a real app, this would come from a database or API
  final List<Map<String, dynamic>> allProducts = [
    // ==================== CLOTHING CATEGORY ====================
    {
      "title": "Soft Baby Blanket",
      "image": "assets/images/blankets.webp",
      "description": "A warm and soft blanket made from organic cotton, perfect for keeping your baby cozy and comfortable.",
      "price": 25.0,
      "originalPrice": 30.0,
      "category": "Clothing",
      "subcategory": "Blankets & Swaddles",
      "rating": 4.8,
      "reviewCount": 124,
      "discount": 17,
      "inStock": true,
      "features": ["Organic Cotton", "Machine Washable", "Hypoallergenic"]
    },
    {
      "title": "Cotton Baby Onesie",
      "image": "assets/images/cottonbabyonesie.jpg",
      "description": "Soft cotton onesie with snap closures for easy diaper changes.",
      "price": 15.0,
      "category": "Clothing",
      "subcategory": "Bodysuits & Onesies",
      "rating": 4.4,
      "reviewCount": 92,
      "discount": 0,
      "inStock": true,
      "features": ["100% Cotton", "Snap Closures", "Machine Washable"]
    },
    {
      "title": "Baby Sleep Sack",
      "image": "assets/images/sleepsack.jpg",
      "description": "Wearable blanket that keeps baby warm and safe during sleep.",
      "price": 32.0,
      "originalPrice": 40.0,
      "category": "Clothing",
      "subcategory": "Sleepwear",
      "rating": 4.9,
      "reviewCount": 156,
      "discount": 20,
      "inStock": true,
      "features": ["TOG Rated", "Zip Closure", "Breathable Fabric"]
    },
    {
      "title": "Newborn Hat Set",
      "image": "assets/images/hatset.jpg",
      "description": "Set of 3 soft cotton hats to keep baby's head warm.",
      "price": 18.0,
      "category": "Clothing",
      "subcategory": "Hats & Accessories",
      "rating": 4.6,
      "reviewCount": 78,
      "discount": 0,
      "inStock": true,
      "features": ["3-Pack", "Soft Cotton", "Stretchy Fit"]
    },
    {
      "title": "Baby Mittens & Booties Set",
      "image": "assets/images/mittenandbottles.jpg",
      "description": "Adorable mittens and booties set to keep tiny hands and feet warm.",
      "price": 12.0,
      "originalPrice": 16.0,
      "category": "Clothing",
      "subcategory": "Hats & Accessories",
      "rating": 4.5,
      "reviewCount": 89,
      "discount": 25,
      "inStock": true,
      "features": ["Soft Knit", "Stay-On Design", "Machine Washable"]
    },
    {
      "title": "Organic Cotton Romper",
      "image": "assets/images/cottonramper.webp",
      "description": "Comfortable one-piece romper made from organic cotton.",
      "price": 28.0,
      "category": "Clothing",
      "subcategory": "Rompers & Playsuits",
      "rating": 4.7,
      "reviewCount": 134,
      "discount": 0,
      "inStock": false,
      "features": ["Organic Cotton", "Snap Crotch", "Cute Prints"]
    },
    {
      "title": "Baby Pajama Set",
      "image": "assets/images/pajamaset.webp",
      "description": "Cozy two-piece pajama set for comfortable sleep.",
      "price": 22.0,
      "category": "Clothing",
      "subcategory": "Sleepwear",
      "rating": 4.6,
      "reviewCount": 98,
      "discount": 0,
      "inStock": true,
      "features": ["Two-Piece Set", "Soft Fabric", "Non-Slip Feet"]
    },
    {
      "title": "Baby Dress with Bloomers",
      "image": "assets/images/dressbloomer.webp",
      "description": "Adorable dress with matching bloomers for special occasions.",
      "price": 35.0,
      "originalPrice": 45.0,
      "category": "Clothing",
      "subcategory": "Dresses & Outfits",
      "rating": 4.8,
      "reviewCount": 67,
      "discount": 22,
      "inStock": true,
      "features": ["Matching Bloomers", "Special Occasion", "Soft Cotton"]
    },

    // ==================== BABY FOOD & FEEDING CATEGORY ====================
    {
      "title": "Organic Baby Lotion",
      "image": "assets/images/lotion.webp",
      "description": "Gentle, moisturizing lotion made with natural ingredients, safe for newborns and sensitive skin.",
      "price": 12.5,
      "category": "Baby Food",
      "subcategory": "Baby Care Products",
      "rating": 4.6,
      "reviewCount": 89,
      "discount": 0,
      "inStock": true,
      "features": ["Natural Ingredients", "Dermatologist Tested", "Fragrance Free"]
    },
    {
      "title": "Baby Bottle Set",
      "image": "assets/images/bottle.jpg",
      "description": "Anti-colic baby bottles with natural flow nipples, perfect for feeding time.",
      "price": 22.0,
      "originalPrice": 28.0,
      "category": "Baby Food",
      "subcategory": "Bottles & Nipples",
      "rating": 4.5,
      "reviewCount": 78,
      "discount": 21,
      "inStock": false,
      "features": ["Anti-Colic", "Natural Flow", "Easy Clean"]
    },
    {
      "title": "Silicone Baby Spoons",
      "image": "assets/images/babyspoon.webp",
      "description": "Soft silicone spoons perfect for baby's first foods.",
      "price": 8.0,
      "category": "Baby Food",
      "subcategory": "Feeding Utensils",
      "rating": 4.8,
      "reviewCount": 145,
      "discount": 0,
      "inStock": true,
      "features": ["BPA Free", "Soft Silicone", "Easy Grip Handle"]
    },
    {
      "title": "High Chair",
      "image": "assets/images/highchair.webp",
      "description": "Adjustable high chair with safety harness and removable tray.",
      "price": 85.0,
      "originalPrice": 110.0,
      "category": "Baby Food",
      "subcategory": "High Chairs & Boosters",
      "rating": 4.4,
      "reviewCount": 67,
      "discount": 23,
      "inStock": true,
      "features": ["Adjustable Height", "Safety Harness", "Easy Clean"]
    },
    {
      "title": "Baby Food Maker",
      "image": "assets/images/foodmaker.jpg",
      "description": "Steam and blend fresh baby food with this all-in-one food maker.",
      "price": 65.0,
      "category": "Baby Food",
      "subcategory": "Food Preparation",
      "rating": 4.7,
      "reviewCount": 98,
      "discount": 0,
      "inStock": true,
      "features": ["Steam & Blend", "BPA Free", "Easy Operation"]
    },
    {
      "title": "Sippy Cup Set",
      "image": "assets/images/sippycup.jpg",
      "description": "Spill-proof sippy cups with handles for easy gripping.",
      "price": 16.0,
      "originalPrice": 20.0,
      "category": "Baby Food",
      "subcategory": "Cups & Straws",
      "rating": 4.3,
      "reviewCount": 112,
      "discount": 20,
      "inStock": true,
      "features": ["Spill-Proof", "Easy Grip", "BPA Free"]
    },
    {
      "title": "Breast Pump",
      "image": "assets/images/breastpump.jpg",
      "description": "Electric breast pump with multiple settings for comfortable pumping.",
      "price": 120.0,
      "originalPrice": 150.0,
      "category": "Baby Food",
      "subcategory": "Breastfeeding",
      "rating": 4.6,
      "reviewCount": 89,
      "discount": 20,
      "inStock": true,
      "features": ["Electric", "Multiple Settings", "Portable"]
    },
    {
      "title": "Formula Dispenser",
      "image": "assets/images/dispenser.jpg",
      "description": "Convenient dispenser for storing and measuring baby formula.",
      "price": 18.0,
      "category": "Baby Food",
      "subcategory": "Formula Feeding",
      "rating": 4.4,
      "reviewCount": 156,
      "discount": 0,
      "inStock": true,
      "features": ["Easy Measuring", "Airtight Storage", "Portable"]
    },

    // ==================== TOYS CATEGORY ====================
    {
      "title": "Colorful Rattle",
      "image": "assets/images/rattle.jpg",
      "description": "A lightweight and fun toy designed to develop motor skills and provide entertainment for babies.",
      "price": 8.0,
      "originalPrice": 10.0,
      "category": "Toys",
      "subcategory": "Rattles & Shakers",
      "rating": 4.9,
      "reviewCount": 156,
      "discount": 20,
      "inStock": true,
      "features": ["BPA Free", "Easy Grip", "Colorful Design"]
    },
    {
      "title": "Soft Plush Teddy Bear",
      "image": "assets/images/teady.jpg",
      "description": "Cuddly teddy bear made from ultra-soft materials, perfect for snuggling.",
      "price": 24.0,
      "category": "Toys",
      "subcategory": "Stuffed Animals",
      "rating": 4.8,
      "reviewCount": 203,
      "discount": 0,
      "inStock": true,
      "features": ["Ultra Soft", "Machine Washable", "Safety Tested"]
    },
    {
      "title": "Baby Activity Gym",
      "image": "assets/images/activity.webp",
      "description": "Colorful play gym with hanging toys to stimulate baby's senses.",
      "price": 45.0,
      "originalPrice": 60.0,
      "category": "Toys",
      "subcategory": "Activity Gyms",
      "rating": 4.6,
      "reviewCount": 87,
      "discount": 25,
      "inStock": true,
      "features": ["Sensory Development", "Removable Toys", "Foldable"]
    },
    {
      "title": "Stacking Rings Toy",
      "image": "assets/images/ring.webp",
      "description": "Classic stacking toy that helps develop hand-eye coordination.",
      "price": 14.0,
      "category": "Toys",
      "subcategory": "Educational Toys",
      "rating": 4.5,
      "reviewCount": 134,
      "discount": 0,
      "inStock": true,
      "features": ["Educational", "Colorful", "Safe Materials"]
    },
    {
      "title": "Musical Mobile",
      "image": "assets/images/mobile.webp",
      "description": "Soothing musical mobile with rotating animals for crib entertainment.",
      "price": 38.0,
      "originalPrice": 48.0,
      "category": "Toys",
      "subcategory": "Mobiles & Crib Toys",
      "rating": 4.7,
      "reviewCount": 156,
      "discount": 21,
      "inStock": true,
      "features": ["Plays Lullabies", "Rotating Motion", "Easy Installation"]
    },
    {
      "title": "Teething Toys Set",
      "image": "assets/images/teeting.jpg",
      "description": "Set of safe teething toys to soothe baby's gums.",
      "price": 18.0,
      "category": "Toys",
      "subcategory": "Teething Toys",
      "rating": 4.4,
      "reviewCount": 98,
      "discount": 0,
      "inStock": true,
      "features": ["BPA Free", "Multiple Textures", "Easy to Clean"]
    },
    {
      "title": "Baby Piano Toy",
      "image": "assets/images/piano.webp",
      "description": "Musical piano toy with lights and sounds to encourage creativity.",
      "price": 32.0,
      "category": "Toys",
      "subcategory": "Musical Toys",
      "rating": 4.6,
      "reviewCount": 123,
      "discount": 0,
      "inStock": true,
      "features": ["Lights & Sounds", "Multiple Melodies", "Educational"]
    },
    {
      "title": "Push & Pull Toy",
      "image": "assets/images/pull.jpg",
      "description": "Wooden push and pull toy to encourage walking and movement.",
      "price": 26.0,
      "originalPrice": 32.0,
      "category": "Toys",
      "subcategory": "Push & Pull Toys",
      "rating": 4.5,
      "reviewCount": 87,
      "discount": 19,
      "inStock": true,
      "features": ["Wooden Construction", "Encourages Walking", "Durable"]
    },

    // ==================== DIAPERS CATEGORY ====================
    {
      "title": "Huggies Diapers - Pack of 50",
      "image": "assets/images/diapers.png",
      "description": "Super absorbent diapers with 12-hour protection for all-day dryness and comfort.",
      "price": 18.0,
      "category": "Diapers",
      "subcategory": "Disposable Diapers",
      "rating": 4.7,
      "reviewCount": 203,
      "discount": 0,
      "inStock": true,
      "features": ["12-Hour Protection", "Soft & Stretchy", "Wetness Indicator"]
    },
    {
      "title": "Pampers Baby Dry - Pack of 40",
      "image": "assets/images/babydry.jpg",
      "description": "Trusted protection with 3 Extra Absorb Channels for up to 12 hours.",
      "price": 16.0,
      "originalPrice": 20.0,
      "category": "Diapers",
      "subcategory": "Disposable Diapers",
      "rating": 4.6,
      "reviewCount": 178,
      "discount": 20,
      "inStock": true,
      "features": ["3 Extra Absorb Channels", "Soft Comfort", "Trusted Protection"]
    },
    {
      "title": "Eco-Friendly Bamboo Diapers",
      "image": "assets/images/ecofriendly.jpg",
      "description": "Sustainable bamboo diapers that are gentle on baby and the environment.",
      "price": 22.0,
      "category": "Diapers",
      "subcategory": "Eco-Friendly Diapers",
      "rating": 4.5,
      "reviewCount": 89,
      "discount": 0,
      "inStock": true,
      "features": ["Bamboo Fiber", "Eco-Friendly", "Hypoallergenic"]
    },
    {
      "title": "Overnight Diapers - Pack of 30",
      "image": "assets/images/overnight.webp",
      "description": "Extra absorbent diapers designed for overnight protection.",
      "price": 20.0,
      "originalPrice": 25.0,
      "category": "Diapers",
      "subcategory": "Overnight Diapers",
      "rating": 4.8,
      "reviewCount": 145,
      "discount": 20,
      "inStock": true,
      "features": ["Extra Absorbent", "Overnight Protection", "Comfortable Fit"]
    },
    {
      "title": "Diaper Rash Cream",
      "image": "assets/images/rashcream.webp",
      "description": "Gentle cream to prevent and treat diaper rash.",
      "price": 9.0,
      "category": "Diapers",
      "subcategory": "Diaper Care",
      "rating": 4.7,
      "reviewCount": 234,
      "discount": 0,
      "inStock": true,
      "features": ["Zinc Oxide", "Gentle Formula", "Pediatrician Recommended"]
    },
    {
      "title": "Baby Wipes - Pack of 80",
      "image": "assets/images/wipes.webp",
      "description": "Gentle, alcohol-free wipes for sensitive baby skin.",
      "price": 6.0,
      "originalPrice": 8.0,
      "category": "Diapers",
      "subcategory": "Baby Wipes",
      "rating": 4.6,
      "reviewCount": 167,
      "discount": 25,
      "inStock": true,
      "features": ["Alcohol-Free", "Gentle Formula", "Thick & Strong"]
    },
    {
      "title": "Cloth Diaper Set",
      "image": "assets/images/cloth.jpg",
      "description": "Reusable cloth diapers with adjustable snaps and inserts.",
      "price": 45.0,
      "originalPrice": 55.0,
      "category": "Diapers",
      "subcategory": "Cloth Diapers",
      "rating": 4.4,
      "reviewCount": 98,
      "discount": 18,
      "inStock": true,
      "features": ["Reusable", "Adjustable Snaps", "Includes Inserts"]
    },
    {
      "title": "Diaper Bag",
      "image": "assets/images/diaperbag.webp",
      "description": "Spacious diaper bag with multiple compartments and changing pad.",
      "price": 38.0,
      "category": "Diapers",
      "subcategory": "Diaper Bags",
      "rating": 4.5,
      "reviewCount": 134,
      "discount": 0,
      "inStock": true,
      "features": ["Multiple Compartments", "Changing Pad Included", "Stylish Design"]
    },

    // ==================== BABY CARE & HEALTH CATEGORY ====================
    {
      "title": "Baby Thermometer",
      "image": "assets/images/thermometer.jpg",
      "description": "Digital thermometer with quick and accurate readings for babies.",
      "price": 15.0,
      "category": "Baby Care",
      "subcategory": "Health Monitoring",
      "rating": 4.5,
      "reviewCount": 123,
      "discount": 0,
      "inStock": true,
      "features": ["Digital Display", "Quick Reading", "Fever Alert"]
    },
    {
      "title": "Baby Nail Clippers Set",
      "image": "assets/images/nallclipper.jpg",
      "description": "Safe nail clippers designed specifically for baby's tiny nails.",
      "price": 8.0,
      "category": "Baby Care",
      "subcategory": "Grooming Tools",
      "rating": 4.3,
      "reviewCount": 89,
      "discount": 0,
      "inStock": true,
      "features": ["Safety Design", "Rounded Tips", "Easy Grip"]
    },
    {
      "title": "Baby Shampoo & Body Wash",
      "image": "assets/images/shampoo.jpg",
      "description": "Gentle, tear-free formula for baby's delicate skin and hair.",
      "price": 11.0,
      "originalPrice": 14.0,
      "category": "Baby Care",
      "subcategory": "Bath Products",
      "rating": 4.7,
      "reviewCount": 198,
      "discount": 21,
      "inStock": true,
      "features": ["Tear-Free", "Gentle Formula", "Natural Ingredients"]
    },
    {
      "title": "Baby Humidifier",
      "image": "assets/images/humidifier.jpg",
      "description": "Cool mist humidifier to maintain optimal humidity for baby's room.",
      "price": 42.0,
      "category": "Baby Care",
      "subcategory": "Room Environment",
      "rating": 4.4,
      "reviewCount": 76,
      "discount": 0,
      "inStock": true,
      "features": ["Cool Mist", "Quiet Operation", "Auto Shut-off"]
    },
    {
      "title": "Baby Nasal Aspirator",
      "image": "assets/images/nasalaspirator.jpg",
      "description": "Gentle nasal aspirator to help clear baby's stuffy nose.",
      "price": 12.0,
      "category": "Baby Care",
      "subcategory": "Health Tools",
      "rating": 4.2,
      "reviewCount": 145,
      "discount": 0,
      "inStock": true,
      "features": ["Gentle Suction", "Easy to Clean", "Safe Design"]
    },
    {
      "title": "Baby Sunscreen SPF 50",
      "image": "assets/images/sunscreen.jpg",
      "description": "Mineral sunscreen specially formulated for baby's sensitive skin.",
      "price": 14.0,
      "originalPrice": 18.0,
      "category": "Baby Care",
      "subcategory": "Sun Protection",
      "rating": 4.6,
      "reviewCount": 167,
      "discount": 22,
      "inStock": true,
      "features": ["SPF 50", "Mineral Formula", "Water Resistant"]
    },

    // ==================== SAFETY & SECURITY CATEGORY ====================
    {
      "title": "Cabinet Safety Locks",
      "image": "assets/images/lock.jpg",
      "description": "Magnetic safety locks to keep cabinets secure from curious babies.",
      "price": 12.0,
      "category": "Safety",
      "subcategory": "Cabinet & Drawer Safety",
      "rating": 4.5,
      "reviewCount": 167,
      "discount": 0,
      "inStock": true,
      "features": ["Magnetic Lock", "Easy Installation", "Strong Hold"]
    },
    {
      "title": "Outlet Covers - Pack of 20",
      "image": "assets/images/outlet.jpg",
      "description": "Electrical outlet covers to protect babies from electrical hazards.",
      "price": 5.0,
      "category": "Safety",
      "subcategory": "Electrical Safety",
      "rating": 4.4,
      "reviewCount": 234,
      "discount": 0,
      "inStock": true,
      "features": ["Easy Installation", "Secure Fit", "Durable Plastic"]
    },
    {
      "title": "Corner Guards - Pack of 8",
      "image": "assets/images/corner.webp",
      "description": "Soft corner guards to protect babies from sharp furniture edges.",
      "price": 8.0,
      "originalPrice": 10.0,
      "category": "Safety",
      "subcategory": "Furniture Safety",
      "rating": 4.3,
      "reviewCount": 145,
      "discount": 20,
      "inStock": true,
      "features": ["Soft Cushioning", "Strong Adhesive", "Clear Design"]
    },
    {
      "title": "Baby Gate",
      "image": "assets/images/gate.webp",
      "description": "Adjustable safety gate for doorways and stairs.",
      "price": 45.0,
      "category": "Safety",
      "subcategory": "Gates & Barriers",
      "rating": 4.6,
      "reviewCount": 98,
      "discount": 0,
      "inStock": true,
      "features": ["Adjustable Width", "Easy Installation", "Auto-Close"]
    },
    {
      "title": "Window Safety Locks",
      "image": "assets/images/window.jpg",
      "description": "Secure window locks to prevent accidental opening.",
      "price": 15.0,
      "category": "Safety",
      "subcategory": "Window Safety",
      "rating": 4.4,
      "reviewCount": 89,
      "discount": 0,
      "inStock": true,
      "features": ["Secure Locking", "Easy Adult Use", "Durable"]
    },
    {
      "title": "Toilet Safety Lock",
      "image": "assets/images/toilet.jpeg",
      "description": "Child-proof toilet lock to keep curious toddlers safe.",
      "price": 9.0,
      "originalPrice": 12.0,
      "category": "Safety",
      "subcategory": "Bathroom Safety",
      "rating": 4.2,
      "reviewCount": 156,
      "discount": 25,
      "inStock": true,
      "features": ["Child-Proof", "Easy Installation", "Strong Adhesive"]
    },

    // ==================== STROLLERS & GEAR CATEGORY ====================
    {
      "title": "Lightweight Stroller",
      "image": "assets/images/lightweight.jpg",
      "description": "Compact and lightweight stroller perfect for everyday use.",
      "price": 120.0,
      "originalPrice": 150.0,
      "category": "Strollers",
      "subcategory": "Lightweight Strollers",
      "rating": 4.5,
      "reviewCount": 89,
      "discount": 20,
      "inStock": true,
      "features": ["Lightweight", "One-Hand Fold", "Large Canopy"]
    },
    {
      "title": "Convertible Car Seat",
      "image": "assets/images/convet1.webp",
      "description": "All-in-one car seat that grows with your child from infant to toddler.",
      "price": 180.0,
      "category": "Strollers",
      "subcategory": "Car Seats",
      "rating": 4.8,
      "reviewCount": 156,
      "discount": 0,
      "inStock": true,
      "features": ["Convertible", "Safety Tested", "Easy Installation"]
    },
    {
      "title": "Baby Carrier",
      "image": "assets/images/carrier.jpg",
      "description": "Ergonomic baby carrier for comfortable hands-free carrying.",
      "price": 65.0,
      "originalPrice": 80.0,
      "category": "Strollers",
      "subcategory": "Baby Carriers",
      "rating": 4.7,
      "reviewCount": 134,
      "discount": 19,
      "inStock": true,
      "features": ["Ergonomic Design", "Multiple Positions", "Breathable Fabric"]
    },
    {
      "title": "Jogging Stroller",
      "image": "assets/images/jogging.webp",
      "description": "All-terrain jogging stroller with air-filled tires.",
      "price": 220.0,
      "originalPrice": 280.0,
      "category": "Strollers",
      "subcategory": "Jogging Strollers",
      "rating": 4.6,
      "reviewCount": 67,
      "discount": 21,
      "inStock": true,
      "features": ["Air-Filled Tires", "All-Terrain", "Hand Brake"]
    },
    {
      "title": "Travel System",
      "image": "assets/images/travel.webp",
      "description": "Complete travel system with stroller and infant car seat.",
      "price": 280.0,
      "category": "Strollers",
      "subcategory": "Travel Systems",
      "rating": 4.7,
      "reviewCount": 98,
      "discount": 0,
      "inStock": false,
      "features": ["Stroller & Car Seat", "Click-Connect", "Safety Certified"]
    },
    {
      "title": "Umbrella Stroller",
      "image": "assets/images/umbralla.jpg",
      "description": "Ultra-lightweight umbrella stroller for quick trips.",
      "price": 45.0,
      "originalPrice": 60.0,
      "category": "Strollers",
      "subcategory": "Umbrella Strollers",
      "rating": 4.3,
      "reviewCount": 123,
      "discount": 25,
      "inStock": true,
      "features": ["Ultra-Light", "Compact Fold", "Cup Holder"]
    },

    // ==================== NURSERY & FURNITURE CATEGORY ====================
    {
      "title": "Baby Crib",
      "image": "assets/images/crib.jpg",
      "description": "Convertible crib that transforms into a toddler bed.",
      "price": 220.0,
      "originalPrice": 280.0,
      "category": "Nursery",
      "subcategory": "Cribs & Toddler Beds",
      "rating": 4.6,
      "reviewCount": 78,
      "discount": 21,
      "inStock": true,
      "features": ["Convertible", "Solid Wood", "Adjustable Mattress"]
    },
    {
      "title": "Changing Table",
      "image": "assets/images/changing.jpg",
      "description": "Sturdy changing table with safety rails and storage shelves.",
      "price": 95.0,
      "category": "Nursery",
      "subcategory": "Changing Tables",
      "rating": 4.4,
      "reviewCount": 67,
      "discount": 0,
      "inStock": true,
      "features": ["Safety Rails", "Storage Shelves", "Sturdy Construction"]
    },
    {
      "title": "Nursery Rocking Chair",
      "image": "assets/images/rocking.jpeg",
      "description": "Comfortable rocking chair perfect for feeding and soothing baby.",
      "price": 150.0,
      "originalPrice": 190.0,
      "category": "Nursery",
      "subcategory": "Nursery Seating",
      "rating": 4.7,
      "reviewCount": 89,
      "discount": 21,
      "inStock": false,
      "features": ["Comfortable Cushions", "Smooth Rocking", "Durable Frame"]
    },
    {
      "title": "Night Light",
      "image": "assets/images/night.jpg",
      "description": "Soft LED night light with multiple color options for nursery.",
      "price": 18.0,
      "category": "Nursery",
      "subcategory": "Lighting",
      "rating": 4.5,
      "reviewCount": 145,
      "discount": 0,
      "inStock": true,
      "features": ["LED Technology", "Multiple Colors", "Timer Function"]
    },
    {
      "title": "Baby Dresser",
      "image": "assets/images/dresser.jpg",
      "description": "6-drawer dresser with changing topper for nursery storage.",
      "price": 180.0,
      "category": "Nursery",
      "subcategory": "Storage & Organization",
      "rating": 4.5,
      "reviewCount": 134,
      "discount": 0,
      "inStock": true,
      "features": ["6 Drawers", "Changing Topper", "Safety Tested"]
    },
    {
      "title": "Crib Mattress",
      "image": "assets/images/mattress.jpg",
      "description": "Firm and breathable crib mattress for safe sleep.",
      "price": 85.0,
      "originalPrice": 110.0,
      "category": "Nursery",
      "subcategory": "Mattresses & Bedding",
      "rating": 4.6,
      "reviewCount": 167,
      "discount": 23,
      "inStock": true,
      "features": ["Firm Support", "Breathable", "Waterproof Cover"]
    },

    // ==================== BATH & GROOMING CATEGORY ====================
    {
      "title": "Baby Bathtub",
      "image": "assets/images/bathtub.jpg",
      "description": "Ergonomic baby bathtub with non-slip surface for safe bathing.",
      "price": 28.0,
      "category": "Bath",
      "subcategory": "Bathtubs & Bath Seats",
      "rating": 4.6,
      "reviewCount": 123,
      "discount": 0,
      "inStock": true,
      "features": ["Non-Slip Surface", "Ergonomic Design", "Drain Plug"]
    },
    {
      "title": "Hooded Baby Towels",
      "image": "assets/images/hodded.webp",
      "description": "Set of 2 soft hooded towels to keep baby warm after bath.",
      "price": 22.0,
      "originalPrice": 28.0,
      "category": "Bath",
      "subcategory": "Towels & Washcloths",
      "rating": 4.8,
      "reviewCount": 167,
      "discount": 21,
      "inStock": true,
      "features": ["Ultra Soft", "Hooded Design", "Quick Dry"]
    },
    {
      "title": "Baby Hair Brush Set",
      "image": "assets/images/brush.webp",
      "description": "Gentle brush and comb set for baby's delicate hair and scalp.",
      "price": 12.0,
      "category": "Bath",
      "subcategory": "Hair Care",
      "rating": 4.4,
      "reviewCount": 89,
      "discount": 0,
      "inStock": true,
      "features": ["Soft Bristles", "Gentle on Scalp", "Easy Grip"]
    },
    {
      "title": "Bath Toys Set",
      "image": "assets/images/bathtoys.jpg",
      "description": "Colorful floating bath toys to make bath time fun.",
      "price": 16.0,
      "category": "Bath",
      "subcategory": "Bath Toys",
      "rating": 4.5,
      "reviewCount": 198,
      "discount": 0,
      "inStock": true,
      "features": ["Floating Toys", "Colorful", "Safe Materials"]
    },
    {
      "title": "Baby Bath Thermometer",
      "image": "assets/images/bath.jpg",
      "description": "Digital thermometer to ensure perfect bath water temperature.",
      "price": 10.0,
      "originalPrice": 14.0,
      "category": "Bath",
      "subcategory": "Bath Accessories",
      "rating": 4.3,
      "reviewCount": 145,
      "discount": 29,
      "inStock": true,
      "features": ["Digital Display", "Waterproof", "Temperature Alert"]
    },
    {
      "title": "Baby Bubble Bath",
      "image": "assets/images/bubble.jpg",
      "description": "Gentle bubble bath formula for sensitive baby skin.",
      "price": 8.0,
      "category": "Bath",
      "subcategory": "Bath Products",
      "rating": 4.4,
      "reviewCount": 156,
      "discount": 0,
      "inStock": true,
      "features": ["Gentle Formula", "Tear-Free", "Natural Ingredients"]
    },

    // ==================== BOOKS & LEARNING CATEGORY ====================
    {
      "title": "Baby's First Books Set",
      "image": "assets/images/first.jpg",
      "description": "Set of 6 colorful board books perfect for baby's development.",
      "price": 16.0,
      "category": "Books",
      "subcategory": "Board Books",
      "rating": 4.7,
      "reviewCount": 198,
      "discount": 0,
      "inStock": true,
      "features": ["Board Books", "Colorful Pictures", "Educational"]
    },
    {
      "title": "Soft Fabric Books",
      "image": "assets/images/fabric.jpg",
      "description": "Washable fabric books with different textures for sensory play.",
      "price": 14.0,
      "originalPrice": 18.0,
      "category": "Books",
      "subcategory": "Soft Books",
      "rating": 4.5,
      "reviewCount": 134,
      "discount": 22,
      "inStock": true,
      "features": ["Washable", "Different Textures", "Sensory Play"]
    },
    // {
    //   "title": "Musical Learning Toy",
    //   "image": "assets/images/learning-toy.jpg",
    //   "description": "Interactive toy that teaches numbers, letters, and songs.",
    //   "price": 32.0,
    //   "category": "Books",
    //   "subcategory": "Learning Toys",
    //   "rating": 4.6,
    //   "reviewCount": 156,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Interactive", "Educational", "Musical"]
    // },
    // {
    //   "title": "Touch & Feel Books",
    //   "image": "assets/images/touch-feel-books.jpg",
    //   "description": "Interactive books with different textures to explore.",
    //   "price": 12.0,
    //   "category": "Books",
    //   "subcategory": "Interactive Books",
    //   "rating": 4.6,
    //   "reviewCount": 123,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Touch & Feel", "Interactive", "Durable"]
    // },
    {
      "title": "Alphabet Learning Cards",
      "image": "assets/images/alphabetic.jpg",
      "description": "Colorful alphabet cards for early learning and recognition.",
      "price": 9.0,
      "originalPrice": 12.0,
      "category": "Books",
      "subcategory": "Learning Cards",
      "rating": 4.4,
      "reviewCount": 167,
      "discount": 25,
      "inStock": true,
      "features": ["Alphabet Learning", "Colorful", "Durable Cards"]
    },

    // // ==================== MATERNITY CATEGORY ====================
    // {
    //   "title": "Maternity Pillow",
    //   "image": "assets/images/maternity-pillow.jpg",
    //   "description": "Full-body pregnancy pillow for comfortable sleep and support.",
    //   "price": 45.0,
    //   "originalPrice": 60.0,
    //   "category": "Maternity",
    //   "subcategory": "Pregnancy Support",
    //   "rating": 4.7,
    //   "reviewCount": 189,
    //   "discount": 25,
    //   "inStock": true,
    //   "features": ["Full Body Support", "Removable Cover", "Hypoallergenic"]
    // },
    // {
    //   "title": "Nursing Bras Set",
    //   "image": "assets/images/nursing-bras.jpg",
    //   "description": "Comfortable nursing bras with easy-open clips.",
    //   "price": 35.0,
    //   "category": "Maternity",
    //   "subcategory": "Nursing Wear",
    //   "rating": 4.5,
    //   "reviewCount": 145,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Easy-Open Clips", "Comfortable Fit", "Wireless"]
    // },
    // {
    //   "title": "Maternity Belly Band",
    //   "image": "assets/images/belly-band.jpg",
    //   "description": "Supportive belly band for pregnancy comfort and back support.",
    //   "price": 25.0,
    //   "originalPrice": 32.0,
    //   "category": "Maternity",
    //   "subcategory": "Maternity Support",
    //   "rating": 4.4,
    //   "reviewCount": 123,
    //   "discount": 22,
    //   "inStock": true,
    //   "features": ["Back Support", "Adjustable", "Breathable Fabric"]
    // },
    // {
    //   "title": "Nursing Pads",
    //   "image": "assets/images/nursing-pads.jpg",
    //   "description": "Disposable nursing pads for leak protection.",
    //   "price": 12.0,
    //   "category": "Maternity",
    //   "subcategory": "Nursing Accessories",
    //   "rating": 4.3,
    //   "reviewCount": 167,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Leak Protection", "Ultra-Thin", "Adhesive Strips"]
    // },
    // {
    //   "title": "Maternity Dress",
    //   "image": "assets/images/maternity-dress.jpg",
    //   "description": "Stylish and comfortable maternity dress for all occasions.",
    //   "price": 42.0,
    //   "category": "Maternity",
    //   "subcategory": "Maternity Clothing",
    //   "rating": 4.6,
    //   "reviewCount": 98,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Stylish Design", "Comfortable Fit", "Nursing Friendly"]
    // },

    // // ==================== BABY MONITORS & TECH CATEGORY ====================
    // {
    //   "title": "Video Baby Monitor",
    //   "image": "assets/images/video-monitor.jpg",
    //   "description": "HD video baby monitor with night vision and two-way audio.",
    //   "price": 85.0,
    //   "originalPrice": 110.0,
    //   "category": "Monitors",
    //   "subcategory": "Video Monitors",
    //   "rating": 4.6,
    //   "reviewCount": 134,
    //   "discount": 23,
    //   "inStock": true,
    //   "features": ["HD Video", "Night Vision", "Two-Way Audio"]
    // },
    // {
    //   "title": "Audio Baby Monitor",
    //   "image": "assets/images/audio-monitor.jpg",
    //   "description": "Long-range audio monitor with clear sound quality.",
    //   "price": 35.0,
    //   "category": "Monitors",
    //   "subcategory": "Audio Monitors",
    //   "rating": 4.4,
    //   "reviewCount": 156,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Long Range", "Clear Audio", "Rechargeable"]
    // },
    // {
    //   "title": "Smart Baby Monitor",
    //   "image": "assets/images/smart-monitor.jpg",
    //   "description": "WiFi-enabled smart monitor with smartphone app control.",
    //   "price": 120.0,
    //   "category": "Monitors",
    //   "subcategory": "Smart Monitors",
    //   "rating": 4.7,
    //   "reviewCount": 89,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["WiFi Enabled", "Smartphone App", "Cloud Storage"]
    // },
    // {
    //   "title": "Movement Monitor",
    //   "image": "assets/images/movement-monitor.jpg",
    //   "description": "Under-mattress movement monitor for peace of mind.",
    //   "price": 95.0,
    //   "originalPrice": 120.0,
    //   "category": "Monitors",
    //   "subcategory": "Movement Monitors",
    //   "rating": 4.5,
    //   "reviewCount": 67,
    //   "discount": 21,
    //   "inStock": true,
    //   "features": ["Movement Detection", "Under-Mattress", "Alert System"]
    // },
    // {
    //   "title": "Baby Breathing Monitor",
    //   "image": "assets/images/breathing-monitor.jpg",
    //   "description": "Wearable breathing monitor with smartphone alerts.",
    //   "price": 150.0,
    //   "category": "Monitors",
    //   "subcategory": "Breathing Monitors",
    //   "rating": 4.8,
    //   "reviewCount": 78,
    //   "discount": 0,
    //   "inStock": false,
    //   "features": ["Wearable", "Breathing Detection", "Smartphone Alerts"]
    // },

    // // ==================== OUTDOOR & TRAVEL CATEGORY ====================
    // {
    //   "title": "Travel Crib",
    //   "image": "assets/images/travel-crib.jpg",
    //   "description": "Portable travel crib that folds compactly for trips.",
    //   "price": 75.0,
    //   "originalPrice": 95.0,
    //   "category": "Travel",
    //   "subcategory": "Travel Cribs",
    //   "rating": 4.5,
    //   "reviewCount": 123,
    //   "discount": 21,
    //   "inStock": true,
    //   "features": ["Portable", "Compact Fold", "Easy Setup"]
    // },
    // {
    //   "title": "Baby Beach Tent",
    //   "image": "assets/images/beach-tent.jpg",
    //   "description": "UV protection beach tent with built-in pool for babies.",
    //   "price": 38.0,
    //   "category": "Travel",
    //   "subcategory": "Outdoor Gear",
    //   "rating": 4.4,
    //   "reviewCount": 167,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["UV Protection", "Built-in Pool", "Easy Setup"]
    // },
    // {
    //   "title": "Portable High Chair",
    //   "image": "assets/images/portable-highchair.jpg",
    //   "description": "Foldable portable high chair for dining out and travel.",
    //   "price": 45.0,
    //   "originalPrice": 55.0,
    //   "category": "Travel",
    //   "subcategory": "Travel Feeding",
    //   "rating": 4.3,
    //   "reviewCount": 98,
    //   "discount": 18,
    //   "inStock": true,
    //   "features": ["Foldable", "Portable", "Safety Harness"]
    // },
    // {
    //   "title": "Baby Wagon",
    //   "image": "assets/images/baby-wagon.jpg",
    //   "description": "All-terrain wagon with canopy and safety harnesses.",
    //   "price": 180.0,
    //   "category": "Travel",
    //   "subcategory": "Wagons",
    //   "rating": 4.6,
    //   "reviewCount": 89,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["All-Terrain", "Canopy", "Safety Harnesses"]
    // },
    // {
    //   "title": "Travel Bottle Warmer",
    //   "image": "assets/images/travel-warmer.jpg",
    //   "description": "Portable bottle warmer for feeding on the go.",
    //   "price": 28.0,
    //   "category": "Travel",
    //   "subcategory": "Travel Accessories",
    //   "rating": 4.2,
    //   "reviewCount": 134,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Portable", "Car Adapter", "Quick Warming"]
    // },

    // // ==================== GIFTS & KEEPSAKES CATEGORY ====================
    // {
    //   "title": "Baby Memory Book",
    //   "image": "assets/images/memory-book.jpg",
    //   "description": "Beautiful memory book to record baby's first year milestones.",
    //   "price": 22.0,
    //   "category": "Gifts",
    //   "subcategory": "Memory Books",
    //   "rating": 4.8,
    //   "reviewCount": 156,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["First Year Milestones", "Photo Pages", "Quality Binding"]
    // },
    // {
    //   "title": "Hand & Footprint Kit",
    //   "image": "assets/images/handprint-kit.jpg",
    //   "description": "Clay impression kit to capture baby's tiny hands and feet.",
    //   "price": 18.0,
    //   "originalPrice": 24.0,
    //   "category": "Gifts",
    //   "subcategory": "Keepsakes",
    //   "rating": 4.6,
    //   "reviewCount": 189,
    //   "discount": 25,
    //   "inStock": true,
    //   "features": ["Clay Impression", "Display Frame", "Safe Materials"]
    // },
    // {
    //   "title": "Personalized Baby Blanket",
    //   "image": "assets/images/personalized-blanket.jpg",
    //   "description": "Soft blanket with custom embroidered name and birth details.",
    //   "price": 35.0,
    //   "category": "Gifts",
    //   "subcategory": "Personalized Gifts",
    //   "rating": 4.9,
    //   "reviewCount": 234,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Custom Embroidery", "Soft Fabric", "Gift Packaging"]
    // },
    // {
    //   "title": "Baby Gift Basket",
    //   "image": "assets/images/gift-basket.jpg",
    //   "description": "Curated gift basket with essential baby items and toys.",
    //   "price": 65.0,
    //   "originalPrice": 80.0,
    //   "category": "Gifts",
    //   "subcategory": "Gift Sets",
    //   "rating": 4.7,
    //   "reviewCount": 123,
    //   "discount": 19,
    //   "inStock": true,
    //   "features": ["Curated Items", "Beautiful Basket", "Gift Ready"]
    // },
    // {
    //   "title": "Baby's First Christmas Ornament",
    //   "image": "assets/images/christmas-ornament.jpg",
    //   "description": "Commemorative ornament for baby's first Christmas.",
    //   "price": 15.0,
    //   "category": "Gifts",
    //   "subcategory": "Holiday Gifts",
    //   "rating": 4.5,
    //   "reviewCount": 167,
    //   "discount": 0,
    //   "inStock": true,
    //   "features": ["Commemorative", "Quality Materials", "Gift Box Included"]
    // },

  
  ];

  List<Map<String, dynamic>> get filteredProducts {
    var filtered = allProducts
        .where((product) => product["category"] == widget.categoryTitle)
        .toList();
    
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a["price"].compareTo(b["price"]));
        break;
      case 'price_high':
        filtered.sort((a, b) => b["price"].compareTo(a["price"]));
        break;
      case 'rating':
        filtered.sort((a, b) => b["rating"].compareTo(a["rating"]));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a["title"].compareTo(b["title"]));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final products = filteredProducts;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Updated background color to match modern theme
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildHeaderSection(),
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
    return AnimatedBuilder( // Added animated header section
      animation: _headerScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerScaleAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE1F5FE), // Updated to light blue gradient
                  Colors.white,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( // Added icon to header
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF81C784),
                            const Color(0xFF66BB6A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF81C784).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(widget.categoryTitle),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.categoryTitle,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Discover our ${widget.categoryTitle.toLowerCase()} collection",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'baby food':
        return Icons.restaurant_menu;
      case 'clothing':
        return Icons.checkroom;
      case 'toys':
        return Icons.toys;
      case 'diapers':
        return Icons.baby_changing_station;
      case 'baby care':
        return Icons.health_and_safety;
      case 'safety':
        return Icons.security;
      case 'strollers':
        return Icons.directions_walk;
      case 'nursery':
        return Icons.bed;
      case 'bath':
        return Icons.bathtub;
      case 'books':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
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
          Icon(Icons.sort, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            "Sort by:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF81C784)), // Updated to green theme
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF81C784), // Updated to green theme
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                  DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                  DropdownMenuItem(value: 'rating', child: Text('Rating')),
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
    );
  }

  Widget _buildProductCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        "$count ${count == 1 ? 'product' : 'products'} found",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container( // Enhanced empty state icon with gradient background
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE1F5FE),
                  const Color(0xFFE8F5E8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: const Color(0xFF64B5F6),
            ),
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
            "We couldn't find any products in this category.",
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
    final bool inStock = product["inStock"] ?? true;
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
              price: product["price"].toDouble(),
              originalPrice: product["originalPrice"]?.toDouble(),
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
        child: isGrid ? _buildGridCard(product, inStock, hasDiscount) : _buildListCard(product, inStock, hasDiscount),
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> product, bool inStock, bool hasDiscount) {
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
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<FavoritesProvider>(
                  builder: (context, favorites, child) {
                    final isFavorite = favorites.isFavorite(product["title"]);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact(); // Added haptic feedback
                        favorites.toggleFavorite(
                          FavoriteItem(
                            title: product["title"],
                            image: product["image"],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
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
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!inStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Text(
                        "OUT OF STOCK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                          "\$${product["price"].toStringAsFixed(2)}",
                          style: TextStyle(
                            color: const Color(0xFF81C784), // Updated to green theme
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasDiscount && product["originalPrice"] != null)
                          Text(
                            "\$${product["originalPrice"].toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return GestureDetector(
                          onTap: inStock ? () {
                            HapticFeedback.lightImpact(); // Added haptic feedback
                            cart.addToCart(
                              CartItem(
                                title: product["title"],
                                price: product["price"].toDouble(),
                                image: product["image"],
                                quantity: 1,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row( // Enhanced snackbar with icon
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text("${product["title"]} added to cart!"),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF81C784),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: inStock ? const Color(0xFF81C784) : Colors.grey.shade300, // Updated to green theme
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: inStock ? Colors.white : Colors.grey.shade500,
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
        ),
      ],
    );
  }

  Widget _buildListCard(Map<String, dynamic> product, bool inStock, bool hasDiscount) {
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
                if (!inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text(
                          "OUT OF STOCK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
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
                      Consumer<FavoritesProvider>(
                        builder: (context, favorites, child) {
                          final isFavorite = favorites.isFavorite(product["title"]);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact(); // Added haptic feedback
                              favorites.toggleFavorite(
                                FavoriteItem(
                                  title: product["title"],
                                  image: product["image"],
                                ),
                              );
                            },
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          );
                        },
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
                          "${product["rating"]} (${product["reviewCount"]} reviews)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
                            "\$${product["price"].toStringAsFixed(2)}",
                            style: TextStyle(
                              color: const Color(0xFF81C784), // Updated to green theme
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (hasDiscount && product["originalPrice"] != null)
                            Text(
                              "\$${product["originalPrice"].toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return ElevatedButton.icon(
                            onPressed: inStock ? () {
                              HapticFeedback.lightImpact(); // Added haptic feedback
                              cart.addToCart(
                                CartItem(
                                  title: product["title"],
                                  price: product["price"].toDouble(),
                                  image: product["image"],
                                  quantity: 1,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row( // Enhanced snackbar with icon
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text("${product["title"]} added to cart!"),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF81C784),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } : null,
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text("Add", style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inStock ? const Color(0xFF81C784) : Colors.grey.shade300, // Updated to green theme
                              foregroundColor: inStock ? Colors.white : Colors.grey.shade500,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
          ),
        ],
      ),
    );
  }
}
