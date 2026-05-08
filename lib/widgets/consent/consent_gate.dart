import 'package:flutter/material.dart';

import '../../services/consent_service.dart';
import '../../views/consent/consent_screen.dart';

class ConsentGate extends StatefulWidget {
  final Widget child;

  const ConsentGate({super.key, required this.child});

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  ConsentState? _consent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final consent = await ConsentService.getConsent();
    if (!mounted) return;
    setState(() {
      _consent = consent;
      _loading = false;
    });
  }

  void _onDecided() {
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.child;
    }
    if (_consent == null) {
      return ConsentScreen(onDecided: _onDecided);
    }
    return widget.child;
  }
}

