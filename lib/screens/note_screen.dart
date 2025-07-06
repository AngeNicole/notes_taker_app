import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_app/providers/note_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/add_note_dialog.dart';
import '../utils/message_helper.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                await ref.read(notesProvider.notifier).loadNotes();
                if (context.mounted) {
                  MessageHelper.showSuccess(context, 'Notes refreshed!');
                }
              } catch (e) {
                if (context.mounted) {
                  MessageHelper.showError(context, 'Failed to refresh: $e');
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                ref.invalidate(isAuthenticatedProvider);
                MessageHelper.showSuccess(context, 'Signed out successfully!');
              }
            },
          ),
        ],
      ),
      body: notesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesState.notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nothing here yet—tap ➕ to add a note.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(notesProvider.notifier).loadNotes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notesState.notes.length,
                itemBuilder: (context, index) {
                  final note = notesState.notes[index];
                  return NoteCard(
                    key: ValueKey(note.id),
                    note: note,
                    onEdit: (updatedText) =>
                        _handleUpdateNote(context, ref, note.id, updatedText),
                    onDelete: () => _showDeleteDialog(context, ref, note.id),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddNoteDialog(
              onSave: (text) => _handleAddNote(context, ref, text),
            ),
          );
        },
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAddNote(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    try {
      await ref.read(notesProvider.notifier).addNote(text);
      if (context.mounted) {
        MessageHelper.showSuccess(context, 'Note added successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        MessageHelper.showError(context, 'Failed to add note: $e');
      }
    }
  }

  Future<void> _handleUpdateNote(
    BuildContext context,
    WidgetRef ref,
    String id,
    String text,
  ) async {
    try {
      await ref.read(notesProvider.notifier).updateNote(id, text);
      if (context.mounted) {
        MessageHelper.showSuccess(context, 'Note updated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        MessageHelper.showError(context, 'Failed to update note: $e');
      }
    }
  }

  Future<void> _handleDeleteNote(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(notesProvider.notifier).deleteNote(id);
      if (context.mounted) {
        MessageHelper.showSuccess(context, 'Note deleted successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        MessageHelper.showError(context, 'Failed to delete note: $e');
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteNote(context, ref, noteId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
