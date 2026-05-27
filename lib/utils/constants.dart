class AppConstants {
  static const List<String> expenseCategories = ['Materials', 'Labor', 'Machinery', 'Diesel', 'Fuel', 'Misc'];
  static const Map<String, String> expenseCategoryIcons = {
    'Materials': '\u{1F9F1}',
    'Labor': '\u{1F477}',
    'Machinery': '\u{1F3D7}',
    'Diesel': '\u{26FD}',
    'Fuel': '\u{1F6E2}',
    'Misc': '\u{1F4E6}',
  };
}

class ExpenseCategories {
  static const List<String> all = ['Materials', 'Labor', 'Machinery', 'Diesel', 'Fuel', 'Misc'];

  static String displayName(String category) {
    switch (category) {
      case 'Materials': return 'Materials';
      case 'Labor': return 'Labor';
      case 'Machinery': return 'Machinery';
      case 'Diesel': return 'Diesel';
      case 'Fuel': return 'Fuel';
      case 'Misc': return 'Miscellaneous';
      default: return category;
    }
  }

  static String icon(String category) {
    switch (category) {
      case 'Materials': return '\u{1F9F1}';
      case 'Labor': return '\u{1F477}';
      case 'Machinery': return '\u{1F3D7}';
      case 'Diesel': return '\u{26FD}';
      case 'Fuel': return '\u{1F6E2}';
      case 'Misc': return '\u{1F4E6}';
      default: return '\u{1F4CB}';
    }
  }
}

class FirestoreCollections {
  static const String tenders = 'tenders';
  static const String investors = 'investors';
  static const String contributions = 'contributions';
  static const String expenses = 'expenses';
  static const String users = 'users';
}

class StoragePaths {
  static const String receipts = 'receipts';
  static const String contributionProof = 'contributions';
  static const String progress = 'progress';
}
