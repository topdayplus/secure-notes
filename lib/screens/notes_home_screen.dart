import 'package:flutter/material.dart';

import '../design/app_design.dart';
import '../models/note.dart';
import '../services/app_container.dart';
import '../services/app_settings_service.dart';
import 'migration_screen.dart';
import 'note_editor_screen.dart';
import 'security_check_screen.dart';
import 'settings_screen.dart';
import '../widgets/app_scope.dart';
import '../widgets/language_menu_button.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({
    super.key,
    required this.container,
    required this.settings,
    required this.onAutoLockDelayChanged,
    required this.onStartupPasscodeEnabledChanged,
    required this.onLock,
  });

  final AppContainer container;
  final AppSettings settings;
  final Future<void> Function(int seconds) onAutoLockDelayChanged;
  final Future<void> Function(bool enabled) onStartupPasscodeEnabledChanged;
  final VoidCallback onLock;

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  final _searchController = TextEditingController();
  late Future<List<Note>> _notes;

  @override
  void initState() {
    super.initState();
    _notes = _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(strings.homeTitle),
        ),
        actions: [
          PopupMenuButton<_HomeAction>(
            tooltip: strings.moreActions,
            icon: const Icon(Icons.menu, size: 30),
            onSelected: (action) {
              switch (action) {
                case _HomeAction.settings:
                  _openSettings();
                case _HomeAction.language:
                  _showLanguageMenu();
                case _HomeAction.security:
                  _openSecurityCheck();
                case _HomeAction.migration:
                  _openMigration();
                case _HomeAction.lock:
                  widget.onLock();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HomeAction.settings,
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(strings.settings),
                ),
              ),
              PopupMenuItem(
                value: _HomeAction.language,
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(strings.languageLabel),
                ),
              ),
              PopupMenuItem(
                value: _HomeAction.security,
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(strings.securityCheck),
                ),
              ),
              PopupMenuItem(
                value: _HomeAction.migration,
                child: ListTile(
                  leading: const Icon(Icons.sync_alt),
                  title: Text(strings.offlineMigration),
                ),
              ),
              if (widget.settings.startupPasscodeEnabled != false)
                PopupMenuItem(
                  value: _HomeAction.lock,
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(strings.lockNow),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 2, 24, 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 30),
                labelText: strings.searchNotes,
              ),
              onChanged: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!;
                if (notes.isEmpty) {
                  return const _EmptyNotes();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 112),
                  itemCount: notes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == notes.length) {
                      return const _LocalStorageHint();
                    }
                    final note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _NoteCard(
                        note: note,
                        preview: _preview(note),
                        date: _formatDate(note.updatedAt),
                        onTap: () => _openEditor(note),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: strings.newNote,
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add, size: 40),
      ),
    );
  }

  Future<List<Note>> _loadNotes() {
    return widget.container.notes.listNotes(query: _searchController.text);
  }

  void _refresh() {
    setState(() {
      _notes = _loadNotes();
    });
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          settings: widget.settings,
          onAutoLockDelayChanged: widget.onAutoLockDelayChanged,
          onStartupPasscodeEnabledChanged:
              widget.onStartupPasscodeEnabledChanged,
          crypto: widget.container.crypto,
          repository: widget.container.notes,
        ),
      ),
    );
    if (changed == true && mounted) {
      _refresh();
    }
  }

  Future<void> _showLanguageMenu() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        content: const LanguageMenuButton(),
      ),
    );
  }

  Future<void> _openSecurityCheck() {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecurityCheckScreen(
          repository: widget.container.notes,
          crypto: widget.container.crypto,
        ),
      ),
    );
  }

  Future<void> _openMigration() async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MigrationScreen(repository: widget.container.notes),
      ),
    );
    if (imported == true && mounted) {
      _refresh();
    }
  }

  Future<void> _openEditor(Note? note) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            NoteEditorScreen(repository: widget.container.notes, note: note),
      ),
    );
    if (changed == true && mounted) {
      _refresh();
    }
  }

  String _preview(Note note) {
    final body = note.body.trim().replaceAll(RegExp(r'\s+'), ' ');
    return body.isEmpty ? AppScope.of(context).strings.noBody : body;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }
}

enum _HomeAction { settings, language, security, migration, lock }

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.preview,
    required this.date,
    required this.onTap,
  });

  final Note note;
  final String preview;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppDesign.radius,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
        constraints: const BoxConstraints(minHeight: 122),
        decoration: BoxDecoration(
          color: AppDesign.surface,
          borderRadius: AppDesign.radius,
          border: Border.all(color: AppDesign.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.more_vert, color: AppDesign.muted, size: 28),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppDesign.blueGrey,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              date,
              style: const TextStyle(color: AppDesign.muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalStorageHint extends StatelessWidget {
  const _LocalStorageHint();

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppDesign.muted),
          const SizedBox(width: 8),
          Text(
            strings.localEncryptedStorageHint,
            style: const TextStyle(color: AppDesign.muted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.noNotesYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
