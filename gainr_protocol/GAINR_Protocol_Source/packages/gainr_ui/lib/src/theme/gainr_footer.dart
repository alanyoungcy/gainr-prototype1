import 'package:flutter/material.dart';
import './app_theme.dart';

class GainrFooter extends StatelessWidget {
  final String systemId;
  final String region;
  final String latency;
  final List<FooterLink>? extraLinks;

  const GainrFooter({
    super.key,
    this.systemId = 'TERMINAL_v1.0.4',
    this.region = 'US-EAST-1',
    this.latency = '12ms',
    this.extraLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
        vertical: 48,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF050505),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 48,
            runSpacing: 32,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VERIFIED_GATEWAY',
                        style: TextStyle(
                            color: AppColors.neonOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1)),
                    const SizedBox(height: 16),
                    Text(
                      'All signals and predictions are secured via AES-256 encryption. Trading involves high risk. Past performance is not indicative of future results.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
              _FooterGroup(
                title: 'TERMINAL_TELEMETRY',
                items: [
                  'SYS_ID: $systemId',
                  'REGION: $region',
                  'LATENCY: $latency',
                ],
              ),
              if (extraLinks != null)
                _FooterGroup(
                  title: 'RESOURCES',
                  items: extraLinks!.map((l) => l.label).toList(),
                  onTap: (index) => extraLinks![index].onTap(),
                ),
            ],
          ),
          const SizedBox(height: 60),
          Text('© 2026 GAINR_PROTOCOL | Headquartered in Hong Kong',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                  fontSize: 10,
                  letterSpacing: 2)),
        ],
      ),
    );
  }
}

class FooterLink {
  final String label;
  final VoidCallback onTap;
  FooterLink({required this.label, required this.onTap});
}

class _FooterGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(int)? onTap;

  const _FooterGroup({required this.title, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1)),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: onTap != null ? () => onTap!(index) : null,
              hoverColor: Colors.transparent,
              child: Text(item,
                  style: TextStyle(
                      color: onTap != null ? Colors.white70 : Colors.white24,
                      fontSize: 11)),
            ),
          );
        }),
      ],
    );
  }
}
