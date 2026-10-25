import 'package:flutter/material.dart';

import '../data.dart';
import '../smooth_scroll.dart';
import '../theme.dart';
import '../l10n/strings.dart';

Map<String, String> get _typeLabels => {
  'rj': appL10n.blacklistPageTypeLabelsTypeLabels,
  'circle': appL10n.circle,
  'va': appL10n.voiceActor,
  'tag': appL10n.tag,
};

class BlacklistPage extends StatelessWidget {
  final AppState app;
  const BlacklistPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final p = Theme.of(context).brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light;
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.blacklist),
            leading: const BackButton(),
            actions: [
              TextButton(
                onPressed: () => _addEntry(context),
                child: Text(
                  context.l10n.add,
                  style: TextStyle(fontSize: 13, color: p.accent),
                ),
              ),
            ],
          ),
          body: app.blacklist.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.blacklistPageBuildText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: p.dim, height: 1.6),
                  ),
                )
              : SmoothListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: app.blacklist.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final e = app.blacklist[i];
                    final type = e['type'] ?? 'rj';
                    final value = e['value'] ?? '';
                    return Container(
                      padding: const EdgeInsets.fromLTRB(13, 11, 6, 11),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.line),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: p.red.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              _typeLabels[type] ?? type,
                              style: TextStyle(fontSize: 10.5, color: p.red),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => app.toggleBlacklist(type, value),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: p.dim,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _addEntry(BuildContext context) async {
    final l10n = context.l10n;
    final p = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    var type = 'rj';
    final ctrl = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: p.surface,
          title: Text(l10n.blacklistPageResultText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: _typeLabels.entries.map((e) {
                  final selected = type == e.key;
                  return ChoiceChip(
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setDlg(() => type = e.key),
                    backgroundColor: p.surface2,
                    selectedColor: p.accent.withValues(alpha: .14),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: TextStyle(fontSize: 13, color: p.text),
                decoration: InputDecoration(
                  hintText: l10n.blacklistPageResultHintText,
                  hintStyle: TextStyle(fontSize: 13, color: p.dim),
                  filled: true,
                  fillColor: p.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final v = ctrl.text.trim();
                if (v.isNotEmpty) {
                  Navigator.pop(ctx, {'type': type, 'value': v});
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      app.toggleBlacklist(result['type']!, result['value']!);
    }
  }
}
