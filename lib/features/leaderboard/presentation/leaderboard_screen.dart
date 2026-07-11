import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mango_background.dart';
import '../../player/presentation/player_cubit.dart';
import 'leaderboard_cubit.dart';
import 'leaderboard_state.dart';
import '../domain/leaderboard_entry.dart';

/// Global "Guest-First" leaderboard: shows the ranking with the local guest
/// highlighted, plus an optional (stubbed) social sign-in to link the account.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final player = context.read<PlayerCubit>().state;
      context.read<LeaderboardCubit>().load(player);
    });
  }

  void _onSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inicio de sesión con Google/Apple — próximamente 🥭'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MangoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textOnPrimary),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clasificación',
                    style: AppTypography.display(26,
                        color: AppColors.textOnPrimary),
                  ),
                  Text(
                    'Los mejores cosechadores',
                    style: AppTypography.body(13,
                        color: AppColors.textOnPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) => switch (state) {
                LeaderboardLoaded(:final entries) =>
                  _LeaderboardList(entries: entries),
                LeaderboardError(:final message) => Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(16,
                          color: AppColors.textOnPrimary),
                    ),
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.textOnPrimary),
                  ),
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _onSignIn,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Vincular cuenta (Google / Apple)'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.textOnPrimary,
              side: const BorderSide(color: AppColors.textOnPrimary, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _LeaderboardRow(entry: entries[index]),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final highlighted = entry.isCurrentPlayer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.mango : AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: AppColors.primaryDark, width: 2)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: AppTypography.display(18, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              entry.initial,
              style: AppTypography.display(16, color: AppColors.cream),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              highlighted ? '${entry.displayName} (Tú)' : entry.displayName,
              style: AppTypography.body(16,
                  color: AppColors.textDark, weight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('🥭 ${entry.mangos}',
              style: AppTypography.body(15, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
