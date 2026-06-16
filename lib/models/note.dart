enum NoteType {
  plain('plain'),
  credential('credential');

  const NoteType(this.value);

  final String value;

  static NoteType fromValue(String value) {
    return NoteType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NoteType.plain,
    );
  }
}

class Note {
  const Note({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final NoteType type;
  final String title;
  final String body;
  final Map<String, String> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    NoteType? type,
    String? title,
    String? body,
    Map<String, String>? fields,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      fields: fields ?? this.fields,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
