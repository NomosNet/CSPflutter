import 'package:flutter/material.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() => runApp(const SimpleNotesApp());

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [
    Note(id: '1', title: 'Добро пожаловать!', body: 'Это ваша первая заметка. Нажмите + чтобы добавить новую.'),
    Note(id: '2', title: 'Список покупок', body: 'Молоко, хлеб, яйца, фрукты'),
  ];
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    
    return _notes.where((note) =>
      note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      note.body.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Поиск заметок...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchController.text.isEmpty) {
              _stopSearch();
            } else {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            }
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
      ];
    }
  }

  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const EditNotePage()),
    );
    
    if (newNote != null && mounted) {
      setState(() {
        _notes.insert(0, newNote);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Заметка создана'),
          backgroundColor: Colors.orange.shade700,
          action: SnackBarAction(
            label: 'Отменить',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _notes.remove(newNote));
            },
          ),
        ),
      );
    }
  }

  Future<void> _editNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );
    
    if (updatedNote != null && mounted) {
      setState(() {
        final index = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
      });
    }
  }

  void _deleteNote(Note note, {bool showSnackBar = true}) {
    final deletedIndex = _notes.indexWhere((n) => n.id == note.id);
    
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Заметка удалена'),
          backgroundColor: Colors.orange.shade700,
          action: SnackBarAction(
            label: 'Отменить',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _notes.insert(deletedIndex, note);
              });
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildNoteCard(Note note, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.orange.shade50,
      child: Dismissible(
        key: ValueKey(note.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        secondaryBackground: Container(
          color: Colors.orange.shade600,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.archive, color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await _showDeleteConfirmation(note);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Функция архивации в разработке'),
                backgroundColor: Colors.orange.shade700,
              ),
            );
            return false;
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            _deleteNote(note, showSnackBar: false);
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_outlined,
              color: Colors.orange.shade800,
              size: 20,
            ),
          ),
          title: Text(
            note.title.isEmpty ? '(без названия)' : note.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.orange.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                'Изменено: ${_formatDate(note.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.orange.shade600),
            onPressed: () => _showDeleteConfirmation(note).then((confirmed) {
              if (confirmed == true) {
                _deleteNote(note);
              }
            }),
          ),
          onTap: () => _editNote(note),
          onLongPress: () {
            _showNoteContextMenu(note, context);
          },
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Note note) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text('Заметка "${note.title.isEmpty ? '(без названия)' : note.title}" будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showNoteContextMenu(Note note, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.orange.shade700),
              title: Text('Редактировать', style: TextStyle(color: Colors.orange.shade800)),
              onTap: () {
                Navigator.pop(context);
                _editNote(note);
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, color: Colors.orange.shade700),
              title: Text('Дублировать', style: TextStyle(color: Colors.orange.shade800)),
              onTap: () {
                Navigator.pop(context);
                _duplicateNote(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(note).then((confirmed) {
                  if (confirmed == true) {
                    _deleteNote(note);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateNote(Note note) {
    final duplicatedNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${note.title} (копия)',
      body: note.body,
    );
    
    setState(() {
      _notes.insert(0, duplicatedNote);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Заметка дублирована'),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes} мин назад';
    if (difference.inDays < 1) return '${difference.inHours} ч назад';
    if (difference.inDays == 1) return 'вчера';
    if (difference.inDays < 7) return '${difference.inDays} д назад';
    
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Мои заметки'),
        backgroundColor: Colors.orange.shade500,
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Всего заметок: ${_notes.length}',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Найдено: ${_filteredNotes.length}',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Список заметок
          Expanded(
            child: _filteredNotes.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {});
                    },
                    child: ListView.builder(
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = _filteredNotes[index];
                        return _buildNoteCard(note, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _isSearching ? null : FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.orange.shade500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Пока нет заметок' : 'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Нажмите + чтобы создать первую заметку'
                : 'Попробуйте изменить поисковый запрос',
            style: TextStyle(color: Colors.orange.shade600),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                _stopSearch();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade300,
                foregroundColor: Colors.orange.shade900,
              ),
              child: const Text('Показать все заметки'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}