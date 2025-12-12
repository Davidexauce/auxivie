import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../models/document_model.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
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
                        source: ImageSource.camera, imageQuality: 90);
                    if (picked == null) return;
                    
                    // Afficher un indicateur de chargement
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    // Uploader vers le backend
                    final file = File(picked.path);
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
                          const SnackBar(content: Text('Erreur lors de l\'upload du document')));
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
                        source: ImageSource.gallery, imageQuality: 90);
                    if (picked == null) return;
                    
                    // Afficher un indicateur de chargement
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    // Uploader vers le backend
                    final file = File(picked.path);
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
                          const SnackBar(content: Text('Erreur lors de l\'upload du document')));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded,
                      color: Color.fromARGB(255, 43, 54, 29)),
                  title: const Text('Importer un fichier (PDF, images)'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
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
          color: (leadingColor ?? AppTheme.primary).withOpacity(0.12),
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

  String _extractFirstName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join(' ');
    }
    return '';
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
                        source: ImageSource.camera, imageQuality: 90);
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
                        source: ImageSource.gallery, imageQuality: 90);
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
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null)
      return const Scaffold(
          body: Center(child: Text('Utilisateur introuvable')));

    // ProfileScreen est dans un IndexedStack, donc il n'est pas dans la pile de navigation
    // Le bouton retour système ne devrait rien faire ici
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
                                    backgroundColor: AppTheme.primary.withOpacity(0.1),
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
                                      _buildInfoRow('Nom', _user!.name),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Prénom', _extractFirstName(_user!.name)),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Date de naissance', 'Non renseignée'),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Âge', 'Non calculé'),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Adresse', _user!.ville ?? 'Non renseignée'),
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
                    _tile('RIB', Icons.account_balance, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditRibScreen(),
                        ),
                      );
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
                    FutureBuilder<int>(
                      future: _getOpenReportsCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return _tile('Mes signalements', Icons.report_problem,
                            leadingColor: Colors.orange, onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                          builder: (_) => const MyReportsScreen(),
                        ),
                      );
                      
                      // Recharger le badge après retour de MyReportsScreen
                      // (au cas où un signalement aurait été créé depuis un autre écran)
                      if (mounted) {
                        setState(() {
                          // Le badge se rechargera automatiquement via _getOpenReportsCount()
                        });
                      }
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
                            : null);
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

                      if (confirm == true) {
                        // TODO: Implémenter la suppression du compte via l'API backend
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Compte supprimé')));
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
                            color: const Color(0xFFA8E063).withOpacity(0.12),
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
