import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../models/document_model.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'edit_phone_screen.dart';
import 'edit_email_screen.dart';
import 'edit_password_screen.dart';
import 'edit_tarif_screen.dart';
import 'edit_rib_screen.dart';
import 'edit_country_screen.dart';
import 'edit_language_screen.dart';
import 'legal_info_screen.dart';
import 'edit_personal_info_screen.dart';
import 'family_members_screen.dart';
import 'my_reports_screen.dart';
import '../support/support_screen.dart';
import '../../services/consent_service.dart';
import '../consent/consent_screen.dart';
import '../auth/choice_screen.dart';

/// Page Profile modernisée, intégrée à BackendApiService + Provider
/// - Thème dégradé vert
/// - 7 sections demandées
/// - Chargement réel du user par userId
/// - Vérifications `mounted` avant setState

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villeController = TextEditingController();
  final _tarifController = TextEditingController();
  final _experienceController = TextEditingController();

  UserModel? _user;
  bool _isLoading = true;

  /// Une seule requête réseau tant qu’on ne force pas un rafraîchissement (évite N appels à /reports/my à chaque rebuild).
  Future<int>? _openReportsCountFuture;

  final ImagePicker _picker = ImagePicker();
  List<DocumentModel> _docsIdentite = [];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _loadUser();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _villeController.dispose();
    _tarifController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      // Charger depuis le backend (base de données unique)
      final u = await BackendApiService.getUserById(widget.userId);
      if (!mounted) return;

      setState(() {
        _user = u;
        if (u != null) {
          _nameController.text = u.name;
          _emailController.text = u.email;
          _phoneController.text = u.phone ?? '';
          _villeController.text = u.ville ?? '';
          _tarifController.text = u.tarif?.toStringAsFixed(2) ?? '';
          _experienceController.text = u.experience?.toString() ?? '';
          _openReportsCountFuture = _getOpenReportsCount();
        } else {
          _openReportsCountFuture = null;
        }
        _isLoading = false;
      });

      await _loadDocuments();

      if (mounted) _animCtrl.forward();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    try {
      final documents = await BackendApiService.getDocuments(widget.userId);
      if (!mounted) return;
      setState(() {
        _docsIdentite = documents.where((doc) => doc.type == 'identity').toList();
      });
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur lors du chargement des documents: $e');
      }
      if (!mounted) return;
      setState(() {
        _docsIdentite = [];
      });
    }
  }


  Future<void> _addDocument(String type) async {
    // Show modal with options then add document
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ajouter un document',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded,
                      color: AppTheme.accent),
                  title: const Text('Prendre une photo'),
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    final picked = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (picked == null) return;
                    
                    // Afficher un indicateur de chargement
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    // Vérifier que le fichier existe avant l'upload
                    final file = File(picked.path);
                    if (!await file.exists()) {
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Fermer le dialog de chargement
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Le fichier sélectionné n\'est plus accessible. Veuillez réessayer.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ));
                      return;
                    }
                    
                    // Uploader vers le backend
                    final result = await BackendApiService.uploadDocument(
                      userId: widget.userId,
                      type: type,
                      file: file,
                    );
                    
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Fermer le dialog de chargement
                    
                    if (result != null) {
                      // Le document est déjà enregistré sur le backend
                      await _loadDocuments();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Document uploadé avec succès')));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de l\'upload du document. Veuillez réessayer.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppTheme.accent),
                  title: const Text('Depuis la galerie'),
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    final picked = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (picked == null) return;
                    
                    // Afficher un indicateur de chargement
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    // Vérifier que le fichier existe avant l'upload
                    final file = File(picked.path);
                    if (!await file.exists()) {
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Fermer le dialog de chargement
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Le fichier sélectionné n\'est plus accessible. Veuillez réessayer.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ));
                      return;
                    }
                    
                    // Uploader vers le backend
                    final result = await BackendApiService.uploadDocument(
                      userId: widget.userId,
                      type: type,
                      file: file,
                    );
                    
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Fermer le dialog de chargement
                    
                    if (result != null) {
                      // Le document est déjà enregistré sur le backend
                      await _loadDocuments();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Document uploadé avec succès')));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de l\'upload du document. Veuillez réessayer.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded,
                      color: Color.fromARGB(255, 43, 54, 29)),
                  title: const Text('Importer un fichier (PDF, images)'),
                  subtitle: const Text('Sélectionnez un PDF ou une image', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    
                    try {
                      // Utiliser file_picker pour sélectionner PDF ou images
                      // Essayer d'abord avec FileType.any pour une meilleure compatibilité
                      FilePickerResult? result;
                      
                      const allowedExtensions = <String>{'pdf', 'jpg', 'jpeg', 'png'};
                      try {
                        // Essayer avec FileType.any (plus compatible)
                        result = await FilePicker.pickFiles(
                          type: FileType.any,
                          allowMultiple: false,
                        );
                      } catch (e) {
                        // Si FileType.any ne fonctionne pas, essayer FileType.custom
                        if (AppConfig.enableLogging) {
                          print('⚠️ [FILE PICKER] FileType.any a échoué, essai avec FileType.custom: $e');
                        }
                        result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: allowedExtensions.toList(),
                          allowMultiple: false,
                        );
                      }
                      
                      if (result == null || result.files.single.path == null) return;
                      
                      final filePath = result.files.single.path!;
                      final file = File(filePath);
                      final filename = result.files.single.name;
                      final dotIndex = filename.lastIndexOf('.');
                      final extension = dotIndex == -1
                          ? ''
                          : filename.substring(dotIndex + 1).toLowerCase();

                      if (!allowedExtensions.contains(extension)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Format non supporté. Utilisez un PDF, JPG, JPEG ou PNG.',
                            ),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      // Vérifier que le fichier existe et est accessible
                      if (!await file.exists()) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le fichier sélectionné n\'est plus accessible. Veuillez réessayer.'),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ));
                        return;
                      }
                      
                      // Vérifier que le fichier peut être lu
                      try {
                        final testBytes = await file.readAsBytes();
                        if (testBytes.isEmpty) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Le fichier sélectionné est vide. Veuillez choisir un autre fichier.'),
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.red,
                              ));
                          return;
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Impossible d\'accéder au fichier. Erreur: ${e.toString()}'),
                              duration: const Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ));
                        return;
                      }
                      
                      // Afficher un indicateur de chargement
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );
                      
                      // Uploader vers le backend
                      final uploadResult = await BackendApiService.uploadDocument(
                        userId: widget.userId,
                        type: type,
                        file: file,
                      );
                      
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Fermer le dialog de chargement
                      
                      if (uploadResult != null) {
                        // Le document est déjà enregistré sur le backend
                        await _loadDocuments();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document uploadé avec succès')));
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erreur lors de l\'upload du document. Veuillez réessayer.'),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ));
                      }
                    } catch (e) {
                      // Fermer le dialog de chargement si ouvert
                      if (mounted) {
                        try {
                          Navigator.of(context).pop();
                        } catch (_) {
                          // Dialog peut ne pas être ouvert
                        }
                      }
                      
                      // Gérer l'erreur MissingPluginException
                      if (e.toString().contains('MissingPluginException') || 
                          e.toString().contains('filepicker') ||
                          e.toString().contains('Method not found')) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le sélecteur de fichiers nécessite un redémarrage complet de l\'application. Arrêtez l\'app et relancez-la.'),
                              duration: Duration(seconds: 7),
                              backgroundColor: Colors.orange,
                            ));
                        if (AppConfig.enableLogging) {
                          print('❌ [FILE PICKER] Erreur plugin: $e');
                          print('   Solution: Arrêter complètement l\'app et la relancer (pas juste hot reload)');
                          print('   Alternative: Utiliser "Depuis la galerie" pour les images');
                        }
                      } else {
                        if (!mounted) return;
                        final err = e.toString();
                        final preview = err.length > 100 ? '${err.substring(0, 100)}...' : err;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la sélection du fichier: $preview'),
                              duration: const Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ));
                        if (AppConfig.enableLogging) {
                          print('❌ [FILE PICKER] Erreur: $e');
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // result is only used to know if bottom sheet was closed via action
    return;
  }



  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: Offset(0, 3))
          ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(String title, IconData icon,
      {VoidCallback? onTap, Color? leadingColor, Widget? trailing}) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (leadingColor ?? AppTheme.primary).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: leadingColor ?? AppTheme.primary),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Future<int> _getOpenReportsCount() async {
    try {
      // Plus besoin de passer userId, le backend filtre automatiquement via le token JWT
      final reports = await BackendApiService.getMyReports();
      return reports.where((r) => r.status == 'open').length;
    } catch (e) {
      return 0;
    }
  }

  void _refreshOpenReportsBadge() {
    if (!mounted) return;
    setState(() {
      _openReportsCountFuture = _getOpenReportsCount();
    });
  }

  String _extractFirstName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join(' ');
    }
    return '';
  }
  
  /// Formate dateOfBirth (string) ou dateNaissance (DateTime) pour l'affichage
  String _formatDateOfBirth() {
    String? dateStr;
    
    // Priorité à dateOfBirth (string format YYYY-MM-DD)
    if (_user!.dateOfBirth != null && _user!.dateOfBirth!.isNotEmpty) {
      try {
        final dateTime = DateTime.tryParse(_user!.dateOfBirth!);
        if (dateTime != null) {
          dateStr = _formatDateSafe(dateTime);
        }
      } catch (e) {
        // Si le parsing échoue, essayer comme string direct
        dateStr = _user!.dateOfBirth;
      }
    }
    
    // Fallback sur dateNaissance (DateTime)
    if (dateStr == null && _user!.dateNaissance != null) {
      dateStr = _formatDateSafe(_user!.dateNaissance!);
    }
    
    return dateStr ?? 'Non renseignée';
  }

  String _formatDate(DateTime date) {
    try {
      // Vérifier que la date est valide
      if (date.year < 1900 || date.year > 2100) {
        return '${date.day}/${date.month}/${date.year}';
      }
      // Essayer avec la locale française
      try {
        return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
      } catch (e) {
        // Si la locale n'est pas disponible, utiliser le formatage simple
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      // Fallback ultime si le formatage échoue complètement
      try {
        return '${date.day}/${date.month}/${date.year}';
      } catch (_) {
        return 'Date invalide';
      }
    }
  }

  String _formatDateSafe(DateTime? date) {
    if (date == null) return 'Non renseignée';
    try {
      return _formatDate(date);
    } catch (e) {
      print('❌ [PROFILE] Erreur formatage date: $e');
      return 'Date invalide';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _openPreview(DocumentModel d) {
    final imageUrl = d.documentUrl ?? d.path;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && (imageUrl.startsWith('http') || imageUrl.startsWith('https'))
                  ? Image.network(imageUrl)
                  : imageUrl != null
                      ? Image.file(File(imageUrl))
                      : const Icon(Icons.description, size: 100),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Changer la photo de profil',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded,
                      color: AppTheme.accent),
                  title: const Text('Prendre une photo'),
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    final picked = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (picked == null) return;
                    
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    final file = File(picked.path);
                    final photoUrl = await BackendApiService.uploadProfilePhoto(
                      userId: widget.userId,
                      photo: file,
                    );
                    
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Fermer le dialog de chargement
                    
                    if (photoUrl != null) {
                      await _loadUser();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo de profil mise à jour')));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur lors de l\'upload de la photo')));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppTheme.accent),
                  title: const Text('Depuis la galerie'),
                  onTap: () async {
                    Navigator.of(context).pop(true);
                    final picked = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (picked == null) return;
                    
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    final file = File(picked.path);
                    final photoUrl = await BackendApiService.uploadProfilePhoto(
                      userId: widget.userId,
                      photo: file,
                    );
                    
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Fermer le dialog de chargement
                    
                    if (photoUrl != null) {
                      await _loadUser();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo de profil mise à jour')));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur lors de l\'upload de la photo')));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(
          body: Center(child: Text('Utilisateur introuvable')));
    }

    // ProfileScreen est dans un IndexedStack, donc il n'est pas dans la pile de navigation
    // Le bouton retour système ne devrait rien faire ici
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Ne rien faire - on est dans un IndexedStack, le retour est géré par le HomeScreen
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.heroGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                  _sectionTitle('Identité'),
                  _card([
                    if (_user != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo de profil
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                    backgroundImage: _user!.photo != null && _user!.photo!.isNotEmpty
                                        ? (_user!.photo!.startsWith('http')
                                            ? NetworkImage(_user!.photo!)
                                            : FileImage(File(_user!.photo!)) as ImageProvider)
                                        : null,
                                    child: _user!.photo == null || _user!.photo!.isEmpty
                                        ? const Icon(Icons.person, size: 50, color: AppTheme.primary)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                        onPressed: () => _uploadProfilePhoto(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ✅ Afficher firstName/lastName si disponibles, sinon extraire du name
                                      if (_user!.firstName != null && _user!.firstName!.isNotEmpty)
                                        _buildInfoRow('Prénom', _user!.firstName!),
                                      if (_user!.firstName != null && _user!.firstName!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (_user!.lastName != null && _user!.lastName!.isNotEmpty)
                                        _buildInfoRow('Nom', _user!.lastName!),
                                      if (_user!.lastName != null && _user!.lastName!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      // Si pas de firstName/lastName, utiliser l'ancienne méthode
                                      if ((_user!.firstName == null || _user!.firstName!.isEmpty) &&
                                          (_user!.lastName == null || _user!.lastName!.isEmpty)) ...[
                                        _buildInfoRow('Nom', _user!.name),
                                        const SizedBox(height: 12),
                                        _buildInfoRow('Prénom', _extractFirstName(_user!.name)),
                                        const SizedBox(height: 12),
                                      ],
                                      _buildInfoRow(
                                        'Date de naissance',
                                        _formatDateOfBirth(),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        'Âge',
                                        _user!.age != null ? '${_user!.age} ans' : 'Non calculé',
                                      ),
                                      const SizedBox(height: 12),
                                      // ✅ Afficher address si disponible
                                      if (_user!.address != null && _user!.address!.isNotEmpty)
                                        _buildInfoRow('Adresse', _user!.address!),
                                      if (_user!.address != null && _user!.address!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      _buildInfoRow('Ville', _user!.ville ?? 'Non renseignée'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF0EAD69)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditPersonalInfoScreen(user: _user!),
                                      ),
                                    ).then((_) => _loadUser());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    _tile('Mes proches', Icons.group, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FamilyMembersScreen(userId: widget.userId),
                        ),
                      );
                    }),
                  ]),
                  _sectionTitle('Connexion'),
                  _card([
                    _tile('Téléphone', Icons.phone, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditPhoneScreen(
                            currentPhone: _user?.phone ?? '',
                            userId: widget.userId,
                          ),
                        ),
                      ).then((_) => _loadUser());
                    }),
                    _tile('Email', Icons.email, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditEmailScreen(
                            currentEmail: _user?.email ?? '',
                            userId: widget.userId,
                          ),
                        ),
                      ).then((_) => _loadUser());
                    }),
                    _tile('Mot de passe', Icons.lock, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditPasswordScreen(userId: widget.userId),
                        ),
                      );
                    }),
                  ]),
                  _sectionTitle('Paiement & Facturation'),
                  _card([
                    // Afficher le tarif horaire uniquement pour les professionnels
                    if (_user!.userType == 'professionnel')
                      _tile('Tarif horaire', Icons.euro, onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditTarifScreen(
                              currentTarif: _user?.tarif,
                              userId: widget.userId,
                            ),
                          ),
                        ).then((_) => _loadUser());
                      }),
                    if (_user!.userType == 'professionnel')
                      const Divider(),
                    _tile('RIB', Icons.account_balance, onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (_) => EditRibScreen(
                            userId: widget.userId,
                            initialRib: _user?.rib,
                          ),
                        ),
                      )
                          .then((saved) {
                        if (saved == true) _loadUser();
                      });
                    }),
                  ]),
                  _sectionTitle('Paramètres'),
                  _card([
                    _tile('Pays', Icons.flag, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditCountryScreen(
                            currentCountry: _user?.ville,
                          ),
                        ),
                      );
                    }),
                    _tile('Langue', Icons.language, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditLanguageScreen(),
                        ),
                      );
                    }),
                  ]),
                  _sectionTitle('Support'),
                  _card([
                    _tile('Aide & Support', Icons.support_agent,
                        leadingColor: AppTheme.primary, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      );
                    }),
                    const Divider(),
                    FutureBuilder<int>(
                      future: _openReportsCountFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return _tile(
                          'Mes signalements',
                          Icons.report_problem,
                          leadingColor: Colors.orange,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (_) => const MyReportsScreen(),
                              ),
                            )
                                .then((_) => _refreshOpenReportsBadge());
                          },
                          trailing: count > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ]),
                  _sectionTitle('Confidentialité'),
                  _card([
                    _tile('Informations légales', Icons.info_outline,
                        onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LegalInfoScreen(),
                        ),
                      );
                    }),
                    const Divider(),
                    _tile('Gérer mes consentements', Icons.tune_rounded, onTap: () async {
                      await ConsentService.clearConsent();
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConsentScreen(
                            onDecided: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    _tile('Supprimer le compte', Icons.delete_forever,
                        leadingColor: Colors.red, onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Supprimer le compte'),
                          content: const Text(
                              'Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Annuler')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Supprimer',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        final ok = await BackendApiService.deleteUserAccount(
                            widget.userId);
                        if (!mounted) return;
                        Navigator.of(context).pop();

                        if (ok) {
                          await ConsentService.clearConsent();
                          if (!mounted) return;
                          await Provider.of<AuthViewModel>(context,
                                  listen: false)
                              .logout();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const ChoiceScreen()),
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Impossible de supprimer le compte. Réessayez ou contactez le support.'),
                            ),
                          );
                        }
                      }
                    }),
                  ]),
                  _sectionTitle('Documents'),
                  _card([
                    ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: const Color(0xFFA8E063).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.upload_file,
                            color: AppTheme.accent),
                      ),
                      title: const Text('Ajouter un document',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _addDocument('identite'),
                    ),
                    if (_docsIdentite.isNotEmpty) ...[
                      const Divider(),
                      ..._docsIdentite.map((doc) => _DocumentCard(
                        document: doc,
                        onTap: () => _openPreview(doc),
                        onReupload: doc.isRejected ? () => _addDocument(doc.type) : null,
                      )),
                    ]
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // logout
                        Provider.of<AuthViewModel>(context, listen: false)
                            .logout();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Se déconnecter',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Widget pour afficher un document avec son statut
class _DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onReupload;

  const _DocumentCard({
    required this.document,
    required this.onTap,
    this.onReupload,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = document.documentUrl ?? document.path;
    
    // Couleur et icône selon le statut
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (document.status) {
      case 'verified':
        statusColor = AppTheme.emerald;
        statusIcon = Icons.check_circle;
        statusText = 'Vérifié';
        break;
      case 'rejected':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel;
        statusText = 'Rejeté';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'En attente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniature du document
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null && (imageUrl.startsWith('http') || imageUrl.startsWith('https'))
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.description, color: Colors.grey[400]),
                        ),
                      )
                    : imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.description, color: Colors.grey[400]),
                            ),
                          )
                        : Icon(Icons.description, color: Colors.grey[400]),
              ),
              const SizedBox(width: 12),
              
              // Informations du document
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDocumentTypeName(document.type),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Afficher la raison de rejet si présente
                    if (document.isRejected && document.rejectReason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                document.rejectReason!,
                                style: TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (onReupload != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onReupload,
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('Téléverser à nouveau'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocumentTypeName(String type) {
    switch (type) {
      case 'identity':
        return 'Pièce d\'identité';
      case 'kbis':
        return 'KBIS';
      case 'insurance':
        return 'Assurance';
      case 'diploma':
        return 'Diplôme/Certification';
      default:
        return 'Document';
    }
  }
}
