import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Withdraw Funds',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 30),
            Text(
              'Withdraw Amount',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildAmountInput(),
            const SizedBox(height: 20),
            _buildFeeBreakdown(),
            const SizedBox(height: 40),
            _buildWithdrawButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF16161D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.wallet, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Available \$GBET',
                style: GoogleFonts.outfit(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '12,450.00',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          hintText: '0.00',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {},
              child: const Text('MAX', style: TextStyle(color: Colors.blueAccent)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    return Column(
      children: [
        _feeRow('Off-ramp Fee (1.5%)', '-\$18.75'),
        const SizedBox(height: 8),
        _feeRow('Network Gas', '~\$0.02'),
        const Divider(color: Colors.white10),
        _feeRow('Total Receiving', '~\$1,231.23', isTotal: true),
      ],
    );
  }

  Widget _feeRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white54)),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isTotal ? Colors.greenAccent : Colors.white,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        child: Text(
          'Confirm Withdrawal',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
