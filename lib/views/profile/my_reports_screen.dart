import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/backend_api_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/report_model.dart';
import '../../theme/app_theme.dart';
import '../reports/report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<ReportModel> _allReports = [];
  List<ReportModel> _filteredReports = [];
  String _selectedFilter = 'all'; // all, open, resolved, dismissed
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }
  

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    // Plus besoin de récupérer userId, le backend filtre automatiquement via le token JWT
    print('📡 [MY REPORTS] Chargement signalements de l\'utilisateur connecté');
    final reports = await BackendApiService.getMyReports();
    
    print('📡 [MY REPORTS] Signalements reçus: ${reports.length}');
    
    if (mounted) {
      setState(() {
        _allReports = reports;
        _applyFilter();
        _isLoading = false;
      });
      print('✅ [MY REPORTS] État mis à jour: ${_allReports.length} signalements');
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'all') {
        _filteredReports = _allReports;
      } else if (_selectedFilter == 'open') {
        _filteredReports = _allReports.where((r) => r.status == 'open').toList();
      } else if (_selectedFilter == 'resolved') {
        _filteredReports = _allReports.where((r) => r.status == 'resolved').toList();
      } else if (_selectedFilter == 'dismissed') {
        _filteredReports = _allReports.where((r) => r.status == 'dismissed').toList();
      }
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _navigateToDetail(ReportModel report) async {
    if (report.id == null) return;
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    
    if (currentUser?.id == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          reportId: report.id!,
          userId: currentUser!.id!,
        ),
      ),
    );

    // Recharger si le signalement a été modifié
    if (result == true) {
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _allReports.where((r) => r.status == 'open').length;
    final resolvedCount = _allReports.where((r) => r.status == 'resolved').length;
    final dismissedCount = _allReports.where((r) => r.status == 'dismissed').length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mes signalements'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.green50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: 'Tous (${_allReports.length})',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => _changeFilter('all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: 'Ouverts ($openCount)',
                        isSelected: _selectedFilter == 'open',
                        onTap: () => _changeFilter('open'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: 'Résolus ($resolvedCount)',
                        isSelected: _selectedFilter == 'resolved',
                        onTap: () => _changeFilter('resolved'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: 'Rejetés ($dismissedCount)',
                        isSelected: _selectedFilter == 'dismissed',
                        onTap: () => _changeFilter('dismissed'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = _filteredReports[index];
                            return _ReportCard(
                              report: report,
                              onTap: () => _navigateToDetail(report),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'Aucun signalement'
                : _selectedFilter == 'open'
                    ? 'Aucun signalement ouvert'
                    : _selectedFilter == 'resolved'
                        ? 'Aucun signalement résolu'
                        : 'Aucun signalement rejeté',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos signalements apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderSlate,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'open':
          return AppTheme.primary; // Vert pour "en cours"
        case 'resolved':
          return AppTheme.emerald; // Vert émeraude pour "résolu"
        case 'dismissed':
          return AppTheme.error; // Rouge pour "rejeté"
        default:
          return AppTheme.textTertiary;
      }
    }

    String getStatusLabel(String status) {
      switch (status) {
        case 'open':
          return 'En cours';
        case 'resolved':
          return 'Résolu';
        case 'dismissed':
          return 'Rejeté';
        default:
          return status;
      }
    }

    String formatDate(DateTime date) {
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Badge de statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(report.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getStatusColor(report.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      getStatusLabel(report.status),
                      style: TextStyle(
                        color: getStatusColor(report.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (report.id != null)
                    Text(
                      'ID: #${report.id}',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    report.reasonIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.reasonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.reportedName ?? 'Utilisateur #${report.reportedUserId}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (report.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  report.description!.length > 100
                      ? '${report.description!.substring(0, 100)}...'
                      : report.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(report.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
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
}

