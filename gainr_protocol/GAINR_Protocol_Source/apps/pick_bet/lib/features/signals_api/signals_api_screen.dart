import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SignalsApiScreen extends ConsumerWidget {
  const SignalsApiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = gainrPadding(screenWidth);
        final heroFontSize = gainrHeroFontSize(screenWidth);

        return SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              NeonText(
                text: 'SIGNALS_API',
                glowColor: AppTheme.neonOrange,
                glowRadius: 12,
                style: AppTextStyles.h1.copyWith(
                  fontSize: heroFontSize,
                  color: AppTheme.neonOrange,
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 16),
              const Text('PROGRAMMATIC ACCESS | REST + WEBSOCKET',
                  style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),

              // API Documentation Mock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.code,
                            color: AppTheme.neonOrange, size: 16),
                        SizedBox(width: 12),
                        Text('API_ENDPOINTS',
                            style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildEndpointRow(context, 'GET', '/api/v1/signals',
                        'Fetch latest political intel signals', screenWidth),
                    const SizedBox(height: 16),
                    _buildEndpointRow(context, 'GET', '/api/v1/providers',
                        'List all providers', screenWidth),
                    const SizedBox(height: 16),
                    _buildEndpointRow(context, 'POST', '/api/v1/subscribe',
                        'Subscribe to provider', screenWidth),
                    const SizedBox(height: 16),
                    _buildEndpointRow(context, 'WS', '/ws/v1/stream',
                        'Real-time political alpha stream', screenWidth),
                    const SizedBox(height: 32),

                    // Auth Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                            color: AppTheme.neonOrange.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AUTHENTICATION',
                              style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          SizedBox(height: 12),
                          Text(
                            'Authorization: Bearer <API_KEY>\n'
                            'X-Protocol-Version: v3.0\n'
                            'Content-Type: application/json',
                            style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 12,
                                fontFamily: 'monospace',
                                height: 1.8),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.neonOrange),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.lock,
                              color: AppTheme.neonOrange, size: 14),
                          SizedBox(width: 8),
                          Text('API_KEY_REQUIRED',
                              style: TextStyle(
                                  color: AppTheme.neonOrange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEndpointRow(BuildContext context, String method, String path,
      String description, double screenWidth) {
    Color methodColor;
    switch (method) {
      case 'POST':
        methodColor = Colors.green;
        break;
      case 'WS':
        methodColor = Colors.blue;
        break;
      default:
        methodColor = AppTheme.neonOrange;
    }

    if (screenWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: methodColor),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(method,
                      style: TextStyle(
                          color: methodColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(path,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Text(description,
                style: const TextStyle(color: Colors.white30, fontSize: 12)),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: methodColor),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(method,
                style: TextStyle(
                    color: methodColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(path,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(description,
              style: const TextStyle(color: Colors.white30, fontSize: 12)),
        ),
      ],
    );
  }
}
