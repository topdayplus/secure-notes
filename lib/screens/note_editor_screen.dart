import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/note.dart';
import '../services/note_repository.dart';
import '../widgets/app_scope.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.repository,
    required this.note,
  });

  final NoteRepository repository;
  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  static const _clipboardClearDelay = Duration(seconds: 30);

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final String _originalTitle;
  late final String _originalBody;
  late final FocusNode _titleFocusNode;
  bool _saving = false;
  bool _allowPop = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _originalTitle = note?.title ?? '';
    _originalBody = _initialBody(note);
    _titleController = TextEditingController(text: _originalTitle);
    _bodyController = TextEditingController(text: _originalBody);
    _titleFocusNode = FocusNode();

    if (note == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _titleFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    final isNew = widget.note == null;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _saveAndClose();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back),
            onPressed: _saving ? null : _saveAndClose,
          ),
          title: Text(isNew ? strings.newNote : strings.editNote),
          actions: [
            if (!isNew)
              IconButton(
                tooltip: strings.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _saving ? null : _confirmDelete,
              ),
            IconButton(
              tooltip: strings.save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              onPressed: _saving ? null : _saveAndClose,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: strings.optionalTitle),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      labelText: strings.privateNote,
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _copy(strings.privateNote, _bodyController.text),
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(strings.copy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(String label, String value) async {
    if (value.isEmpty) {
      return;
    }
    final strings = AppScope.of(context).strings;
    await Clipboard.setData(ClipboardData(text: value));
    _clearClipboardLater(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.copiedWithAutoClear(label, _clipboardClearDelay.inSeconds),
          ),
        ),
      );
    }
  }

  Future<void> _clearClipboardLater(String copiedValue) async {
    await Future<void>.delayed(_clipboardClearDelay);
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboard?.text == copiedValue) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  Future<void> _saveAndClose() async {
    if (_closing) {
      return;
    }
    _closing = true;

    if (!_hasChanges() || _isBlankNewNote()) {
      _popEditor(false);
      return;
    }

    setState(() => _saving = true);
    try {
      final note = widget.note;
      final title = _resolvedTitle();
      if (note == null) {
        await widget.repository.createNote(
          type: NoteType.plain,
          title: title,
          body: _bodyController.text,
        );
      } else {
        await widget.repository.updateNote(
          note,
          type: NoteType.plain,
          title: title,
          body: _bodyController.text,
        );
      }
      if (mounted) {
        _popEditor(true);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
      _closing = false;
    }
  }

  Future<void> _confirmDelete() async {
    final note = widget.note;
    if (note == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = AppScope.of(context).strings;
        return AlertDialog(
          title: Text(strings.deleteNoteQuestion),
          content: Text(strings.deleteNoteBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await widget.repository.deleteNote(note.id);
    if (mounted) {
      _popEditor(true);
    }
  }

  bool _hasChanges() {
    return _titleController.text != _originalTitle ||
        _bodyController.text != _originalBody;
  }

  bool _isBlankNewNote() {
    return widget.note == null &&
        _titleController.text.trim().isEmpty &&
        _bodyController.text.trim().isEmpty;
  }

  String _resolvedTitle() {
    final explicitTitle = _titleController.text.trim();
    if (explicitTitle.isNotEmpty) {
      return explicitTitle;
    }

    final firstLine = _bodyController.text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    if (firstLine.isEmpty) {
      return explicitTitle;
    }
    return firstLine.length <= 32 ? firstLine : firstLine.substring(0, 32);
  }

  void _popEditor(bool changed) {
    if (!mounted) {
      return;
    }
    setState(() => _allowPop = true);
    Navigator.of(context).pop(changed);
  }

  String _initialBody(Note? note) {
    if (note == null || note.type == NoteType.plain) {
      return note?.body ?? '';
    }

    final lines = <String>[];
    void addField(String label, String key) {
      final value = note.fields[key]?.trim();
      if (value != null && value.isNotEmpty) {
        lines.add('$label: $value');
      }
    }

    addField('Account', 'account');
    addField('Password', 'password');
    addField('Website', 'website');
    final remark = note.fields['remark']?.trim();
    if (remark != null && remark.isNotEmpty) {
      if (lines.isNotEmpty) {
        lines.add('');
      }
      lines.add(remark);
    } else if (note.body.trim().isNotEmpty) {
      if (lines.isNotEmpty) {
        lines.add('');
      }
      lines.add(note.body.trim());
    }
    return lines.join('\n');
  }
}
