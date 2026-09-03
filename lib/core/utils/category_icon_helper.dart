import 'package:flutter/material.dart';

/// Centralized utility for resolving unique, semantic, and befitting icons
/// for categories across the entire application.
///
/// Supports icon identifier lookup, category name keyword matching, and intelligent fallbacks.
abstract class CategoryIconHelper {
  /// Returns the most befitting [IconData] based on [iconName] and/or [categoryName].
  static IconData getIcon(String? iconName, [String? categoryName]) {
    final cleanIcon = iconName?.toLowerCase().trim() ?? '';
    final cleanName = categoryName?.toLowerCase().trim() ?? '';

    // 1. Direct Icon Identifier Mapping
    switch (cleanIcon) {
      // Food & Dining
      case 'restaurant':
      case 'restaurant_rounded':
      case 'restaurant_menu':
      case 'food':
      case 'dining':
      case 'lunch':
      case 'dinner':
      case 'fastfood':
      case 'fastfood_rounded':
        return Icons.restaurant_rounded;

      // Grocery Shopping
      case 'shopping_cart':
      case 'shopping_cart_rounded':
      case 'grocery':
      case 'groceries':
      case 'supermarket':
      case 'local_grocery_store':
        return Icons.shopping_cart_rounded;

      // Coffee & Cafes
      case 'coffee':
      case 'cafe':
      case 'local_cafe':
      case 'tea':
      case 'bakery':
      case 'espresso':
        return Icons.coffee_rounded;

      // Housing & Rent
      case 'home':
      case 'home_rounded':
      case 'housing':
      case 'house':
      case 'apartment':
      case 'cottage':
      case 'home_work':
      case 'home_work_rounded':
        return Icons.home_work_rounded;

      // Utilities & Bills
      case 'receipt_long':
      case 'receipt_long_rounded':
      case 'receipt':
      case 'utilities':
      case 'utility':
      case 'bills':
      case 'bill':
      case 'bolt':
      case 'electric':
      case 'electricity':
      case 'power':
      case 'water_drop':
      case 'gas':
        return Icons.receipt_long_rounded;

      // Public Transportation & Commute
      case 'directions_bus':
      case 'directions_bus_rounded':
      case 'transportation':
      case 'transport':
      case 'commute':
      case 'bus':
      case 'transit':
      case 'train':
      case 'subway':
        return Icons.directions_bus_rounded;

      // Car & Vehicle
      case 'directions_car':
      case 'directions_car_rounded':
      case 'car':
      case 'auto':
      case 'vehicle':
      case 'fuel':
      case 'petrol':
      case 'gas_station':
      case 'local_gas_station':
        return Icons.directions_car_rounded;

      // Taxi & Rideshare
      case 'local_taxi':
      case 'local_taxi_rounded':
      case 'taxi':
      case 'cab':
      case 'uber':
        return Icons.local_taxi_rounded;

      // Entertainment & Movies
      case 'movie':
      case 'movie_rounded':
      case 'movie_creation':
      case 'entertainment':
      case 'theaters':
      case 'theater':
      case 'cinema':
      case 'film':
        return Icons.movie_rounded;

      // Gaming
      case 'sports_esports':
      case 'sports_esports_rounded':
      case 'games':
      case 'gaming':
      case 'videogame_asset':
        return Icons.sports_esports_rounded;

      // Health & Medical
      case 'medical_services':
      case 'medical_services_rounded':
      case 'medical':
      case 'health':
      case 'wellness':
      case 'doctor':
      case 'hospital':
      case 'pharmacy':
      case 'clinic':
      case 'medicine':
        return Icons.medical_services_rounded;

      // Fitness & Gym
      case 'fitness_center':
      case 'fitness_center_rounded':
      case 'fitness':
      case 'gym':
      case 'workout':
      case 'exercise':
        return Icons.fitness_center_rounded;

      // Shopping & Apparel
      case 'shopping_bag':
      case 'shopping_bag_rounded':
      case 'shopping':
      case 'apparel':
      case 'clothes':
      case 'clothing':
      case 'checkroom':
      case 'fashion':
        return Icons.shopping_bag_rounded;

      // Personal Care & Haircut
      case 'content_cut':
      case 'content_cut_rounded':
      case 'personal_care':
      case 'personal':
      case 'care':
      case 'haircut':
      case 'barber':
      case 'salon':
        return Icons.content_cut_rounded;

      // Beauty & Spa
      case 'spa':
      case 'beauty':
      case 'cosmetics':
      case 'makeup':
      case 'skincare':
      case 'grooming':
      case 'massage':
        return Icons.spa_rounded;

      // Self Care & Mindfulness
      case 'self_improvement':
      case 'self_care':
      case 'meditation':
      case 'yoga':
      case 'mindfulness':
        return Icons.self_improvement_rounded;

      // Hobbies & Crafts
      case 'palette':
      case 'art':
      case 'craft':
      case 'crafts':
      case 'hobbies':
      case 'hobby':
      case 'painting':
      case 'drawing':
        return Icons.palette_rounded;

      // Books & Media
      case 'menu_book':
      case 'book':
      case 'books':
      case 'reading':
      case 'literature':
      case 'magazine':
        return Icons.menu_book_rounded;

      // Education & University
      case 'school':
      case 'school_rounded':
      case 'education':
      case 'course':
      case 'university':
      case 'college':
      case 'tuition':
      case 'study':
        return Icons.school_rounded;

      // Travel & Vacation
      case 'flight':
      case 'flight_rounded':
      case 'flight_takeoff':
      case 'flight_takeoff_rounded':
      case 'travel':
      case 'vacation':
      case 'trip':
      case 'tourism':
      case 'luggage':
      case 'hotel':
        return Icons.flight_takeoff_rounded;

      // Subscriptions & Recurring
      case 'subscriptions':
      case 'subscriptions_rounded':
      case 'subscription':
      case 'streaming':
      case 'stream':
      case 'autorenew':
      case 'repeat':
      case 'membership':
        return Icons.subscriptions_rounded;

      // Events & Celebrations
      case 'celebration':
      case 'celebration_rounded':
      case 'party':
      case 'event':
      case 'events':
      case 'festival':
      case 'anniversary':
      case 'birthday':
        return Icons.celebration_rounded;

      // Concerts & Live Shows
      case 'music_note':
      case 'music_note_rounded':
      case 'music':
      case 'audio':
      case 'concert':
      case 'concerts':
      case 'live_show':
      case 'gig':
        return Icons.music_note_rounded;

      // Weddings & Ceremonies
      case 'favorite':
      case 'favorite_rounded':
      case 'wedding':
      case 'weddings':
      case 'ceremony':
      case 'ceremonies':
      case 'marriage':
      case 'engagement':
        return Icons.favorite_rounded;

      // Sports & Stadium Events
      case 'sports_soccer':
      case 'sports_soccer_rounded':
      case 'sports':
      case 'stadium':
      case 'match':
      case 'tournament':
      case 'football':
        return Icons.sports_soccer_rounded;

      // Nightlife & Bars
      case 'nightlife':
      case 'nightlife_rounded':
      case 'club':
      case 'nightclub':
      case 'pub':
      case 'local_bar':
      case 'bar':
      case 'drinks':
      case 'alcohol':
      case 'beverages':
        return Icons.nightlife_rounded;

      // Gifts & Donations
      case 'card_giftcard':
      case 'card_giftcard_rounded':
      case 'gifts':
      case 'gift':
      case 'donations':
      case 'donation':
      case 'charity':
      case 'present':
      case 'volunteer_activism':
        return Icons.card_giftcard_rounded;

      // Family & Childcare
      case 'child_care':
      case 'child_care_rounded':
      case 'family':
      case 'childcare':
      case 'baby':
      case 'children':
      case 'kids':
      case 'family_restroom':
        return Icons.child_care_rounded;

      // Pets
      case 'pets':
      case 'pets_rounded':
      case 'pet':
      case 'dog':
      case 'cat':
      case 'animal':
      case 'vet':
      case 'veterinary':
        return Icons.pets_rounded;

      // Debt & Loans
      case 'credit_card':
      case 'credit_card_rounded':
      case 'debt':
      case 'loan':
      case 'loans':
      case 'emi':
      case 'credit':
      case 'card':
      case 'mortgage':
      case 'price_change':
        return Icons.credit_card_rounded;

      // Salary & Paycheck
      case 'payments':
      case 'payments_rounded':
      case 'salary':
      case 'income':
      case 'wage':
      case 'wages':
      case 'paycheck':
      case 'payroll':
      case 'stipend':
        return Icons.payments_rounded;

      // Freelance & Work
      case 'work':
      case 'work_rounded':
      case 'freelance':
      case 'freelancing':
      case 'payout':
      case 'contract':
      case 'laptop_mac':
      case 'business_center':
        return Icons.work_rounded;

      // Investments & Dividends
      case 'trending_up':
      case 'trending_up_rounded':
      case 'investments':
      case 'investment':
      case 'dividends':
      case 'dividend':
      case 'stocks':
      case 'stock':
      case 'crypto':
      case 'trading':
      case 'show_chart':
      case 'stacked_line_chart':
        return Icons.trending_up_rounded;

      // Business & Storefront
      case 'storefront':
      case 'storefront_rounded':
      case 'business':
      case 'business_revenue':
      case 'revenue':
      case 'store':
      case 'sales':
      case 'commerce':
      case 'domain':
        return Icons.storefront_rounded;

      // Rental Income
      case 'real_estate_agent':
      case 'real_estate_agent_rounded':
      case 'rental':
      case 'rental_income':
      case 'tenant':
      case 'real_estate':
      case 'holiday_village':
        return Icons.real_estate_agent_rounded;

      // Gifts & Cashbacks
      case 'redeem':
      case 'redeem_rounded':
      case 'gifts_and_cashbacks':
      case 'cashback':
      case 'cashbacks':
      case 'rewards':
      case 'reward':
      case 'bonus':
      case 'prize':
        return Icons.redeem_rounded;

      // Refunds & Reimbursements
      case 'currency_exchange':
      case 'currency_exchange_rounded':
      case 'refunds':
      case 'refund':
      case 'reimbursements':
      case 'reimbursement':
      case 'swap_horiz':
      case 'exchange':
        return Icons.currency_exchange_rounded;

      // Savings
      case 'savings':
      case 'savings_rounded':
      case 'savings_outlined':
      case 'piggy_bank':
      case 'deposit':
        return Icons.savings_rounded;

      // Overall Limit / All
      case 'all_inclusive':
      case 'all_inclusive_rounded':
      case 'overall':
      case 'all':
        return Icons.all_inclusive_rounded;

      // Other / Misc
      case 'more_horiz':
      case 'more_horiz_rounded':
      case 'other_expense':
      case 'other':
      case 'misc':
      case 'miscellaneous':
        if (cleanName.contains('income') ||
            cleanName.contains('revenue') ||
            cleanName.contains('earning')) {
          return Icons.savings_rounded;
        }
        return Icons.more_horiz_rounded;

      // Additional Common Category Keywords
      case 'health_and_safety':
      case 'insurance':
        return Icons.health_and_safety_rounded;

      case 'account_balance':
      case 'bank':
      case 'tax':
      case 'taxes':
        return Icons.account_balance_rounded;

      case 'build':
      case 'tools':
      case 'repair':
      case 'maintenance':
      case 'hardware':
        return Icons.build_rounded;

      case 'devices':
      case 'electronics':
      case 'tech':
      case 'gadget':
      case 'gadgets':
      case 'computer':
      case 'laptop':
      case 'phone':
        return Icons.devices_rounded;
    }

    // 2. Keyword Matching on Category Name if iconName was generic or unmapped
    if (cleanName.isNotEmpty) {
      if (_matches(cleanName, [
        'dining',
        'food',
        'restaurant',
        'meal',
        'lunch',
        'dinner',
        'breakfast',
        'eat'
      ])) {
        return Icons.restaurant_rounded;
      }
      if (_matches(cleanName, [
        'grocery',
        'groceries',
        'market',
        'supermarket',
        'mart',
        'pantry'
      ])) {
        return Icons.shopping_cart_rounded;
      }
      if (_matches(cleanName,
          ['cafe', 'coffee', 'tea', 'bakery', 'starbucks', 'espresso'])) {
        return Icons.coffee_rounded;
      }
      if (_matches(cleanName, [
        'wedding',
        'marriage',
        'ceremony',
        'ceremonies',
        'engagement',
        'bridal'
      ])) {
        return Icons.favorite_rounded;
      }
      if (_matches(cleanName, [
        'concert',
        'live show',
        'gig',
        'music',
        'spotify',
        'sound',
        'audio',
        'band'
      ])) {
        return Icons.music_note_rounded;
      }
      if (_matches(cleanName, [
        'stadium',
        'match',
        'tournament',
        'soccer',
        'football',
        'basketball',
        'cricket',
        'tennis',
        'sports event'
      ])) {
        return Icons.sports_soccer_rounded;
      }
      if (_matches(cleanName, [
        'nightlife',
        'club',
        'nightclub',
        'pub',
        'bar',
        'drink',
        'drinks',
        'beer',
        'wine',
        'cocktail',
        'liquor'
      ])) {
        return Icons.nightlife_rounded;
      }
      if (_matches(cleanName, [
        'party',
        'celebration',
        'event',
        'events',
        'festival',
        'anniversary',
        'birthday'
      ])) {
        return Icons.celebration_rounded;
      }
      if (_matches(cleanName, [
        'self care',
        'self-care',
        'meditation',
        'yoga',
        'mindfulness',
        'therapy',
        'counseling'
      ])) {
        return Icons.self_improvement_rounded;
      }
      if (_matches(cleanName, [
        'beauty',
        'cosmetic',
        'cosmetics',
        'makeup',
        'skincare',
        'spa',
        'massage',
        'grooming'
      ])) {
        return Icons.spa_rounded;
      }
      if (_matches(cleanName, [
        'hair',
        'haircut',
        'barber',
        'salon',
        'personal care',
        'personal'
      ])) {
        return Icons.content_cut_rounded;
      }
      if (_matches(cleanName, [
        'hobby',
        'hobbies',
        'craft',
        'crafts',
        'palette',
        'art',
        'painting',
        'drawing'
      ])) {
        return Icons.palette_rounded;
      }
      if (_matches(cleanName, [
        'book',
        'books',
        'reading',
        'literature',
        'manga',
        'comics',
        'magazine'
      ])) {
        return Icons.menu_book_rounded;
      }
      if (_matches(cleanName, [
        'housing',
        'rent',
        'mortgage',
        'house',
        'apartment',
        'home',
        'property'
      ])) {
        return Icons.home_work_rounded;
      }
      if (_matches(cleanName, [
        'utility',
        'utilities',
        'electric',
        'power',
        'water',
        'gas',
        'internet',
        'wifi',
        'broadband',
        'phone',
        'bill'
      ])) {
        return Icons.receipt_long_rounded;
      }
      if (_matches(cleanName, [
        'bus',
        'train',
        'metro',
        'transit',
        'subway',
        'commute',
        'transport'
      ])) {
        return Icons.directions_bus_rounded;
      }
      if (_matches(cleanName, [
        'car',
        'vehicle',
        'fuel',
        'petrol',
        'parking',
        'toll',
        'auto',
        'garage'
      ])) {
        return Icons.directions_car_rounded;
      }
      if (_matches(cleanName, ['taxi', 'cab', 'uber', 'lyft', 'ride'])) {
        return Icons.local_taxi_rounded;
      }
      if (_matches(cleanName, [
        'flight',
        'airline',
        'plane',
        'travel',
        'vacation',
        'trip',
        'holiday',
        'hotel',
        'tour',
        'resort',
        'luggage'
      ])) {
        return Icons.flight_takeoff_rounded;
      }
      if (_matches(cleanName, [
        'movie',
        'cinema',
        'theatre',
        'theater',
        'film',
        'entertainment',
        'show'
      ])) {
        return Icons.movie_rounded;
      }
      if (_matches(cleanName, [
        'game',
        'gaming',
        'esports',
        'playstation',
        'xbox',
        'steam',
        'nintendo'
      ])) {
        return Icons.sports_esports_rounded;
      }
      if (_matches(cleanName, [
        'gym',
        'fitness',
        'workout',
        'exercise',
        'training',
        'sport',
        'athletics'
      ])) {
        return Icons.fitness_center_rounded;
      }
      if (_matches(cleanName, [
        'health',
        'medical',
        'medicine',
        'doctor',
        'hospital',
        'clinic',
        'pharmacy',
        'dental',
        'dentist',
        'physio'
      ])) {
        return Icons.medical_services_rounded;
      }
      if (_matches(cleanName, ['insurance'])) {
        return Icons.health_and_safety_rounded;
      }
      if (_matches(cleanName, [
        'clothes',
        'clothing',
        'apparel',
        'fashion',
        'wear',
        'shoes',
        'dress',
        'shirt',
        'shopping',
        'mall',
        'boutique'
      ])) {
        return Icons.shopping_bag_rounded;
      }
      if (_matches(cleanName, [
        'school',
        'college',
        'university',
        'education',
        'tuition',
        'course',
        'study',
        'class',
        'learning'
      ])) {
        return Icons.school_rounded;
      }
      if (_matches(cleanName, [
        'subscription',
        'streaming',
        'netflix',
        'hulu',
        'membership',
        'saas',
        'recurring'
      ])) {
        return Icons.subscriptions_rounded;
      }
      if (_matches(cleanName, [
        'gift',
        'donation',
        'donations',
        'charity',
        'present',
        'tip',
        'contribution',
        'fund'
      ])) {
        return Icons.card_giftcard_rounded;
      }
      if (_matches(cleanName, [
        'child',
        'children',
        'kid',
        'kids',
        'baby',
        'daycare',
        'family',
        'parent',
        'nursery'
      ])) {
        return Icons.child_care_rounded;
      }
      if (_matches(cleanName, [
        'pet',
        'pets',
        'dog',
        'cat',
        'puppy',
        'kitten',
        'vet',
        'animal',
        'veterinary'
      ])) {
        return Icons.pets_rounded;
      }
      if (_matches(cleanName, [
        'debt',
        'loan',
        'loans',
        'emi',
        'credit card',
        'credit',
        'interest',
        'payoff'
      ])) {
        return Icons.credit_card_rounded;
      }
      if (_matches(cleanName,
          ['salary', 'wage', 'wages', 'payroll', 'paycheck', 'stipend'])) {
        return Icons.payments_rounded;
      }
      if (_matches(cleanName, [
        'freelance',
        'contract',
        'gig',
        'upwork',
        'fiverr',
        'client',
        'consulting',
        'consultant'
      ])) {
        return Icons.work_rounded;
      }
      if (_matches(cleanName, [
        'invest',
        'stock',
        'stocks',
        'shares',
        'dividend',
        'dividends',
        'crypto',
        'bitcoin',
        'trading',
        'equity',
        'fund',
        'etf',
        'asset'
      ])) {
        return Icons.trending_up_rounded;
      }
      if (_matches(cleanName, [
        'business',
        'store',
        'shop',
        'sale',
        'sales',
        'company',
        'merchant',
        'commerce',
        'revenue'
      ])) {
        return Icons.storefront_rounded;
      }
      if (_matches(
          cleanName, ['rental', 'tenant', 'lease', 'airbnb', 'landlord'])) {
        return Icons.real_estate_agent_rounded;
      }
      if (_matches(cleanName,
          ['cashback', 'reward', 'rewards', 'points', 'prize', 'bonus'])) {
        return Icons.redeem_rounded;
      }
      if (_matches(cleanName,
          ['refund', 'reimbursement', 'reimburse', 'return', 'exchange'])) {
        return Icons.currency_exchange_rounded;
      }
      if (_matches(cleanName, ['saving', 'savings', 'deposit', 'piggy'])) {
        return Icons.savings_rounded;
      }
      if (_matches(cleanName,
          ['tax', 'taxes', 'government', 'irs', 'duty', 'vat', 'gst'])) {
        return Icons.account_balance_rounded;
      }
      if (_matches(cleanName, [
        'maintenance',
        'repair',
        'hardware',
        'tools',
        'plumbing',
        'electrician',
        'handyman'
      ])) {
        return Icons.build_rounded;
      }
      if (_matches(cleanName, [
        'gadget',
        'device',
        'devices',
        'electronics',
        'tech',
        'software',
        'app',
        'computer',
        'laptop',
        'phone'
      ])) {
        return Icons.devices_rounded;
      }
      if (_matches(cleanName, ['overall', 'total', 'all', 'everything'])) {
        return Icons.all_inclusive_rounded;
      }
      if (_matches(cleanName, ['other income'])) {
        return Icons.savings_rounded;
      }
      if (_matches(cleanName, ['other', 'misc', 'miscellaneous', 'general'])) {
        return Icons.more_horiz_rounded;
      }
    }

    return Icons.category_rounded;
  }

  static bool _matches(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}
