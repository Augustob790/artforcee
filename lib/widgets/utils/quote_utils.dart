import 'package:flutter/material.dart';

import '../../models/products/product.dart';

class QuoteUtils {
  static Color getTypeColor(ProductType type) {
    switch (type) {
      case ProductType.industrial:
        return Colors.orange;
      case ProductType.residential:
        return Colors.blue;
      case ProductType.corporate:
        return Colors.purple;
    }
  }

 static IconData getTypeIcon(ProductType type) {
    switch (type) {
      case ProductType.industrial:
        return Icons.precision_manufacturing;
      case ProductType.residential:
        return Icons.home;
      case ProductType.corporate:
        return Icons.business;
    }
  }

}
