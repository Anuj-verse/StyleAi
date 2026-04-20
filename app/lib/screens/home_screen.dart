import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/clothing_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load wardrobe on home entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wardrobeProvider.notifier).loadClothes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeDashboard(),
          _buildWardrobeTab(),
          const SizedBox(), // Placeholder — Generate navigates to outfit screen
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              // Navigate to Generate Outfit screen
              Navigator.pushNamed(context, '/outfit');
              return;
            }
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined),
              activeIcon: Icon(Icons.checkroom_rounded),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Generate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/upload'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Add Clothes'),
            )
          : null,
    );
  }

  // ── Home Dashboard ──
  Widget _buildHomeDashboard() {
    final wardrobe = ref.watch(wardrobeProvider);
    final auth = ref.watch(authProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.user?.name ?? "Stylish"} 👋',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s find your perfect outfit',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Weather Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF4A90D9).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded,
                        color: Colors.amber, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '28°C — Sunny',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Light & breathable clothes recommended',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Quick Stats ──
              Text(
                'Your Wardrobe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'Tops',
                    '${wardrobe.topCount}',
                    Icons.checkroom_rounded,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Bottoms',
                    '${wardrobe.bottomCount}',
                    Icons.straighten_rounded,
                    AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Shoes',
                    '${wardrobe.shoesCount}',
                    Icons.ice_skating_rounded,
                    AppTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Extras',
                    '${wardrobe.accessoryCount}',
                    Icons.watch_rounded,
                    AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Generate Button ──
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/outfit'),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generate Outfit',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-powered outfit suggestions',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Recent Items ──
              if (wardrobe.items.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recently Added',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 1),
                      child: Text('See All',
                          style: TextStyle(color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        wardrobe.items.length > 5 ? 5 : wardrobe.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 140,
                          child: ClothingCard(
                            clothing: wardrobe.items[index],
                            onDelete: () {},
                            compact: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Wardrobe Tab ──
  Widget _buildWardrobeTab() {
    final wardrobe = ref.watch(wardrobeProvider);
    final categories = ['all', 'top', 'bottom', 'shoes', 'accessories'];

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('My Wardrobe',
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected =
                      (wardrobe.selectedCategory ?? 'all') == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(wardrobeProvider.notifier).setCategory(cat);
                      },
                      backgroundColor: AppTheme.surfaceMid,
                      selectedColor: AppTheme.primaryColor,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white12,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Grid
            Expanded(
              child: wardrobe.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : wardrobe.filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checkroom_outlined,
                                  size: 64, color: Colors.white24),
                              const SizedBox(height: 16),
                              Text('No clothes yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              const SizedBox(height: 8),
                              Text('Tap + to add your first item',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: wardrobe.filteredItems.length,
                          itemBuilder: (context, index) {
                            return ClothingCard(
                              clothing: wardrobe.filteredItems[index],
                              onDelete: () {
                                ref
                                    .read(wardrobeProvider.notifier)
                                    .deleteClothing(
                                        wardrobe.filteredItems[index].id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Tab ──
  Widget _buildProfileTab() {
    final auth = ref.watch(authProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (auth.user?.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                auth.user?.name ?? 'User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 36),

              // Menu items
              _buildProfileItem(Icons.checkroom_rounded, 'My Wardrobe',
                  () => setState(() => _currentIndex = 1)),
              _buildProfileItem(Icons.favorite_rounded, 'Saved Outfits',
                  () => Navigator.pushNamed(context, '/outfit')),
              _buildProfileItem(
                  Icons.settings_rounded, 'Settings', () {}),
              _buildProfileItem(Icons.help_outline_rounded, 'Help', () {}),
              const SizedBox(height: 20),
              _buildProfileItem(
                Icons.logout_rounded,
                'Logout',
                () async {
                  await ref.read(authProvider.notifier).logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.error.withValues(alpha: 0.1)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              color: isDestructive ? AppTheme.error : AppTheme.primaryColor),
        ),
        title: Text(label,
            style: TextStyle(
                color: isDestructive ? AppTheme.error : Colors.white,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDestructive ? AppTheme.error : Colors.white38),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: AppTheme.cardDark.withValues(alpha: 0.5),
      ),
    );
  }
}
