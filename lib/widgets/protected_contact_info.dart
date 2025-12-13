import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class ProtectedContactInfo extends StatelessWidget {
  final UserModel user;

  const ProtectedContactInfo({
    super.key,
    required this.user,
  });

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            _buildContactRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
              isVisible: user.isEmailVisible ?? false,
              onTap: (user.isEmailVisible == true && !user.isEmailMasked)
                  ? () => _sendEmail(user.email)
                  : null,
            ),

            const SizedBox(height: 12),

            // Téléphone
            _buildContactRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: user.phone ?? '***',
              isVisible: user.isPhoneVisible ?? false,
              onTap: (user.isPhoneVisible == true && !user.isPhoneMasked && user.phone != null)
                  ? () => _makePhoneCall(user.phone!)
                  : null,
            ),

            // Message d'info
            if (user.infoMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (user.isPhoneVisible == true || user.isEmailVisible == true)
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      (user.isPhoneVisible == true || user.isEmailVisible == true)
                          ? Icons.check_circle
                          : Icons.info,
                      color: (user.isPhoneVisible == true || user.isEmailVisible == true)
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.infoMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: (user.isPhoneVisible == true || user.isEmailVisible == true)
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isVisible,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isVisible ? onTap : null,
      child: Row(
        children: [
          Icon(
            icon,
            color: isVisible ? AppTheme.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isVisible ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (!isVisible) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isVisible && onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}

