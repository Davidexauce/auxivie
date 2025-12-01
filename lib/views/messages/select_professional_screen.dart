import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_model.dart';
import 'chat_screen.dart';
import '../../theme/app_theme.dart';

/// Écran de sélection d'un professionnel pour démarrer une conversation
class SelectProfessionalScreen extends StatefulWidget {
  final int currentUserId;

  const SelectProfessionalScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<SelectProfessionalScreen> createState() => _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.loadProfessionals();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    // Filtrer les professionnels selon la recherche
    final filteredProfessionals = profileViewModel.professionals.where((professional) {
      if (_searchQuery.isEmpty) return true;
      final name = professional.name.toLowerCase();
      final categorie = professional.categorie.toLowerCase();
      final ville = professional.ville?.toLowerCase() ?? '';
      return name.contains(_searchQuery) ||
          categorie.contains(_searchQuery) ||
          ville.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un professionnel'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un professionnel...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.cardBackground,
              ),
            ),
          ),

          // Liste des professionnels
          Expanded(
            child: profileViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProfessionals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Aucun professionnel disponible'
                                  : 'Aucun résultat',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Les professionnels apparaîtront ici'
                                  : 'Essayez une autre recherche',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await profileViewModel.loadProfessionals();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredProfessionals.length,
                          itemBuilder: (context, index) {
                            final professional = filteredProfessionals[index];
                            return _ProfessionalCard(
                              professional: professional,
                              currentUserId: widget.currentUserId,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Carte pour un professionnel dans la liste
class _ProfessionalCard extends StatelessWidget {
  final UserModel professional;
  final int currentUserId;

  const _ProfessionalCard({
    required this.professional,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primary,
          child: Text(
            professional.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          professional.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              professional.categorie,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (professional.ville != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    professional.ville!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
            if (professional.tarif != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.euro, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${professional.tarif!.toStringAsFixed(2)} €/h',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.message_outlined,
          color: AppTheme.primary,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                currentUserId: currentUserId,
                otherUserId: professional.id!,
              ),
            ),
          );
        },
      ),
    );
  }
}

