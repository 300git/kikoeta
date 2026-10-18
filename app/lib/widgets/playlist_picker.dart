import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// 歌单选择结果：`playlist == null` 表示选中了「我的收藏」。
class PlaylistPick {
  final PlaylistInfo? playlist;
  const PlaylistPick(this.playlist);
}

/// 打开歌单切换/选择面板。
///
/// [showFavorites] 为 true 时顶部显示「我的收藏」（收藏页使用）；
/// 作品详情页的「添加到播放列表」传 false，只列出播放列表。
Future<PlaylistPick?> showPlaylistPicker(
  BuildContext context, {
  required AppState app,
  bool showFavorites = true,
  bool reviewsMode = false,
  String? currentId,
}) {
  return showModalBottomSheet<PlaylistPick>(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark.surface
        : AppColors.light.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PlaylistPickerSheet(
      app: app,
      showFavorites: showFavorites,
      reviewsMode: reviewsMode,
      currentId: currentId,
    ),
  );
}

/// 创建/编辑播放列表对话框的返回值。
class _PlaylistEditInput {
  final String? name;
  final String description;
  final int privacy;
  final bool delete;

  const _PlaylistEditInput.save({
    required this.name,
    required this.description,
    required this.privacy,
  }) : delete = false;

  const _PlaylistEditInput.delete()
    : name = null,
      description = '',
      privacy = 0,
      delete = true;
}

class _PlaylistPickerSheet extends StatefulWidget {
  final AppState app;
  final bool showFavorites;
  final bool reviewsMode;
  final String? currentId;

  const _PlaylistPickerSheet({
    required this.app,
    required this.showFavorites,
    required this.reviewsMode,
    this.currentId,
  });

  @override
  State<_PlaylistPickerSheet> createState() => _PlaylistPickerSheetState();
}

class _PlaylistPickerSheetState extends State<_PlaylistPickerSheet> {
  List<PlaylistInfo> _list = const [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  AppState get app => widget.app;
  Palette get p => Theme.of(context).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService.fetchPlaylists(app);
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '无法加载播放列表';
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final list = await ApiService.fetchPlaylists(app);
      if (!mounted) return;
      setState(() => _list = list);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copyLink(PlaylistInfo pl) {
    Clipboard.setData(ClipboardData(text: ApiService.playlistShareLink(pl.id)));
    _toast('已复制分享链接');
  }

  Future<void> _showDetails(PlaylistInfo pl) async {
    var info = pl;
    try {
      info = await ApiService.fetchPlaylistMetadata(app, pl.id);
    } catch (_) {
      // 详情接口不可用时退回列表里的信息。
    }
    if (!mounted) return;
    final rows = <MapEntry<String, String>>[
      MapEntry('UUID', info.id),
      MapEntry('名称', info.name),
      MapEntry('描述', info.description.isEmpty ? ' ' : info.description),
      MapEntry('创建人', info.userName),
      MapEntry('权限', ApiService.playlistPrivacyLabel(info.privacy)),
      MapEntry('语言', info.locale.isEmpty ? ' ' : info.locale),
      MapEntry('播放次数', '${info.playbackCount}'),
      MapEntry('创建时间', info.createdAt),
      MapEntry('更新时间', info.updatedAt),
      MapEntry('作品数量', '${info.worksCount}'),
    ];
    final copy = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('歌单详情'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 68,
                          child: Text(
                            row.key,
                            style: TextStyle(fontSize: 12, color: p.dim),
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            row.value,
                            style: TextStyle(fontSize: 12.5, color: p.text),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('复制链接'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (copy == true) _copyLink(info);
  }

  Future<_PlaylistEditInput?> _showEditor(PlaylistInfo? playlist) async {
    final nameCtrl = TextEditingController(text: playlist?.name ?? '');
    final descCtrl = TextEditingController(text: playlist?.description ?? '');
    var privacy = playlist?.privacy ?? 0;
    return showDialog<_PlaylistEditInput>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: p.surface,
          title: Text(playlist == null ? '创建播放列表' : '编辑播放列表'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    maxLength: 100,
                    style: TextStyle(fontSize: 13, color: p.text),
                    decoration: InputDecoration(
                      labelText: '名称',
                      filled: true,
                      fillColor: p.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    style: TextStyle(fontSize: 13, color: p.text),
                    decoration: InputDecoration(
                      labelText: '描述',
                      filled: true,
                      fillColor: p.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: privacy,
                    decoration: InputDecoration(
                      labelText: '类型',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    items: [
                      for (final entry
                          in ApiService.playlistPrivacyLabels.entries)
                        DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                    ],
                    onChanged: (value) => setLocal(() => privacy = value ?? 0),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            if (playlist != null && !playlist.isSystem)
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, const _PlaylistEditInput.delete()),
                child: Text(
                  '删除',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              )
            else
              const SizedBox.shrink(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(
                      ctx,
                      _PlaylistEditInput.save(
                        name: name,
                        description: descCtrl.text.trim(),
                        privacy: privacy,
                      ),
                    );
                  },
                  child: const Text('确认'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylist() async {
    if (_busy) return;
    final input = await _showEditor(null);
    if (input == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final beforeIds = _list.map((e) => e.id).toSet();
      await ApiService.createPlaylist(
        app,
        name: input.name ?? '未命名歌单',
        description: input.description,
        privacy: input.privacy,
      );
      final list = await ApiService.fetchPlaylists(app);
      if (!mounted) return;
      PlaylistInfo? created;
      for (final pl in list) {
        if (!beforeIds.contains(pl.id)) {
          created = pl;
          break;
        }
      }
      if (created == null || created.id.isEmpty) {
        setState(() {
          _list = list;
          _busy = false;
        });
        _toast('已创建，但列表中未找到该播放列表');
        return;
      }
      Navigator.of(context).pop(PlaylistPick(created));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('创建失败：$e');
    }
  }

  Future<void> _editPlaylist(PlaylistInfo pl) async {
    if (_busy) return;
    final input = await _showEditor(pl);
    if (input == null || !mounted) return;
    if (input.delete) {
      await _deletePlaylist(pl);
      return;
    }
    setState(() => _busy = true);
    try {
      await ApiService.editPlaylist(
        app,
        id: pl.id,
        name: input.name ?? pl.name,
        description: input.description,
        privacy: input.privacy,
      );
      final updated = await ApiService.fetchPlaylistMetadata(app, pl.id);
      if (!mounted) return;
      if (widget.currentId == pl.id) {
        Navigator.of(context).pop(PlaylistPick(updated));
        return;
      }
      setState(() => _busy = false);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('保存失败：$e');
    }
  }

  Future<void> _deletePlaylist(PlaylistInfo pl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('删除播放列表'),
        content: Text('确定删除“${pl.name}”吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ApiService.deletePlaylist(app, pl.id);
      if (!mounted) return;
      if (widget.currentId == pl.id) {
        Navigator.of(context).pop(const PlaylistPick(null));
        return;
      }
      setState(() => _busy = false);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('删除失败：$e');
    }
  }

  Future<void> _removeLiked(PlaylistInfo pl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('移除播放列表'),
        content: Text('确定从我的播放列表中移除“${pl.name}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ApiService.removeLikedPlaylist(app, pl.id);
      if (!mounted) return;
      if (widget.currentId == pl.id) {
        Navigator.of(context).pop(const PlaylistPick(null));
        return;
      }
      setState(() => _busy = false);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('移除失败：$e');
    }
  }

  Future<void> _importPlaylist() async {
    if (_busy) return;
    final ctrl = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('导入播放列表'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              style: TextStyle(fontSize: 13, color: p.text),
              decoration: InputDecoration(
                labelText: '分享链接',
                hintText: 'https://www.asmr.one/playlist/…',
                filled: true,
                fillColor: p.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '粘贴别人分享的播放列表链接，会收藏到我的播放列表。',
              style: TextStyle(fontSize: 11.5, color: p.dim),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
    if (link == null || !mounted) return;
    final id = ApiService.playlistIdFromLink(link);
    if (id == null) {
      _toast('无法识别播放列表链接');
      return;
    }
    setState(() => _busy = true);
    try {
      await ApiService.importPlaylist(app, id);
      final list = await ApiService.fetchPlaylists(app);
      if (!mounted) return;
      PlaylistInfo? imported;
      for (final pl in list) {
        if (pl.id == id) {
          imported = pl;
          break;
        }
      }
      if (imported == null) {
        setState(() {
          _list = list;
          _busy = false;
        });
        _toast('已添加，但列表中暂未找到该播放列表');
        return;
      }
      Navigator.of(context).pop(PlaylistPick(imported));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('导入失败：$e');
    }
  }

  Widget _leading({required String? coverUrl, required IconData icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: coverUrl != null
            ? Image(
                image: ResizeImage.resizeIfNeeded(
                  128,
                  null,
                  RustImageProvider(coverUrl),
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _iconBox(icon),
              )
            : _iconBox(icon),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      color: p.surface2,
      child: Icon(icon, size: 18, color: p.accent),
    );
  }

  Widget _row({
    required Widget leading,
    required String name,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    Widget? trailing,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: _busy ? null : onTap,
      onLongPress: _busy ? null : onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: p.dim),
                  ),
                ],
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.check_circle, size: 18, color: p.accent),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _reviewsItem() {
    return _row(
      leading: _iconBox(Icons.favorite),
      name: '我的收藏',
      subtitle: '我的评价/收藏（所有作品）',
      selected: widget.reviewsMode,
      onTap: () => Navigator.of(context).pop(const PlaylistPick(null)),
    );
  }

  Widget _playlistItem(PlaylistInfo pl) {
    final subtitle = pl.description.isNotEmpty
        ? '${pl.worksCount} 个作品 · ${pl.description.replaceAll('\n', ' ')}'
        : '${pl.worksCount} 个作品';
    return _row(
      leading: _leading(coverUrl: pl.coverUrl, icon: Icons.folder_outlined),
      name: pl.name,
      subtitle: subtitle,
      selected: !widget.reviewsMode && pl.id == widget.currentId,
      onTap: () => Navigator.of(context).pop(PlaylistPick(pl)),
      onLongPress: () => _showDetails(pl),
      trailing: pl.isOwned
          ? IconButton(
              onPressed: _busy ? null : () => _editPlaylist(pl),
              tooltip: '编辑播放列表',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.edit_outlined, size: 18, color: p.dim),
            )
          : IconButton(
              onPressed: _busy ? null : () => _removeLiked(pl),
              tooltip: '移除播放列表',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.delete_outline, size: 18, color: p.dim),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '切换播放列表',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _createPlaylist,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新建', style: TextStyle(fontSize: 12.5)),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _importPlaylist,
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('导入', style: TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_loading && _list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              )
            else if (_error != null && _list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(_error!, style: TextStyle(fontSize: 13, color: p.dim)),
                    TextButton(onPressed: _load, child: const Text('重试')),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: [
                    if (widget.showFavorites) ...[
                      _reviewsItem(),
                      const Divider(height: 1),
                    ],
                    for (final pl in _list) _playlistItem(pl),
                  ],
                ),
              ),
            if (_busy)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: p.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
