import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _topN = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = context.watch<LeaderboardProvider>();
    final auth = context.watch<AuthProvider>();
    final myUserId = auth.user?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.filter_list_rounded, color: AppColors.textHint, size: 20),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _topN,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('Top 10')),
                    DropdownMenuItem(value: 50, child: Text('Top 50')),
                    DropdownMenuItem(value: 100, child: Text('Top 100')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _topN = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: leaderboard.loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : leaderboard.error != null
                    ? Center(child: Text(leaderboard.error!, style: const TextStyle(color: AppColors.rejected)))
                    : leaderboard.topChildren.isEmpty
                        ? const Center(child: Text('Chưa có dữ liệu bảng xếp hạng', style: TextStyle(color: AppColors.textHint)))
                        : RefreshIndicator(
                            onRefresh: () => context.read<LeaderboardProvider>().loadLeaderboard(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: leaderboard.topChildren.take(_topN).length,
                              itemBuilder: (context, index) {
                                final user = leaderboard.topChildren.take(_topN).toList()[index];
                          final isMe = user.id == myUserId;

                          // Rank styles
                          Color rankColor = Colors.grey;
                          IconData? rankIcon;
                          if (index == 0) {
                            rankColor = const Color(0xFFFFD700); // Gold
                            rankIcon = Icons.emoji_events_rounded;
                          } else if (index == 1) {
                            rankColor = const Color(0xFFC0C0C0); // Silver
                            rankIcon = Icons.military_tech_rounded;
                          } else if (index == 2) {
                            rankColor = const Color(0xFFCD7F32); // Bronze
                            rankIcon = Icons.military_tech_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isMe ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.black.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                // Rank indicator
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: rankIcon != null
                                      ? Icon(rankIcon, color: rankColor, size: 32)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                                  backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                                  child: user.avatar == null ? const Icon(Icons.person, color: AppColors.secondary) : null,
                                ),
                                const SizedBox(width: 16),
                                // Name and Family
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (user.familyName != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gia đình ${user.familyName}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Points
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.approved.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.stars_rounded, color: AppColors.approved, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.points}',
                                        style: const TextStyle(
                                          color: AppColors.approved,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
