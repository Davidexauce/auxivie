import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/backend_api_service.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Écran de détails d'un signalement
class ReportDetailScreen extends StatefulWidget {
  final int reportId;
  final int userId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.userId,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  ReportModel? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final report = await BackendApiService.getReportById(widget.reportId);
      setState(() => _report = report);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
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

  String _getStatusLabel(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Signalement #${widget.reportId}'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statut
                      _buildInfoCard(
                        title: 'Statut',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_report!.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(_report!.status),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _getStatusLabel(_report!.status),
                            style: TextStyle(
                              color: _getStatusColor(_report!.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Raison du signalement
                      _buildInfoCard(
                        title: 'Raison du signalement',
                        child: Row(
                          children: [
                            Text(
                              _report!.reasonIcon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                              _report!.reasonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Utilisateur signalé
                      _buildInfoCard(
                        title: 'Utilisateur signalé',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _report!.reportedName ?? 'Utilisateur #${_report!.reportedUserId}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (_report!.reportedEmail != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _report!.reportedEmail!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      if (_report!.description != null)
                        _buildInfoCard(
                          title: 'Description',
                          child: Text(
                            _report!.description!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),

                      if (_report!.description != null) const SizedBox(height: 16),

                      // Dates
                      _buildInfoCard(
                        title: 'Informations',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Créé le',
                              value: _formatDateTime(_report!.createdAt),
                            ),
                            if (_report!.resolvedAt != null) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.check_circle,
                                label: 'Résolu le',
                                value: _formatDateTime(_report!.resolvedAt!),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Notes admin
                      if (_report!.adminNotes != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Notes de l\'administrateur',
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.green50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.green200, width: 1),
                            ),
                            child: Text(
                              _report!.adminNotes!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textGreen,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Note
                      if (_report!.status == 'open')
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.green50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.green200, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppTheme.textGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Notre équipe traite votre signalement. '
                                  'Vous serez notifié dès qu\'une solution sera apportée.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Signalement introuvable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textTertiary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

