import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';

class NotesState {
  final List<Note> notes;
  final bool isLoading;

  const NotesState({this.notes = const [], this.isLoading = false});

  NotesState copyWith({List<Note>? notes, bool? isLoading}) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final NoteRepository _noteRepository;

  NotesNotifier(this._noteRepository) : super(const NotesState()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final notes = await _noteRepository.fetchNotes();
      state = NotesState(notes: [...notes], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow; // Let the UI handle the error
    }
  }

  Future<void> addNote(String text) async {
    try {
      await _noteRepository.addNote(text);
      // Refresh immediately
      final notes = await _noteRepository.fetchNotes();
      state = NotesState(notes: [...notes], isLoading: false);
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }

  Future<void> updateNote(String id, String text) async {
    try {
      await _noteRepository.updateNote(id, text);
      // Refresh immediately
      final notes = await _noteRepository.fetchNotes();
      state = NotesState(notes: [...notes], isLoading: false);
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _noteRepository.deleteNote(id);
      // Refresh immediately
      final notes = await _noteRepository.fetchNotes();
      state = NotesState(notes: [...notes], isLoading: false);
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final noteRepository = ref.watch(noteRepositoryProvider);
  return NotesNotifier(noteRepository);
});
