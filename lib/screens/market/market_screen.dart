import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String _selectedFilter = 'Todos';
  final _searchController = TextEditingController();

  static const _filters = ['Todos', 'Agentes Libres', 'Nacional', 'Internacional', 'Juveniles'];

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(marketPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEMPORADA 2024/25',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mercado de Pases',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar jugador o club...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                  fillColor: AppColors.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100), // Pill shape
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = filter);
                      },
                      backgroundColor: AppColors.surfaceVariant.withOpacity(0.5),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Main Content ListView
            Expanded(
              child: posts.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (data) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Agentes Libres\nDestacados',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                height: 1.2,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver\ntodos',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // High Fidelity Player Cards
                      const _PlayerCardMock(
                        name: "MARCOS 'EL\nMURO' RUIZ",
                        position: "Central",
                        ageAndHeight: "2.10m | 31 años",
                        reach: "3.65m",
                        imgUrl: "https://images.unsplash.com/photo-1593341398860-264627b1406c?q=80&w=600",
                        status: "MÁS BUSCADO",
                      ),
                      const _PlayerCardMock(
                        name: "LUCÍA\nFERNANDEZ",
                        position: "Opuesta",
                        ageAndHeight: "1.88m | 24 años",
                        reach: "3.10m",
                        imgUrl: "https://images.unsplash.com/photo-1574629810360-7efbc5ea002c?q=80&w=600",
                        status: "MÁS BUSCADA",
                      ),
                      const SizedBox(height: 40), // Bottom padding for nav bar
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCardMock extends StatelessWidget {
  final String name;
  final String position;
  final String ageAndHeight;
  final String reach;
  final String status;
  final String imgUrl;

  const _PlayerCardMock({
    required this.name,
    required this.position,
    required this.ageAndHeight,
    required this.reach,
    required this.imgUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Dark card background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with dark gradient overlay
          Image.network(
            imgUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                  const Color(0xFF1A1A1A), // Dark solid at bottom
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.6, 0.9],
              ),
            ),
          ),
          
          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Top Right Reach metric (Simulating float)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      const Text(
                        'ALCANCE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        reach,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Content
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$position | $ageAndHeight',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Negociar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Ver Stats', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
