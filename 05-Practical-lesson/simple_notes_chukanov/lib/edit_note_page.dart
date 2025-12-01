import 'package:flutter/material.dart';
import 'models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note? existing;
  const EditNotePage({super.key, this.existing});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _bodyController.text = widget.existing!.body;
    }
    
    // Слушатели изменений для отслеживания редактирования
    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_isEdited) {
      setState(() => _isEdited = true);
    }
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;
    
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    final result = (widget.existing == null)
        ? Note(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            body: body,
          )
        : Note.copyWith(
            note: widget.existing!,
            title: title,
            body: body,
          );

    Navigator.pop(context, result);
  }

  void _cancel() {
    if (_isEdited) {
      _showCancelConfirmation();
    } else {
      Navigator.pop(context);
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить изменения?'),
        content: const Text('Все несохраненные изменения будут потеряны.'),
        backgroundColor: Colors.orange.shade50,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Продолжить',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 0, 0, 0)),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_isEdited) {
          _showCancelConfirmation();
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Редактировать заметку' : 'Новая заметка'),
          backgroundColor: Colors.orange.shade500,
          actions: [
            if (_isEdited) ...[
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _saveNote,
                tooltip: 'Сохранить',
              ),
            ],
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Заголовок',
                    labelStyle: TextStyle(color: Colors.orange.shade700),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                    ),
                    hintText: 'Введите заголовок заметки',
                    hintStyle: TextStyle(color: Colors.orange.shade400),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: 'Текст заметки',
                      labelStyle: TextStyle(color: Colors.orange.shade700),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                      ),
                      hintText: 'Начните вводить текст...',
                      hintStyle: TextStyle(color: Colors.orange.shade400),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите текст заметки';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (isEdit && widget.existing != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Создано: ${_formatDate(widget.existing!.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Изменено: ${_formatDate(widget.existing!.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveNote,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20),
                        SizedBox(width: 8),
                        Text('Сохранить заметку'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _cancel,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade800,
                    ),
                    child: const Text('Отменить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}