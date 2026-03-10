import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_theme.dart';

class GlobalSearchHUD extends StatefulWidget {
  final List<HUDAction> actions;
  final VoidCallback onClose;

  const GlobalSearchHUD({
    super.key,
    required this.actions,
    required this.onClose,
  });

  @override
  State<GlobalSearchHUD> createState() => _GlobalSearchHUDState();
}

class _GlobalSearchHUDState extends State<GlobalSearchHUD> {
  final TextEditingController _searchController = TextEditingController();
  List<HUDAction> _filteredActions = [];

  @override
  void initState() {
    super.initState();
    _filteredActions = widget.actions;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredActions = widget.actions
          .where((a) => a.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 600,
          height: 400,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppColors.neonOrange.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonOrange.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search,
                        color: AppColors.neonOrange, size: 18),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'RUN_COMMAND_OR_SEARCH_INTEL…',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x,
                          color: Colors.white24, size: 18),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              // Results List
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredActions.length,
                  itemBuilder: (context, index) {
                    final action = _filteredActions[index];
                    return _HUDActionItem(
                      action: action,
                      onTap: () {
                        action.onAction();
                        widget.onClose();
                      },
                    );
                  },
                ),
              ),
              // Footer Telemetry
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF050505),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SYSTEM_ID: GAINR_CORE_v2',
                        style: TextStyle(color: Colors.white24, fontSize: 10)),
                    Text('RESULTS: ${_filteredActions.length}',
                        style: const TextStyle(
                            color: AppColors.neonOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HUDAction {
  final String title;
  final IconData icon;
  final VoidCallback onAction;

  HUDAction({
    required this.title,
    required this.icon,
    required this.onAction,
  });
}

class _HUDActionItem extends StatelessWidget {
  final HUDAction action;
  final VoidCallback onTap;

  const _HUDActionItem({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(action.icon, color: Colors.white54, size: 16),
      title: Text(
        action.title.toUpperCase(),
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace'),
      ),
      trailing: const Icon(LucideIcons.chevron_right,
          color: AppColors.neonOrange, size: 14),
      onTap: onTap,
      hoverColor: AppColors.neonOrange.withValues(alpha: 0.05),
    );
  }
}
