import 'package:expendly/core/utils/category_icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryIconHelper', () {
    test('resolves unique and befitting icons for all default expense categories including events and personal expenses', () {
      final defaultExpenseCategories = {
        // Daily & Essentials
        'Food & Dining': (icon: 'restaurant', expected: Icons.restaurant_rounded),
        'Grocery Shopping': (icon: 'shopping_cart', expected: Icons.shopping_cart_rounded),
        'Coffee & Cafes': (icon: 'coffee', expected: Icons.coffee_rounded),
        'Housing & Bills': (icon: 'home', expected: Icons.home_work_rounded),
        'Utilities': (icon: 'receipt_long', expected: Icons.receipt_long_rounded),
        'Transportation': (icon: 'directions_bus', expected: Icons.directions_bus_rounded),

        // Personal & Lifestyle
        'Personal Care': (icon: 'content_cut', expected: Icons.content_cut_rounded),
        'Beauty & Grooming': (icon: 'spa', expected: Icons.spa_rounded),
        'Self Care & Wellness': (icon: 'self_improvement', expected: Icons.self_improvement_rounded),
        'Fitness & Gym': (icon: 'fitness_center', expected: Icons.fitness_center_rounded),
        'Shopping & Apparel': (icon: 'shopping_bag', expected: Icons.shopping_bag_rounded),
        'Hobbies & Crafts': (icon: 'palette', expected: Icons.palette_rounded),
        'Books & Media': (icon: 'menu_book', expected: Icons.menu_book_rounded),
        'Electronics & Gadgets': (icon: 'devices', expected: Icons.devices_rounded),
        'Health & Wellness': (icon: 'medical_services', expected: Icons.medical_services_rounded),
        'Education': (icon: 'school', expected: Icons.school_rounded),
        'Subscriptions': (icon: 'subscriptions', expected: Icons.subscriptions_rounded),

        // Events & Leisure
        'Events & Celebrations': (icon: 'celebration', expected: Icons.celebration_rounded),
        'Concerts & Live Shows': (icon: 'music_note', expected: Icons.music_note_rounded),
        'Weddings & Ceremonies': (icon: 'favorite', expected: Icons.favorite_rounded),
        'Sports & Stadium Events': (icon: 'sports_soccer', expected: Icons.sports_soccer_rounded),
        'Nightlife & Bars': (icon: 'nightlife', expected: Icons.nightlife_rounded),
        'Entertainment': (icon: 'movie', expected: Icons.movie_rounded),
        'Travel & Vacation': (icon: 'flight', expected: Icons.flight_takeoff_rounded),

        // Family & Social
        'Gifts & Donations': (icon: 'card_giftcard', expected: Icons.card_giftcard_rounded),
        'Family & Childcare': (icon: 'child_care', expected: Icons.child_care_rounded),
        'Pets': (icon: 'pets', expected: Icons.pets_rounded),
        'Debt & Loans': (icon: 'credit_card', expected: Icons.credit_card_rounded),
        'Other Expense': (icon: 'more_horiz', expected: Icons.more_horiz_rounded),
      };

      final resolvedIcons = <IconData>{};

      for (final entry in defaultExpenseCategories.entries) {
        final icon = CategoryIconHelper.getIcon(entry.value.icon, entry.key);
        expect(icon, equals(entry.value.expected),
            reason: 'Category "${entry.key}" with icon "${entry.value.icon}" should resolve to ${entry.value.expected}');
        resolvedIcons.add(icon);
      }

      // Every expense category must have a unique icon
      expect(resolvedIcons.length, equals(defaultExpenseCategories.length),
          reason: 'All default expense category icons must be unique');
    });

    test('resolves unique and befitting icons for all default income categories', () {
      final defaultIncomeCategories = {
        'Salary': (icon: 'payments', expected: Icons.payments_rounded),
        'Freelance Payout': (icon: 'work', expected: Icons.work_rounded),
        'Investments & Dividends': (icon: 'trending_up', expected: Icons.trending_up_rounded),
        'Business Revenue': (icon: 'storefront', expected: Icons.storefront_rounded),
        'Rental Income': (icon: 'real_estate_agent', expected: Icons.real_estate_agent_rounded),
        'Gifts & Cashbacks': (icon: 'redeem', expected: Icons.redeem_rounded),
        'Refunds & Reimbursements': (icon: 'currency_exchange', expected: Icons.currency_exchange_rounded),
        'Other Income': (icon: 'more_horiz', expected: Icons.savings_rounded),
      };

      final resolvedIcons = <IconData>{};

      for (final entry in defaultIncomeCategories.entries) {
        final icon = CategoryIconHelper.getIcon(entry.value.icon, entry.key);
        expect(icon, equals(entry.value.expected),
            reason: 'Category "${entry.key}" with icon "${entry.value.icon}" should resolve to ${entry.value.expected}');
        resolvedIcons.add(icon);
      }

      // Every income category must have a unique icon
      expect(resolvedIcons.length, equals(defaultIncomeCategories.length),
          reason: 'All default income category icons must be unique');
    });

    test('falls back to category name keyword matching for event and personal expense terms', () {
      expect(CategoryIconHelper.getIcon('', 'Wedding Ceremony'), equals(Icons.favorite_rounded));
      expect(CategoryIconHelper.getIcon('', 'Rock Concert Tickets'), equals(Icons.music_note_rounded));
      expect(CategoryIconHelper.getIcon('', 'Birthday Party'), equals(Icons.celebration_rounded));
      expect(CategoryIconHelper.getIcon('', 'Football Match Stadium'), equals(Icons.sports_soccer_rounded));
      expect(CategoryIconHelper.getIcon('', 'Downtown Nightclub & Pub'), equals(Icons.nightlife_rounded));
      expect(CategoryIconHelper.getIcon('', 'Morning Coffee Cafe'), equals(Icons.coffee_rounded));
      expect(CategoryIconHelper.getIcon('', 'Yoga & Meditation Class'), equals(Icons.self_improvement_rounded));
      expect(CategoryIconHelper.getIcon('', 'Painting & Craft Supplies'), equals(Icons.palette_rounded));
      expect(CategoryIconHelper.getIcon('', 'Manga & Novel Books'), equals(Icons.menu_book_rounded));
      expect(CategoryIconHelper.getIcon('', 'Facial Spa & Skincare'), equals(Icons.spa_rounded));
    });

    test('defaults to category_rounded for completely unrecognized category name and icon', () {
      expect(CategoryIconHelper.getIcon('unknown_xyz', 'Random ABC 123'), equals(Icons.category_rounded));
      expect(CategoryIconHelper.getIcon(null, null), equals(Icons.category_rounded));
    });
  });
}
