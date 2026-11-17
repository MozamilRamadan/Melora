import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/data/models/song_playlist.dart';
import 'package:music_player/services/playlists_service.dart';

class PlaylistsScreen extends StatelessWidget {
  final List<SongModel> songs;
  final PlaylistsService playlists;
  final ValueChanged<List<SongModel>> onPlayPlaylist;
  const PlaylistsScreen({
    super.key,
    required this.songs,
    required this.playlists,
    required this.onPlayPlaylist,
  });

  Future<void> _nameDialog(
    BuildContext context, {
    String initial = '',
    required String title,
    required ValueChanged<String> onSave,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _PlaylistNameDialog(
        title: title,
        initial: initial,
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      onSave(result.trim());
    }
  }

  List<SongModel> _resolve(SongPlaylist p) {
    final byId = {for (final s in songs) s.id: s};
    return p.songIds.map((id) => byId[id]).whereType<SongModel>().toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppStyle.backgroundColor,
    appBar: AppBar(
      backgroundColor: AppStyle.backgroundColor,
      iconTheme: const IconThemeData(color: AppStyle.goldColor),
      title: const Text(
        'Playlists',
        style: TextStyle(
          color: AppStyle.goldColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          color: AppStyle.goldColor,
          tooltip: 'Create playlist',
          onPressed: () => _nameDialog(
            context,
            title: 'New playlist',
            onSave: (v) => playlists.create(v),
          ),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: playlists,
      builder: (context, _) {
        final items = playlists.playlists;
        if (items.isEmpty)
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.queue_music_rounded,
                  color: AppStyle.goldColor,
                  size: 64,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your playlists start here',
                  style: TextStyle(
                    color: AppStyle.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a playlist for every mood.',
                  style: TextStyle(color: AppStyle.secondaryTextColor),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => _nameDialog(
                    context,
                    title: 'New playlist',
                    onSave: (v) => playlists.create(v),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create playlist'),
                ),
              ],
            ),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = items[i];
            final resolved = _resolve(p);
            return Material(
              color: AppStyle.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: _Cover(songs: resolved),
                title: Text(
                  p.name,
                  style: const TextStyle(
                    color: AppStyle.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${resolved.length} songs',
                  style: const TextStyle(color: AppStyle.secondaryTextColor),
                ),
                trailing: PopupMenuButton<String>(
                  color: AppStyle.surfaceColor,
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppStyle.secondaryTextColor,
                  ),
                  onSelected: (v) async {
                    if (v == 'rename')
                      await _nameDialog(
                        context,
                        title: 'Rename playlist',
                        initial: p.name,
                        onSave: (name) => playlists.rename(p.id, name),
                      );
                    if (v == 'delete') await playlists.delete(p.id);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _PlaylistDetail(
                      playlist: p,
                      songs: songs,
                      service: playlists,
                      onPlay: onPlayPlaylist,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _PlaylistNameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _PlaylistNameDialog({
    required this.title,
    required this.initial,
  });

  @override
  State<_PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<_PlaylistNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppStyle.surfaceColor,
      title: Text(
        widget.title,
        style: const TextStyle(color: AppStyle.goldColor),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: AppStyle.textColor),
        decoration: const InputDecoration(hintText: 'Playlist name'),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  final List<SongModel> songs;
  const _Cover({required this.songs});
  @override
  Widget build(BuildContext context) {
    final art = songs.isNotEmpty ? songs.first.artwork : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        width: 58,
        height: 58,
        child: art != null && art.isNotEmpty
            ? Image.memory(art, fit: BoxFit.cover)
            : Container(
                color: AppStyle.deepPurpleColor,
                child: const Icon(
                  Icons.queue_music_rounded,
                  color: AppStyle.goldColor,
                  size: 30,
                ),
              ),
      ),
    );
  }
}

class _PlaylistDetail extends StatelessWidget {
  final SongPlaylist playlist;
  final List<SongModel> songs;
  final PlaylistsService service;
  final ValueChanged<List<SongModel>> onPlay;
  const _PlaylistDetail({
    required this.playlist,
    required this.songs,
    required this.service,
    required this.onPlay,
  });

  List<SongModel> get items {
    final byId = {for (final s in songs) s.id: s};
    return playlist.songIds
        .map((id) => byId[id])
        .whereType<SongModel>()
        .toList();
  }

  Future<void> _addSongs(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyle.surfaceColor,
      builder: (_) =>
          _AddSongsSheet(songs: songs, playlist: playlist, service: service),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppStyle.backgroundColor,
    appBar: AppBar(
      backgroundColor: AppStyle.backgroundColor,
      iconTheme: const IconThemeData(color: AppStyle.goldColor),
      title: Text(
        playlist.name,
        style: const TextStyle(color: AppStyle.goldColor),
      ),
      actions: [
        IconButton(
          onPressed: () => _addSongs(context),
          icon: const Icon(Icons.add),
          color: AppStyle.goldColor,
          tooltip: 'Add songs',
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final current = items;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${current.length} songs',
                      style: const TextStyle(
                        color: AppStyle.secondaryTextColor,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: current.isEmpty ? null : () => onPlay(current),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play all'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: current.isEmpty
                  ? const Center(
                      child: Text(
                        'This playlist is empty. Add some songs.',
                        style: TextStyle(color: AppStyle.secondaryTextColor),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: current.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final song = current[i];
                        return ListTile(
                          tileColor: AppStyle.surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: const Icon(
                            Icons.music_note,
                            color: AppStyle.purpleColor,
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(color: AppStyle.textColor),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(
                              color: AppStyle.secondaryTextColor,
                            ),
                          ),
                          onTap: () => onPlay(current),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppStyle.secondaryTextColor,
                            onPressed: () =>
                                service.removeSong(playlist.id, song.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _AddSongsSheet extends StatefulWidget {
  final List<SongModel> songs;
  final SongPlaylist playlist;
  final PlaylistsService service;
  const _AddSongsSheet({
    required this.songs,
    required this.playlist,
    required this.service,
  });
  @override
  State<_AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends State<_AddSongsSheet> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final available = widget.songs
        .where(
          (s) =>
              !widget.playlist.songIds.contains(s.id) &&
              (s.title.toLowerCase().contains(query.toLowerCase()) ||
                  s.artist.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .78,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add songs',
                style: TextStyle(
                  color: AppStyle.goldColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                style: const TextStyle(color: AppStyle.textColor),
                decoration: const InputDecoration(
                  hintText: 'Search songs or artists',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: available.isEmpty
                  ? const Center(
                      child: Text(
                        'No more songs to add',
                        style: TextStyle(color: AppStyle.secondaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: available.length,
                      itemBuilder: (context, i) {
                        final s = available[i];
                        return ListTile(
                          leading: const Icon(
                            Icons.music_note,
                            color: AppStyle.purpleColor,
                          ),
                          title: Text(
                            s.title,
                            style: const TextStyle(color: AppStyle.textColor),
                          ),
                          subtitle: Text(
                            s.artist,
                            style: const TextStyle(
                              color: AppStyle.secondaryTextColor,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: AppStyle.goldColor,
                            onPressed: () async {
                              await widget.service.addSong(
                                widget.playlist.id,
                                s.id,
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
