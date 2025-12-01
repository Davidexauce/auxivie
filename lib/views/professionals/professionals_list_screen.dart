import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_model.dart';
import 'professional_detail_screen.dart';

/// Écran de liste des professionnels avec filtres
class ProfessionalsListScreen extends StatefulWidget {
  const ProfessionalsListScreen({super.key});

  @override
  State<ProfessionalsListScreen> createState() => _ProfessionalsListScreenState();
}

class _ProfessionalsListScreenState extends State<ProfessionalsListScreen> {
  String? _selectedCity;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.loadProfessionals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final cities = await profileViewModel.getAvailableCities();
    final categories = await profileViewModel.getAvailableCategories();

    if (mounted) {
      _showFilterDialog(cities, categories);
    }
  }

  Future<void> _showFilterDialog(List<String> cities, List<String> categories) async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String? tempCity = _selectedCity;
          String? tempCategory = _selectedCategory;

          return AlertDialog(
            title: const Text('Filtres'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filtre par ville
                DropdownButtonFormField<String>(
                  value: tempCity,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes les villes'),
                    ),
                    ...cities.map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      tempCity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Filtre par catégorie
                DropdownButtonFormField<String>(
                  value: tempCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Toutes les catégories'),
                    ),
                    ...categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      tempCategory = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    tempCity = null;
                    tempCategory = null;
                  });
                },
                child: const Text('Réinitialiser'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCity = tempCity;
                    _selectedCategory = tempCategory;
                  });
                  profileViewModel.searchProfessionals(
                    ville: _selectedCity,
                    categorie: _selectedCategory,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Appliquer'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professionnels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _loadFilters,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche - Style Doctolib
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un professionnel...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          // Filtres actifs
          if (_selectedCity != null || _selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCity != null)
                    Chip(
                      label: Text('Ville: $_selectedCity'),
                      onDeleted: () {
                        setState(() {
                          _selectedCity = null;
                        });
                        profileViewModel.searchProfessionals(
                          ville: null,
                          categorie: _selectedCategory,
                        );
                      },
                    ),
                  if (_selectedCategory != null)
                    Chip(
                      label: Text('Catégorie: $_selectedCategory'),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        profileViewModel.searchProfessionals(
                          ville: _selectedCity,
                          categorie: null,
                        );
                      },
                    ),
                ],
              ),
            ),

          // Liste des professionnels
          Expanded(
            child: profileViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profileViewModel.professionals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun professionnel trouvé',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: profileViewModel.professionals.length,
                        itemBuilder: (context, index) {
                          final professional = profileViewModel.professionals[index];
                          
                          // Filtrage par recherche textuelle
                          if (_searchController.text.isNotEmpty) {
                            final searchLower = _searchController.text.toLowerCase();
                            if (!professional.name.toLowerCase().contains(searchLower) &&
                                (professional.ville == null ||
                                    !professional.ville!.toLowerCase().contains(searchLower)) &&
                                !professional.categorie.toLowerCase().contains(searchLower)) {
                              return const SizedBox.shrink();
                            }
                          }

                          return _ProfessionalCard(professional: professional);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Carte pour un professionnel dans la liste - Style Doctolib
class _ProfessionalCard extends StatelessWidget {
  final UserModel professional;

  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfessionalDetailScreen(professional: professional),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    professional.name[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      professional.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Catégorie avec badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        professional.categorie,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Détails
                    Row(
                      children: [
                        if (professional.ville != null) ...[
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            professional.ville!,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (professional.tarif != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ],
                        if (professional.tarif != null) ...[
                          Icon(Icons.euro, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${professional.tarif!.toStringAsFixed(2)}/h',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

