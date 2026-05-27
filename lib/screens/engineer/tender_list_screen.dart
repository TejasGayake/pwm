import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tender_provider.dart';
import '../../models/tender_model.dart';
import '../../utils/helpers.dart';
import '../../theme/app_theme.dart';
import 'tender_detail_screen.dart';

class TenderListScreen extends StatefulWidget {
  const TenderListScreen({super.key});

  @override
  State<TenderListScreen> createState() => _TenderListScreenState();
}

class _TenderListScreenState extends State<TenderListScreen> {
  String _filter = 'all';

  List<TenderModel> _getFilteredTenders(TenderProvider provider) {
    switch (_filter) {
      case 'active':
        return provider.activeTenders;
      case 'completed':
        return provider.completedTenders;
      case 'on_hold':
        return provider.onHoldTenders;
      default:
        return provider.tenders;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade50;
      case 'completed':
        return Colors.blue.shade50;
      case 'on_hold':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenderProvider = context.watch<TenderProvider>();
    final filteredTenders = _getFilteredTenders(tenderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tenders'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('On Hold', 'on_hold'),
              ],
            ),
          ),
          Expanded(
            child: tenderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTenders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tenders found',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {},
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTenders.length,
                          itemBuilder: (context, index) {
                            final tender = filteredTenders[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TenderDetailScreen(
                                        tender: tender),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tender.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _statusBgColor(
                                                  tender.status),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              tender.status
                                                  .replaceAll('_', ' ')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _statusColor(
                                                    tender.status),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              tender.location,
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.flag,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Target: ${Helpers.formatCurrency(tender.targetAmount)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${Helpers.formatDate(tender.startDate)} - ${Helpers.formatDate(tender.endDate)}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
      ),
    );
  }
}
