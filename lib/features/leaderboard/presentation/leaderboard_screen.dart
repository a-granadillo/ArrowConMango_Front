import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_svgs.dart';
import '../../player/presentation/player_cubit.dart';
import '../domain/leaderboard_entry.dart';
import 'leaderboard_cubit.dart';
import 'leaderboard_state.dart';

/// Global "Guest-First" leaderboard: faithful reproduction of the design's
/// "Leaderboard" screen — a green header with a top-3 podium, followed by a
/// scrollable list of the remaining ranks with the local guest highlighted.
///
/// The design has no sign-in control anywhere; the optional "link account"
/// action required by issue #36 is added as a small, unobtrusive text link
/// at the bottom so it doesn't compete with the podium/list.
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) => switch (state) {
          LeaderboardLoaded(:final entries) =>
            _LeaderboardBody(entries: entries, onSignIn: _onSignIn),
          LeaderboardError(:final message) => Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textDark),
              ),
            ),
          _ => const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            ),
        },
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({required this.entries, required this.onSignIn});

  final List<LeaderboardEntry> entries;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final podium = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : const <LeaderboardEntry>[];

    return Column(
      children: [
        _Header(podium: podium),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: rest.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _LeaderboardRow(entry: rest[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextButton.icon(
            onPressed: onSignIn,
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Vincular cuenta (Google / Apple)'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.podium});

  final List<LeaderboardEntry> podium;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    // Design order left-to-right: 2nd, 1st, 3rd.
    final ordered = [
      if (podium.length > 1) podium[1],
      if (podium.isNotEmpty) podium[0],
      if (podium.length > 2) podium[2],
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.successDark, AppColors.success],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppSvgs.icon(AppSvgs.backChevron, 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clasificación',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Los mejores cosechadores',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              AppSvgs.icon(AppSvgs.trophyFilled, 30),
            ],
          ),
          const SizedBox(height: 22),
          if (ordered.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _PodiumSlot(entry: ordered[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({required this.entry});

  final LeaderboardEntry entry;

  bool get _first => entry.rank == 1;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _first ? 58.0 : 46.0;
    final avatarFontSize = _first ? 24.0 : 19.0;
    final barHeight = _first ? 84.0 : (entry.rank == 2 ? 62.0 : 48.0);
    final ring = _first ? AppColors.mango : Colors.white.withValues(alpha: 0.6);
    final numColor = _first ? AppColors.mango : Colors.white;

    return SizedBox(
      width: 86,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(entry.colorValue),
              border: Border.all(color: ring, width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              entry.initial,
              style: GoogleFonts.fredoka(fontSize: avatarFontSize, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            height: barHeight,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              children: [
                Text(
                  '${entry.rank}',
                  style: GoogleFonts.fredoka(fontSize: 20, height: 1, color: numColor),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSvgs.icon(AppSvgs.mangoDot, 12),
                    const SizedBox(width: 3),
                    Text(
                      '${entry.mangos}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final highlighted = entry.isCurrentPlayer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.cream2 : Colors.white,
        border: Border.all(
          color: highlighted ? AppColors.primary : const Color(0xFFF0E4D4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: highlighted ? const Color(0xFFE8C088) : const Color(0xFFE8DCC8),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(fontSize: 17, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(entry.colorValue),
            child: Text(
              entry.initial,
              style: GoogleFonts.fredoka(fontSize: 15, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlighted ? '${entry.displayName} (Tú)' : entry.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  entry.sub,
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cream2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvgs.icon(AppSvgs.mangoDot, 15),
                const SizedBox(width: 5),
                Text(
                  '${entry.mangos}',
                  style: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
