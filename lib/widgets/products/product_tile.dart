// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../mixins/mixins.dart';
import '../../models/models.dart';
import '../utils/quote_utils.dart';

class ProductTile extends StatelessWidget with FormatterMixin {
  final Product product;
  final bool isSelected;
  final VoidCallback? onTap;

  const ProductTile({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      leading: CircleAvatar(
        backgroundColor: QuoteUtils.getTypeColor(product.type),
        child: Icon(
          QuoteUtils.getTypeIcon(product.type),
          color: Colors.white,
        ),
      ),
      title: Text(
        product.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.description),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Chip(
                  label: Text(
                    product.type.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: QuoteUtils.getTypeColor(product.type).withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Chip(
                  label: Text(
                    product.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatCurrency(product.basePrice),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 20,
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: Colors.green.shade50,
      onTap: onTap,
    );
  }
}
