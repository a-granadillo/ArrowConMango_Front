import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Entry point for Modo Creativo: create a level, browse your own, or
/// discover what the community has published.
class CreativeHubScreen extends StatelessWidget {
  const CreativeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Modo Creativo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionHeader('Tablero cuadriculado'),
          const SizedBox(height: 8),
          _HubTile(
            icon: Icons.add_circle_outline,
            title: 'Crear nivel',
            subtitle: 'Diseña un tablero nuevo desde cero',
            onTap: () => context.push(AppRoutes.creativeEditor),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.folder_open,
            title: 'Mis niveles',
            subtitle: 'Borradores y niveles que ya publicaste',
            onTap: () => context.push(AppRoutes.creativeMine),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.public,
            title: 'Comunidad',
            subtitle: 'Juega niveles publicados por otros jugadores',
            onTap: () => context.push(AppRoutes.creativeCommunity),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Tablero hexagonal'),
          const SizedBox(height: 8),
          _HubTile(
            icon: Icons.add_circle_outline,
            title: 'Crear nivel hexagonal',
            subtitle: 'Diseña un panal de hexágonos desde cero',
            onTap: () => context.push(AppRoutes.creativeEditorHex),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.folder_open,
            title: 'Mis niveles hexagonales',
            subtitle: 'Borradores y niveles hexagonales que ya publicaste',
            onTap: () => context.push(AppRoutes.creativeMineHex),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.public,
            title: 'Comunidad hexagonal',
            subtitle: 'Juega niveles hexagonales de otros jugadores',
            onTap: () => context.push(AppRoutes.creativeCommunityHex),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
