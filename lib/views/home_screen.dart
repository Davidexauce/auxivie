import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';
import 'professionals/professionals_list_screen.dart';
import 'messages/messages_list_screen.dart';
import 'reservations/reservations_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/choice_screen.dart';
import 'home/home_dashboard_screen.dart';
import 'home/professional_dashboard_screen.dart';

/// Écran d'accueil principal avec navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    // Ne rediriger que si on n'est pas déjà en train de naviguer
    if (currentUser == null) {
      // Attendre un peu avant de rediriger pour éviter les redirections lors des navigations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && authViewModel.currentUser == null) {
          // Vérifier qu'on n'est pas déjà sur ChoiceScreen
          final route = ModalRoute.of(context);
          if (route?.settings.name != '/choice') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ChoiceScreen()),
              (route) => false,
            );
          }
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isProfessional = currentUser.userType == 'professionnel';

    // Définir les écrans disponibles selon le type d'utilisateur
    // Index 0: Accueil, 1: Recherche/Tableau, 2: Messages, 3: Planning, 4: Profil
    final List<Widget> _screens = [
      // Accueil avec statistiques et informations
      HomeDashboardScreen(
        currentUser: currentUser,
        onNavigate: _onItemTapped,
      ),
      // Recherche pour familles, Tableau de bord pour professionnels
      if (!isProfessional)
        const ProfessionalsListScreen()
      else
        ProfessionalDashboardScreen(
          currentUser: currentUser,
          onNavigate: _onItemTapped,
        ),
      MessagesListScreen(userId: currentUser.id!),
      ReservationsScreen(userId: currentUser.id!),
      ProfileScreen(userId: currentUser.id!),
    ];

    // Définir les items de navigation selon le type d'utilisateur
    final List<BottomNavigationBarItem> _navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Accueil',
      ),
      if (!isProfessional)
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Recherche',
        )
      else
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Tableau',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.message_rounded),
        label: 'Messages',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_rounded),
        label: 'Planning',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];

    return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.textGradient.createShader(bounds),
          child: const Text(
            'Auxivie',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textPrimary),
            onPressed: () {
              authViewModel.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChoiceScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardBackground,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          iconSize: 24,
          selectedIconTheme: const IconThemeData(
            color: AppTheme.primary,
            size: 26,
          ),
          unselectedIconTheme: const IconThemeData(
            color: AppTheme.textTertiary,
            size: 24,
          ),
          elevation: 8,
          items: _navItems,
        ),
      ),
    );
  }
}
