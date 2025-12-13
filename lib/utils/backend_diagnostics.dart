import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/backend_api_service.dart';

/// Utilitaire de diagnostic pour tester la connexion au backend
class BackendDiagnostics {
  /// Teste la connexion de base au backend
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{
      'baseUrl': AppConfig.apiBaseUrl,
      'environment': AppConfig.currentEnvironment.toString(),
      'tests': <String, dynamic>{},
    };

    // Test 1: Health endpoint
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/health'),
      ).timeout(const Duration(seconds: 10));
      
      results['tests']['health'] = {
        'status': response.statusCode,
        'success': response.statusCode == 200,
        'body': response.body,
      };
    } catch (e) {
      results['tests']['health'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    // Test 2: Settings endpoint (sans auth)
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/settings'),
      ).timeout(const Duration(seconds: 10));
      
      results['tests']['settings'] = {
        'status': response.statusCode,
        'success': response.statusCode == 200 || response.statusCode == 401,
        'body': response.statusCode == 200 ? 'OK' : 'Requires auth',
      };
    } catch (e) {
      results['tests']['settings'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    // Test 3: Token check
    try {
      final token = await BackendApiService.getToken();
      results['tests']['token'] = {
        'hasToken': token != null,
        'tokenLength': token?.length ?? 0,
        'tokenPreview': token != null ? '${token.substring(0, 20)}...' : 'No token',
      };
    } catch (e) {
      results['tests']['token'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    return results;
  }

  /// Affiche un dialogue de diagnostic
  static Future<void> showDiagnosticsDialog(BuildContext context) async {
    final results = await testConnection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Diagnostic Backend'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiagnosticRow('URL Base', results['baseUrl']),
              _buildDiagnosticRow('Environnement', results['environment']),
              const SizedBox(height: 16),
              const Text('Tests:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._buildTestResults(results['tests'] as Map<String, dynamic>),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDiagnosticRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildTestResults(Map<String, dynamic> tests) {
    return tests.entries.map((entry) {
      final test = entry.value as Map<String, dynamic>;
      final isSuccess = test['success'] == true;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (test.containsKey('status'))
                    Text('Status: ${test['status']}', style: const TextStyle(fontSize: 12)),
                  if (test.containsKey('error'))
                    Text('Error: ${test['error']}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                  if (test.containsKey('body'))
                    Text('Response: ${test['body']}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

