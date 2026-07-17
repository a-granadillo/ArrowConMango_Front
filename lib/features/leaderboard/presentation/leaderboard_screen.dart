import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/i18n/app_localizations_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_svgs.dart';
import '../../game/application/dtos/level_summary.dart';
import '../../game/application/use_cases/get_level_list_use_case.dart';
import '../../game/domain/repositories/result.dart';
import '../domain/leaderboard_entry.dart';
import 'leaderboard_cubit.dart';
import 'leaderboard_state.dart';

/// Leaderboard screen with two tabs: "Por Nivel" (level selector + that
/// level's own ranking) and "Supervivencia" (total mangos across every
/// survival run). Both highlight the top 10 and pin the requesting
/// player's own row at the bottom, even when they fall outside the top.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.getLevelListUseCase});

  final GetLevelListUseCase getLevelListUseCase;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<LevelSummary> _unlockedLevels = const [];
  int? _selectedLevelId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLevelsThenTab());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLevelsThenTab() async {
    final result = await widget.getLevelListUseCase();
    if (!mounted) return;
    if (result case Success(:final value)) {
      final unlocked = value.where((l) => l.isUnlocked).toList();
      setState(() {
        _unlockedLevels = unlocked;
        _selectedLevelId = unlocked.isEmpty ? null : unlocked.first.levelId;
      });
    }
    _loadCurrentTab();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadCurrentTab();
  }

  void _loadCurrentTab() {
    final cubit = context.read<LeaderboardCubit>();
    if (_tabController.index == 0) {
      final levelId = _selectedLevelId;
      if (levelId != null) cubit.loadByLevel('$levelId');
    } else {
      cubit.loadSurvival();
    }
  }

  void _onLevelSelected(int levelId) {
    setState(() => _selectedLevelId = levelId);
    context.read<LeaderboardCubit>().loadByLevel('$levelId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _Header(
            tabController: _tabController,
            unlockedLevels: _unlockedLevels,
            selectedLevelId: _selectedLevelId,
            onLevelSelected: _onLevelSelected,
          ),
          Expanded(
            child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) => switch (state) {
                LeaderboardLoaded(:final page) => _LeaderboardBody(page: page),
                LeaderboardError(:final message) => Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.nunito(fontSize: 16, color: AppColors.textDark),
                    ),
                  ),
                _ => const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({required this.page});

  final LeaderboardPage page;

  @override
  Widget build(BuildContext context) {
    final entries = page.top;
    final podium = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : const <LeaderboardEntry>[];
    final me = page.me;

    if (entries.isEmpty && me == null) {
      final metric = entries.isEmpty ? LeaderboardMetric.levels : entries.first.metric;
      return Center(
        child: Text(
          metric == LeaderboardMetric.survivalRuns
              ? context.l10n.leaderboardEmptySurvival
              : context.l10n.leaderboardEmptyByLevel,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: [
        if (podium.isNotEmpty) _Podium(podium: podium),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: rest.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _LeaderboardRow(entry: rest[index]),
          ),
        ),
        if (me != null) _PinnedMeRow(entry: me),
      ],
    );
  }
}

class _PinnedMeRow extends StatelessWidget {
  const _PinnedMeRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: Color(0xFFF0E4D4), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.leaderboardYourPosition,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _LeaderboardRow(entry: entry),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tabController,
    required this.unlockedLevels,
    required this.selectedLevelId,
    required this.onLevelSelected,
  });

  final TabController tabController;
  final List<LevelSummary> unlockedLevels;
  final int? selectedLevelId;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.of(context).padding.top;

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
                      l10n.leaderboardTitle,
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.leaderboardSubtitle,
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
          const SizedBox(height: 16),
          TabBar(
            controller: tabController,
            indicatorColor: AppColors.mango,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            labelStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800),
            tabs: [
              Tab(text: l10n.leaderboardTabByLevel),
              Tab(text: l10n.leaderboardTabSurvival),
            ],
          ),
          AnimatedBuilder(
            animation: tabController,
            builder: (context, _) => tabController.index == 0
                ? _LevelSelector(
                    levels: unlockedLevels,
                    selectedLevelId: selectedLevelId,
                    onSelected: onLevelSelected,
                  )
                : const SizedBox(height: 12),
          ),
        ],
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({
    required this.levels,
    required this.selectedLevelId,
    required this.onSelected,
  });

  final List<LevelSummary> levels;
  final int? selectedLevelId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedLevelId,
          dropdownColor: AppColors.successDark,
          iconEnabledColor: Colors.white,
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700),
          items: [
            for (final level in levels)
              DropdownMenuItem(
                value: level.levelId,
                child: Text(context.l10n.leaderboardSelectLevel(level.levelId)),
              ),
          ],
          onChanged: (levelId) {
            if (levelId != null) onSelected(levelId);
          },
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.podium});

  final List<LeaderboardEntry> podium;

  @override
  Widget build(BuildContext context) {
    // Design order left-to-right: 2nd, 1st, 3rd.
    final ordered = [
      if (podium.length > 1) podium[1],
      if (podium.isNotEmpty) podium[0],
      if (podium.length > 2) podium[2],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.4, -1),
            end: Alignment(0.4, 1),
            colors: [AppColors.successDark, AppColors.success],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < ordered.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _PodiumSlot(entry: ordered[i]),
            ],
          ],
        ),
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
    final highlighted = entry.isCurrentPlayer;
    final avatarSize = _first ? 58.0 : 46.0;
    final avatarFontSize = _first ? 24.0 : 19.0;
    final barHeight = _first ? 84.0 : (entry.rank == 2 ? 62.0 : 48.0);
    final ring = highlighted
        ? AppColors.primary
        : (_first ? AppColors.mango : Colors.white.withValues(alpha: 0.6));
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
              border: Border.all(color: ring, width: highlighted ? 4 : 3),
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
            highlighted
                ? context.l10n.leaderboardCurrentPlayer(entry.displayName)
                : entry.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: highlighted ? AppColors.mango : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            height: barHeight,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: highlighted
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: highlighted
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
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

  String _subtitle(BuildContext context) => switch (entry.metric) {
        LeaderboardMetric.levels =>
          context.l10n.leaderboardLevelsSub(entry.secondaryValue),
        LeaderboardMetric.moves =>
          context.l10n.leaderboardMovesSub(entry.secondaryValue),
        LeaderboardMetric.survivalRuns =>
          context.l10n.leaderboardRunsSub(entry.secondaryValue),
      };

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
                  highlighted
                      ? context.l10n.leaderboardCurrentPlayer(entry.displayName)
                      : entry.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _subtitle(context),
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
