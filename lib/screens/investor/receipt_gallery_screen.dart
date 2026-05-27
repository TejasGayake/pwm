import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/photo_viewer.dart';

class ReceiptGalleryScreen extends StatelessWidget {
  final String tenderId;
  const ReceiptGalleryScreen({super.key, required this.tenderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Gallery')),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: FirestoreService().getExpensesForTender(tenderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data?.where((e) => e.hasPhoto).toList() ?? [];
          if (expenses.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No receipts available', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoViewer(imageUrl: expense.receiptPhotoUrl!))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: expense.receiptPhotoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
