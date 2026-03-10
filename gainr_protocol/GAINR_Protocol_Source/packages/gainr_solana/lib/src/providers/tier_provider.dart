import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';

/// User tier based on $GAINR staked amount
enum UserTier { bronze, silver, gold, diamond }

class TierInfo {
  final UserTier tier;
  final String name;
  final String emoji;
  final Color color;
  final double feeDiscount;
  final double minStaked;
  final double? nextTierMin;

  const TierInfo({
    required this.tier,
    required this.name,
    required this.emoji,
    required this.color,
    required this.feeDiscount,
    required this.minStaked,
    this.nextTierMin,
  });

  double get progressToNext {
    if (nextTierMin == null) return 1.0;
    return 1.0; // Will be computed dynamically
  }

  String get feeLabel => '-${(feeDiscount * 100).toInt()}% Fees';
}

const _tiers = [
  TierInfo(
    tier: UserTier.bronze,
    name: 'Bronze',
    emoji: '🥉',
    color: Color(0xFFCD7F32),
    feeDiscount: 0.0,
    minStaked: 0,
    nextTierMin: 5000,
  ),
  TierInfo(
    tier: UserTier.silver,
    name: 'Silver',
    emoji: '🥈',
    color: Color(0xFFC0C0C0),
    feeDiscount: 0.10,
    minStaked: 5000,
    nextTierMin: 25000,
  ),
  TierInfo(
    tier: UserTier.gold,
    name: 'Gold',
    emoji: '🥇',
    color: Color(0xFFFFD700),
    feeDiscount: 0.20,
    minStaked: 25000,
    nextTierMin: 100000,
  ),
  TierInfo(
    tier: UserTier.diamond,
    name: 'Diamond',
    emoji: '💎',
    color: Color(0xFF00D4FF),
    feeDiscount: 0.35,
    minStaked: 100000,
  ),
];

/// Current tier info provider based on wallet's GAINR balance
final userTierProvider = Provider<TierInfo>((ref) {
  final wallet = ref.watch(walletProvider);
  final staked = wallet.gainrBalance;

  TierInfo currentTier = _tiers.first;
  for (final tier in _tiers.reversed) {
    if (staked >= tier.minStaked) {
      currentTier = tier;
      break;
    }
  }
  return currentTier;
});

/// Progress towards the next tier (0.0 to 1.0)
final tierProgressProvider = Provider<double>((ref) {
  final wallet = ref.watch(walletProvider);
  final staked = wallet.gainrBalance;
  final tier = ref.watch(userTierProvider);

  if (tier.nextTierMin == null) return 1.0; // Max tier
  final range = tier.nextTierMin! - tier.minStaked;
  final progress = (staked - tier.minStaked) / range;
  return progress.clamp(0.0, 1.0);
});
