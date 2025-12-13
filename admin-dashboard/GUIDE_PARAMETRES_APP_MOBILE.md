# Guide d'implémentation des paramètres du Dashboard dans l'Application Mobile Flutter

**Date:** 12 Décembre 2025  
**Projet:** Auxivie - Application mobile Flutter  
**Objectif:** Synchroniser les paramètres configurés dans le dashboard admin avec l'application mobile

---

## 📋 Vue d'ensemble

Le dashboard admin permet de configurer 6 catégories de paramètres qui doivent être synchronisés avec l'application mobile Flutter :

1. **Général** - Paramètres financiers et de réservation
2. **Paiements** - Configuration Stripe
3. **Notifications** - Emails et SMS
4. **Sécurité** - Authentification et sessions
5. **Admins** - (Non applicable à l'app mobile)
6. **Système** - Mode maintenance et debug

---

## 🔧 1. Paramètres Généraux

### 1.1 Paramètres financiers

#### `platformFee` (Commission de plateforme)
- **Type:** `double` (0-100%)
- **Valeur actuelle:** `15%`
- **Utilisation mobile:**
  - Afficher dans l'écran de détail de réservation
  - Calculer le montant total avec commission
  - Afficher la répartition des frais avant paiement

**Implémentation Flutter:**
```dart
// lib/models/app_settings.dart
class AppSettings {
  final double platformFee;
  
  double calculateTotal(double basePrice) {
    return basePrice * (1 + platformFee / 100);
  }
  
  double calculateFeeAmount(double basePrice) {
    return basePrice * (platformFee / 100);
  }
}

// lib/screens/reservation_summary_screen.dart
Widget buildPriceBreakdown(Reservation reservation) {
  final settings = Provider.of<AppSettings>(context);
  final basePrice = reservation.totalPrice;
  final fee = settings.calculateFeeAmount(basePrice);
  final total = settings.calculateTotal(basePrice);
  
  return Column(
    children: [
      PriceRow(label: 'Prix de base', amount: basePrice),
      PriceRow(label: 'Frais de service (${settings.platformFee}%)', amount: fee),
      Divider(),
      PriceRow(label: 'Total', amount: total, bold: true),
    ],
  );
}
```

### 1.2 Paramètres de réservation

#### `cancellationDelay` (Délai d'annulation)
- **Type:** `int` (heures)
- **Valeur actuelle:** `24 heures`
- **Utilisation mobile:**
  - Afficher le délai dans les conditions d'annulation
  - Calculer si l'annulation sans frais est possible
  - Afficher un timer/compte à rebours

**Implémentation Flutter:**
```dart
// lib/services/reservation_service.dart
class ReservationService {
  final AppSettings settings;
  
  bool canCancelFree(DateTime reservationStart) {
    final now = DateTime.now();
    final hoursUntilStart = reservationStart.difference(now).inHours;
    return hoursUntilStart >= settings.cancellationDelay;
  }
  
  String getCancellationPolicyText() {
    return 'Annulation gratuite jusqu\'à ${settings.cancellationDelay}h avant le début';
  }
}

// lib/screens/reservation_detail_screen.dart
Widget buildCancellationInfo() {
  final canCancel = reservationService.canCancelFree(reservation.startTime);
  
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: canCancel ? Colors.green[50] : Colors.orange[50],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(canCancel ? Icons.check_circle : Icons.warning, 
             color: canCancel ? Colors.green : Colors.orange),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            reservationService.getCancellationPolicyText(),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
```

#### `minReservationHours` et `maxReservationHours`
- **Type:** `int` (heures)
- **Valeurs actuelles:** `min: 2h`, `max: 24h`
- **Utilisation mobile:**
  - Validation lors de la création de réservation
  - Limiter le sélecteur de durée
  - Afficher les contraintes à l'utilisateur

**Implémentation Flutter:**
```dart
// lib/widgets/duration_picker.dart
class DurationPicker extends StatelessWidget {
  final AppSettings settings;
  final int selectedHours;
  final Function(int) onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Durée de la réservation'),
        Text(
          'Entre ${settings.minReservationHours}h et ${settings.maxReservationHours}h',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Slider(
          min: settings.minReservationHours.toDouble(),
          max: settings.maxReservationHours.toDouble(),
          value: selectedHours.toDouble(),
          divisions: settings.maxReservationHours - settings.minReservationHours,
          onChanged: (value) => onChanged(value.toInt()),
          label: '${selectedHours}h',
        ),
      ],
    );
  }
}

// Validation
String? validateReservationDuration(int hours) {
  if (hours < settings.minReservationHours) {
    return 'Durée minimale: ${settings.minReservationHours}h';
  }
  if (hours > settings.maxReservationHours) {
    return 'Durée maximale: ${settings.maxReservationHours}h';
  }
  return null;
}
```

### 1.3 Contact

#### `contactEmail` et `supportPhone`
- **Valeurs actuelles:** `contact@auxivie.org`, `+33 6 52 24 85 94`
- **Utilisation mobile:**
  - Écran "Aide & Support"
  - Boutons de contact direct (email, téléphone)
  - Page "À propos"

**Implémentation Flutter:**
```dart
// lib/screens/support_screen.dart
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  final AppSettings settings;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.email, color: Colors.blue),
            title: Text('Email'),
            subtitle: Text(settings.contactEmail),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchEmail(settings.contactEmail),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.green),
            title: Text('Téléphone'),
            subtitle: Text(settings.supportPhone),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchPhone(settings.supportPhone),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Support Auxivie'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
  
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
```

---

## 💳 2. Paiements Stripe

### Configuration des clés Stripe

#### Paramètres disponibles:
- **Mode:** `stripeMode` → `'test'` ou `'production'`
- **Clés Test:** `stripePublicKeyTest`, `stripeSecretKeyTest`
- **Clés Prod:** `stripePublicKeyProd`, `stripeSecretKeyProd`
- **Valeurs actuelles:** Mode `production` avec clés live

**Implémentation Flutter:**
```dart
// pubspec.yaml
dependencies:
  flutter_stripe: ^10.0.0

// lib/services/stripe_service.dart
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  final AppSettings settings;
  
  Future<void> initialize() async {
    // Sélectionner la clé selon le mode
    final publishableKey = settings.stripeMode == 'production'
        ? settings.stripePublicKeyProd
        : settings.stripePublicKeyTest;
    
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
  
  Future<PaymentIntent> createPaymentIntent(double amount) async {
    // Utiliser la clé secrète appropriée
    final secretKey = settings.stripeMode == 'production'
        ? settings.stripeSecretKeyProd
        : settings.stripeSecretKeyTest;
    
    // Appeler votre backend qui utilisera la clé secrète
    final response = await http.post(
      Uri.parse('https://auxivie.org/api/create-payment-intent'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': (amount * 100).toInt(), // Convertir en centimes
        'currency': 'eur',
      }),
    );
    
    return PaymentIntent.fromJson(jsonDecode(response.body));
  }
  
  Future<bool> processPayment(String paymentIntentId) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentId,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      return true;
    } catch (e) {
      print('Erreur paiement: $e');
      return false;
    }
  }
}

// lib/screens/payment_screen.dart
class PaymentScreen extends StatefulWidget {
  final Reservation reservation;
  
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }
  
  Future<void> _initializeStripe() async {
    final stripeService = Provider.of<StripeService>(context, listen: false);
    await stripeService.initialize();
  }
  
  Future<void> _handlePayment() async {
    setState(() => isProcessing = true);
    
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final stripeService = Provider.of<StripeService>(context, listen: false);
      
      // Calculer le montant total avec frais
      final total = settings.calculateTotal(widget.reservation.basePrice);
      
      // Créer le Payment Intent
      final paymentIntent = await stripeService.createPaymentIntent(total);
      
      // Confirmer le paiement
      final success = await stripeService.processPayment(
        paymentIntent.clientSecret,
      );
      
      if (success) {
        // Naviguer vers la confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(reservation: widget.reservation),
          ),
        );
      } else {
        _showErrorDialog('Le paiement a échoué');
      }
    } catch (e) {
      _showErrorDialog('Erreur: ${e.toString()}');
    } finally {
      setState(() => isProcessing = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paiement')),
      body: Column(
        children: [
          CardField(
            onCardChanged: (card) {
              // Gérer les changements de carte
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isProcessing ? null : _handlePayment,
            child: isProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Payer ${settings.calculateTotal(widget.reservation.basePrice)}€'),
          ),
        ],
      ),
    );
  }
}
```

**⚠️ Important - Sécurité:**
- **NE JAMAIS** stocker les clés secrètes Stripe dans l'app mobile
- Les clés secrètes doivent rester uniquement sur le backend
- L'app mobile utilise uniquement les clés publiques (`publishableKey`)
- Tous les appels sensibles (création PaymentIntent) passent par le backend

---

## 🔔 3. Notifications

### 3.1 Email et SMS

#### Paramètres:
- `sendEmailNotifications` → `true`
- `sendSMSNotifications` → `false`
- SMTP configuré: `smtp.hostinger.com:587`

**Implémentation Flutter:**
```dart
// lib/models/notification_preferences.dart
class NotificationPreferences {
  bool emailEnabled;
  bool smsEnabled;
  bool pushEnabled;
  
  NotificationPreferences({
    required this.emailEnabled,
    required this.smsEnabled,
    this.pushEnabled = true,
  });
  
  factory NotificationPreferences.fromSettings(AppSettings settings) {
    return NotificationPreferences(
      emailEnabled: settings.sendEmailNotifications,
      smsEnabled: settings.sendSMSNotifications,
    );
  }
}

// lib/screens/notification_settings_screen.dart
class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationPreferences prefs;
  
  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    prefs = NotificationPreferences.fromSettings(settings);
  }
  
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          // Email - Géré par le paramètre global
          SwitchListTile(
            title: Text('Notifications par email'),
            subtitle: Text(
              settings.sendEmailNotifications
                  ? 'Activées par l\'administrateur'
                  : 'Désactivées par l\'administrateur',
            ),
            value: prefs.emailEnabled && settings.sendEmailNotifications,
            onChanged: settings.sendEmailNotifications
                ? (value) {
                    setState(() => prefs.emailEnabled = value);
                    _savePreferences();
                  }
                : null, // Désactivé si l'admin a désactivé
          ),
          
          // SMS - Géré par le paramètre global
          SwitchListTile(
            title: Text('Notifications par SMS'),
            subtitle: Text(
              settings.sendSMSNotifications
                  ? 'Activées par l\'administrateur'
                  : 'Désactivées par l\'administrateur',
            ),
            value: prefs.smsEnabled && settings.sendSMSNotifications,
            onChanged: settings.sendSMSNotifications
                ? (value) {
                    setState(() => prefs.smsEnabled = value);
                    _savePreferences();
                  }
                : null,
          ),
          
          // Push - Toujours disponible
          SwitchListTile(
            title: Text('Notifications push'),
            subtitle: Text('Notifications dans l\'application'),
            value: prefs.pushEnabled,
            onChanged: (value) {
              setState(() => prefs.pushEnabled = value);
              _savePreferences();
            },
          ),
          
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Les notifications email et SMS sont contrôlées par l\'administrateur. '
              'Vous pouvez les désactiver pour votre compte uniquement.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', this.prefs.emailEnabled);
    await prefs.setBool('sms_notifications', this.prefs.smsEnabled);
    await prefs.setBool('push_notifications', this.prefs.pushEnabled);
  }
}
```

### 3.2 Approbation automatique des documents

#### `autoApproveDocuments`
- **Valeur actuelle:** `false`
- **Utilisation mobile:**
  - Afficher le statut de vérification des documents
  - Informer l'utilisateur du délai de validation

**Implémentation Flutter:**
```dart
// lib/screens/document_upload_screen.dart
class DocumentUploadScreen extends StatelessWidget {
  final AppSettings settings;
  
  Widget buildApprovalInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settings.autoApproveDocuments ? Colors.blue[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: settings.autoApproveDocuments ? Colors.blue : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            settings.autoApproveDocuments ? Icons.check_circle : Icons.schedule,
            color: settings.autoApproveDocuments ? Colors.blue : Colors.orange,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              settings.autoApproveDocuments
                  ? 'Vos documents seront approuvés automatiquement'
                  : 'Vos documents seront vérifiés sous 24-48h',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔒 4. Sécurité

### 4.1 Tentatives de connexion

#### Paramètres:
- `maxLoginAttempts` → `5`
- `lockoutDuration` → `30 minutes`

**Implémentation Flutter:**
```dart
// lib/services/auth_service.dart
class AuthService {
  final AppSettings settings;
  int loginAttempts = 0;
  DateTime? lockoutUntil;
  
  Future<bool> login(String email, String password) async {
    // Vérifier si le compte est verrouillé
    if (isLockedOut()) {
      final remainingMinutes = getRemainingLockoutMinutes();
      throw Exception(
        'Compte temporairement verrouillé. '
        'Réessayez dans $remainingMinutes minutes.'
      );
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://auxivie.org/api/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        // Succès - Réinitialiser les tentatives
        loginAttempts = 0;
        lockoutUntil = null;
        
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return true;
      } else {
        // Échec - Incrémenter les tentatives
        loginAttempts++;
        
        if (loginAttempts >= settings.maxLoginAttempts) {
          // Verrouiller le compte
          lockoutUntil = DateTime.now().add(
            Duration(minutes: settings.lockoutDuration),
          );
          throw Exception(
            'Trop de tentatives échouées. '
            'Compte verrouillé pendant ${settings.lockoutDuration} minutes.'
          );
        } else {
          final remaining = settings.maxLoginAttempts - loginAttempts;
          throw Exception(
            'Email ou mot de passe incorrect. '
            '$remaining tentative(s) restante(s).'
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  
  bool isLockedOut() {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }
  
  int getRemainingLockoutMinutes() {
    if (lockoutUntil == null) return 0;
    final remaining = lockoutUntil!.difference(DateTime.now());
    return remaining.inMinutes + 1;
  }
}

// lib/screens/login_screen.dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Message d'erreur avec compteur
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            
            // Indicateur de verrouillage
            if (authService.isLockedOut())
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Compte verrouillé pendant ${authService.getRemainingLockoutMinutes()} min',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: !authService.isLockedOut() && !_isLoading,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              enabled: !authService.isLockedOut() && !_isLoading,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: (!authService.isLockedOut() && !_isLoading)
                  ? _handleLogin
                  : null,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.2 Timeout de session

#### `sessionTimeout` → `24 heures`

**Implémentation Flutter:**
```dart
// lib/services/session_service.dart
class SessionService {
  final AppSettings settings;
  DateTime? lastActivity;
  Timer? _sessionTimer;
  
  void startSession() {
    lastActivity = DateTime.now();
    _startSessionTimer();
  }
  
  void updateActivity() {
    lastActivity = DateTime.now();
  }
  
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (isSessionExpired()) {
        _handleSessionExpired();
      }
    });
  }
  
  bool isSessionExpired() {
    if (lastActivity == null) return true;
    
    final elapsed = DateTime.now().difference(lastActivity!);
    final timeoutDuration = Duration(hours: settings.sessionTimeout);
    
    return elapsed > timeoutDuration;
  }
  
  void _handleSessionExpired() {
    _sessionTimer?.cancel();
    // Déconnecter l'utilisateur
    _logout();
  }
  
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Rediriger vers login
  }
  
  void dispose() {
    _sessionTimer?.cancel();
  }
}

// Dans main.dart ou dans un wrapper global
class SessionWrapper extends StatefulWidget {
  final Widget child;
  
  @override
  _SessionWrapperState createState() => _SessionWrapperState();
}

class _SessionWrapperState extends State<SessionWrapper> with WidgetsBindingObserver {
  late SessionService sessionService;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.startSession();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App revenue au premier plan
      if (sessionService.isSessionExpired()) {
        _showSessionExpiredDialog();
      } else {
        sessionService.updateActivity();
      }
    }
  }
  
  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Session expirée'),
        content: Text(
          'Votre session a expiré après ${sessionService.settings.sessionTimeout}h d\'inactivité. '
          'Veuillez vous reconnecter.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Se reconnecter'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sessionService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => sessionService.updateActivity(),
      onPanDown: (_) => sessionService.updateActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
```

### 4.3 Authentification à deux facteurs (2FA)

#### `require2FA` → `false`

**Implémentation Flutter (préparation):**
```dart
// lib/screens/two_factor_screen.dart
class TwoFactorScreen extends StatefulWidget {
  final String email;
  
  @override
  _TwoFactorScreenState createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _codeController = TextEditingController();
  
  Future<void> _verifyCode() async {
    final response = await http.post(
      Uri.parse('https://auxivie.org/api/verify-2fa'),
      body: jsonEncode({
        'email': widget.email,
        'code': _codeController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      _showError('Code incorrect');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    
    // N'afficher que si 2FA est activé
    if (!settings.require2FA) {
      return Container(); // Ou rediriger directement
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Vérification en 2 étapes')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Un code de vérification a été envoyé à ${widget.email}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de vérification',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyCode,
              child: Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🖥️ 5. Système

### 5.1 Mode maintenance

#### `maintenanceMode` → `false`

**Implémentation Flutter:**
```dart
// lib/main.dart ou app wrapper
class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppSettings? settings;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final response = await http.get(
        Uri.parse('https://auxivie.org/api/settings'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          settings = AppSettings.fromJson(data);
          isLoading = false;
        });
      }
    } catch (e) {
      // En cas d'erreur, utiliser les paramètres par défaut
      setState(() {
        settings = AppSettings.defaults();
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // Vérifier le mode maintenance
    if (settings!.maintenanceMode) {
      return MaterialApp(
        home: MaintenanceScreen(),
      );
    }
    
    return MultiProvider(
      providers: [
        Provider<AppSettings>.value(value: settings!),
        // Autres providers...
      ],
      child: MaterialApp(
        home: LoginScreen(),
        // Routes, etc.
      ),
    );
  }
}

// lib/screens/maintenance_screen.dart
class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 120,
                color: Colors.orange,
              ),
              SizedBox(height: 32),
              Text(
                'Maintenance en cours',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Nous effectuons actuellement une maintenance. '
                'L\'application sera de nouveau disponible très bientôt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Recharger l'app pour vérifier si la maintenance est terminée
                  RestartWidget.restartApp(context);
                },
                icon: Icon(Icons.refresh),
                label: Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5.2 Mode debug

#### `debugMode` → `false`

**Implémentation Flutter:**
```dart
// lib/utils/logger.dart
class AppLogger {
  static AppSettings? _settings;
  
  static void init(AppSettings settings) {
    _settings = settings;
  }
  
  static void log(String message, {String? tag}) {
    if (_settings?.debugMode ?? false) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ${tag ?? 'APP'}: $message');
    }
  }
  
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_settings?.debugMode ?? false) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
  
  static void network(String url, {dynamic request, dynamic response}) {
    if (_settings?.debugMode ?? false) {
      print('=== NETWORK REQUEST ===');
      print('URL: $url');
      if (request != null) print('Request: $request');
      if (response != null) print('Response: $response');
      print('=======================');
    }
  }
}

// Utilisation dans l'app
void someFunction() {
  AppLogger.log('Fonction appelée', tag: 'HOME');
  
  try {
    // Code...
  } catch (e, stackTrace) {
    AppLogger.error('Erreur dans someFunction', error: e, stackTrace: stackTrace);
  }
}

// Dans les appels API
Future<Response> apiCall(String endpoint) async {
  final url = 'https://auxivie.org/api/$endpoint';
  AppLogger.network(url);
  
  final response = await http.get(Uri.parse(url));
  
  AppLogger.network(url, response: response.body);
  return response;
}
```

---

## 📡 6. API Backend - Récupération des paramètres

### Endpoint à créer sur le backend

```javascript
// backend/server.js

// GET /api/settings - Récupérer les paramètres publics
app.get('/api/settings', (req, res) => {
  // Ne retourner que les paramètres non-sensibles
  const publicSettings = {
    // Général
    platformFee: 15,
    cancellationDelay: 24,
    contactEmail: process.env.SMTP_USER || 'contact@auxivie.org',
    supportPhone: '+33 6 52 24 85 94',
    minReservationHours: 2,
    maxReservationHours: 24,
    
    // Paiements (clés publiques uniquement!)
    stripePublicKey: process.env.STRIPE_MODE === 'production'
      ? process.env.STRIPE_PUBLIC_KEY_PROD
      : process.env.STRIPE_PUBLIC_KEY_TEST,
    stripeMode: process.env.STRIPE_MODE || 'test',
    
    // Notifications
    sendEmailNotifications: true,
    sendSMSNotifications: false,
    autoApproveDocuments: false,
    
    // Sécurité
    maxLoginAttempts: 5,
    lockoutDuration: 30,
    sessionTimeout: 24,
    require2FA: false,
    
    // Système
    maintenanceMode: false,
    debugMode: false,
  };
  
  res.json(publicSettings);
});

// NE JAMAIS exposer les clés secrètes Stripe ou les mots de passe SMTP!
```

### Appel depuis Flutter

```dart
// lib/services/settings_service.dart
class SettingsService {
  static const String baseUrl = 'https://auxivie.org/api';
  
  Future<AppSettings> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppSettings.fromJson(data);
      } else {
        throw Exception('Erreur lors du chargement des paramètres');
      }
    } catch (e) {
      print('Erreur: $e');
      // Retourner des paramètres par défaut en cas d'erreur
      return AppSettings.defaults();
    }
  }
  
  // Rafraîchir les paramètres périodiquement
  Stream<AppSettings> watchSettings({Duration interval = const Duration(hours: 1)}) {
    return Stream.periodic(interval, (_) => fetchSettings()).asyncMap((future) => future);
  }
}

// lib/models/app_settings.dart
class AppSettings {
  final double platformFee;
  final int cancellationDelay;
  final String contactEmail;
  final String supportPhone;
  final int minReservationHours;
  final int maxReservationHours;
  final String stripePublicKey;
  final String stripeMode;
  final bool sendEmailNotifications;
  final bool sendSMSNotifications;
  final bool autoApproveDocuments;
  final int maxLoginAttempts;
  final int lockoutDuration;
  final int sessionTimeout;
  final bool require2FA;
  final bool maintenanceMode;
  final bool debugMode;
  
  AppSettings({
    required this.platformFee,
    required this.cancellationDelay,
    required this.contactEmail,
    required this.supportPhone,
    required this.minReservationHours,
    required this.maxReservationHours,
    required this.stripePublicKey,
    required this.stripeMode,
    required this.sendEmailNotifications,
    required this.sendSMSNotifications,
    required this.autoApproveDocuments,
    required this.maxLoginAttempts,
    required this.lockoutDuration,
    required this.sessionTimeout,
    required this.require2FA,
    required this.maintenanceMode,
    required this.debugMode,
  });
  
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      platformFee: (json['platformFee'] ?? 15).toDouble(),
      cancellationDelay: json['cancellationDelay'] ?? 24,
      contactEmail: json['contactEmail'] ?? 'contact@auxivie.org',
      supportPhone: json['supportPhone'] ?? '+33 6 52 24 85 94',
      minReservationHours: json['minReservationHours'] ?? 2,
      maxReservationHours: json['maxReservationHours'] ?? 24,
      stripePublicKey: json['stripePublicKey'] ?? '',
      stripeMode: json['stripeMode'] ?? 'test',
      sendEmailNotifications: json['sendEmailNotifications'] ?? true,
      sendSMSNotifications: json['sendSMSNotifications'] ?? false,
      autoApproveDocuments: json['autoApproveDocuments'] ?? false,
      maxLoginAttempts: json['maxLoginAttempts'] ?? 5,
      lockoutDuration: json['lockoutDuration'] ?? 30,
      sessionTimeout: json['sessionTimeout'] ?? 24,
      require2FA: json['require2FA'] ?? false,
      maintenanceMode: json['maintenanceMode'] ?? false,
      debugMode: json['debugMode'] ?? false,
    );
  }
  
  factory AppSettings.defaults() {
    return AppSettings(
      platformFee: 15,
      cancellationDelay: 24,
      contactEmail: 'contact@auxivie.org',
      supportPhone: '+33 6 52 24 85 94',
      minReservationHours: 2,
      maxReservationHours: 24,
      stripePublicKey: '',
      stripeMode: 'test',
      sendEmailNotifications: true,
      sendSMSNotifications: false,
      autoApproveDocuments: false,
      maxLoginAttempts: 5,
      lockoutDuration: 30,
      sessionTimeout: 24,
      require2FA: false,
      maintenanceMode: false,
      debugMode: false,
    );
  }
}
```

---

## 📦 Dépendances Flutter requises

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  http: ^1.1.0
  
  # State Management
  provider: ^6.1.1
  
  # Stockage local
  shared_preferences: ^2.2.2
  
  # Paiements Stripe
  flutter_stripe: ^10.0.0
  
  # URL Launcher (email, téléphone)
  url_launcher: ^6.2.2
  
  # Notifications push (optionnel)
  firebase_messaging: ^14.7.9
  
  # Gestion de session
  # (Timer et DateTime sont natifs)
```

---

## 🔄 Synchronisation et mise à jour

### Stratégie de rafraîchissement

```dart
// lib/providers/settings_provider.dart
class SettingsProvider with ChangeNotifier {
  AppSettings? _settings;
  final SettingsService _service = SettingsService();
  Timer? _refreshTimer;
  
  AppSettings? get settings => _settings;
  bool get isLoaded => _settings != null;
  
  Future<void> initialize() async {
    await loadSettings();
    _startAutoRefresh();
  }
  
  Future<void> loadSettings() async {
    try {
      _settings = await _service.fetchSettings();
      notifyListeners();
    } catch (e) {
      print('Erreur chargement paramètres: $e');
    }
  }
  
  void _startAutoRefresh() {
    // Rafraîchir toutes les heures
    _refreshTimer = Timer.periodic(Duration(hours: 1), (_) {
      loadSettings();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// Dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ProxyProvider<SettingsProvider, AuthService>(
          update: (_, settings, __) => AuthService(settings.settings!),
        ),
        // Autres providers...
      ],
      child: MyApp(),
    ),
  );
}
```

---

## ✅ Checklist d'implémentation

### Phase 1: Configuration de base
- [ ] Créer le modèle `AppSettings`
- [ ] Créer le service `SettingsService`
- [ ] Implémenter l'endpoint backend `/api/settings`
- [ ] Tester la récupération des paramètres
- [ ] Configurer le Provider pour les paramètres globaux

### Phase 2: Paramètres généraux
- [ ] Implémenter le calcul des frais de plateforme
- [ ] Ajouter la validation des durées de réservation
- [ ] Intégrer les délais d'annulation
- [ ] Créer l'écran de support avec contact email/téléphone

### Phase 3: Paiements Stripe
- [ ] Intégrer `flutter_stripe`
- [ ] Configurer les clés publiques selon le mode (test/prod)
- [ ] Implémenter le flow de paiement
- [ ] Tester en mode test puis production

### Phase 4: Notifications
- [ ] Créer l'écran des préférences de notifications
- [ ] Implémenter la logique d'activation/désactivation selon les paramètres admin
- [ ] Afficher le statut d'approbation des documents

### Phase 5: Sécurité
- [ ] Implémenter le compteur de tentatives de connexion
- [ ] Ajouter le système de verrouillage temporaire
- [ ] Créer le gestionnaire de session avec timeout
- [ ] Préparer l'interface 2FA (pour activation future)

### Phase 6: Système
- [ ] Implémenter l'écran de maintenance
- [ ] Configurer le logger avec mode debug
- [ ] Tester le mode maintenance

### Phase 7: Tests et validation
- [ ] Tester tous les paramètres avec différentes valeurs
- [ ] Vérifier le comportement en cas d'échec réseau
- [ ] Valider les paramètres par défaut
- [ ] Tester le rafraîchissement automatique

---

## 🔐 Sécurité - Points critiques

### ⚠️ À NE JAMAIS FAIRE:
1. **Stocker les clés secrètes Stripe dans l'app mobile**
2. **Exposer les mots de passe SMTP côté client**
3. **Faire confiance aux paramètres client uniquement** (toujours valider côté serveur)
4. **Stocker les tokens sans chiffrement**

### ✅ Bonnes pratiques:
1. **Toujours utiliser HTTPS** pour les appels API
2. **Valider tous les paramètres côté backend** avant traitement
3. **Stocker les tokens dans un stockage sécurisé** (flutter_secure_storage)
4. **Implémenter un système de cache** pour réduire les appels API
5. **Gérer les erreurs réseau** avec des valeurs par défaut raisonnables

---

## 📞 Support et questions

Pour toute question sur l'implémentation:
- **Email:** contact@auxivie.org
- **Téléphone:** +33 6 52 24 85 94

---

**Dernière mise à jour:** 12 Décembre 2025
