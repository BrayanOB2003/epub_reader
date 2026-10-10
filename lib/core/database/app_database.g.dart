// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverBytesMeta = const VerificationMeta(
    'coverBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> coverBytes = GeneratedColumn<Uint8List>(
    'cover_bytes',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bookUidMeta = const VerificationMeta(
    'bookUid',
  );
  @override
  late final GeneratedColumn<String> bookUid = GeneratedColumn<String>(
    'book_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locatorJsonMeta = const VerificationMeta(
    'locatorJson',
  );
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
    'locator_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _darkModeMeta = const VerificationMeta(
    'darkMode',
  );
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
    'dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scrollModeMeta = const VerificationMeta(
    'scrollMode',
  );
  @override
  late final GeneratedColumn<bool> scrollMode = GeneratedColumn<bool>(
    'scroll_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scroll_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
    'font_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    filePath,
    coverPath,
    coverBytes,
    contentHash,
    bookUid,
    locatorJson,
    progress,
    darkMode,
    scrollMode,
    fontSize,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('cover_bytes')) {
      context.handle(
        _coverBytesMeta,
        coverBytes.isAcceptableOrUnknown(data['cover_bytes']!, _coverBytesMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('book_uid')) {
      context.handle(
        _bookUidMeta,
        bookUid.isAcceptableOrUnknown(data['book_uid']!, _bookUidMeta),
      );
    }
    if (data.containsKey('locator_json')) {
      context.handle(
        _locatorJsonMeta,
        locatorJson.isAcceptableOrUnknown(
          data['locator_json']!,
          _locatorJsonMeta,
        ),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('dark_mode')) {
      context.handle(
        _darkModeMeta,
        darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta),
      );
    }
    if (data.containsKey('scroll_mode')) {
      context.handle(
        _scrollModeMeta,
        scrollMode.isAcceptableOrUnknown(data['scroll_mode']!, _scrollModeMeta),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      coverBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}cover_bytes'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
      bookUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_uid'],
      ),
      locatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_json'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      darkMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dark_mode'],
      )!,
      scrollMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scroll_mode'],
      )!,
      fontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}font_size'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String? author;
  final String filePath;
  final String? coverPath;
  final Uint8List? coverBytes;
  final String? contentHash;
  final String? bookUid;
  final String? locatorJson;
  final double progress;
  final bool darkMode;
  final bool scrollMode;
  final double fontSize;
  final DateTime addedAt;
  const Book({
    required this.id,
    required this.title,
    this.author,
    required this.filePath,
    this.coverPath,
    this.coverBytes,
    this.contentHash,
    this.bookUid,
    this.locatorJson,
    required this.progress,
    required this.darkMode,
    required this.scrollMode,
    required this.fontSize,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || coverBytes != null) {
      map['cover_bytes'] = Variable<Uint8List>(coverBytes);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    if (!nullToAbsent || bookUid != null) {
      map['book_uid'] = Variable<String>(bookUid);
    }
    if (!nullToAbsent || locatorJson != null) {
      map['locator_json'] = Variable<String>(locatorJson);
    }
    map['progress'] = Variable<double>(progress);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['scroll_mode'] = Variable<bool>(scrollMode);
    map['font_size'] = Variable<double>(fontSize);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      filePath: Value(filePath),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      coverBytes: coverBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(coverBytes),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      bookUid: bookUid == null && nullToAbsent
          ? const Value.absent()
          : Value(bookUid),
      locatorJson: locatorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(locatorJson),
      progress: Value(progress),
      darkMode: Value(darkMode),
      scrollMode: Value(scrollMode),
      fontSize: Value(fontSize),
      addedAt: Value(addedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      filePath: serializer.fromJson<String>(json['filePath']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      coverBytes: serializer.fromJson<Uint8List?>(json['coverBytes']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      bookUid: serializer.fromJson<String?>(json['bookUid']),
      locatorJson: serializer.fromJson<String?>(json['locatorJson']),
      progress: serializer.fromJson<double>(json['progress']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      scrollMode: serializer.fromJson<bool>(json['scrollMode']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'filePath': serializer.toJson<String>(filePath),
      'coverPath': serializer.toJson<String?>(coverPath),
      'coverBytes': serializer.toJson<Uint8List?>(coverBytes),
      'contentHash': serializer.toJson<String?>(contentHash),
      'bookUid': serializer.toJson<String?>(bookUid),
      'locatorJson': serializer.toJson<String?>(locatorJson),
      'progress': serializer.toJson<double>(progress),
      'darkMode': serializer.toJson<bool>(darkMode),
      'scrollMode': serializer.toJson<bool>(scrollMode),
      'fontSize': serializer.toJson<double>(fontSize),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    Value<String?> author = const Value.absent(),
    String? filePath,
    Value<String?> coverPath = const Value.absent(),
    Value<Uint8List?> coverBytes = const Value.absent(),
    Value<String?> contentHash = const Value.absent(),
    Value<String?> bookUid = const Value.absent(),
    Value<String?> locatorJson = const Value.absent(),
    double? progress,
    bool? darkMode,
    bool? scrollMode,
    double? fontSize,
    DateTime? addedAt,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    filePath: filePath ?? this.filePath,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    coverBytes: coverBytes.present ? coverBytes.value : this.coverBytes,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    bookUid: bookUid.present ? bookUid.value : this.bookUid,
    locatorJson: locatorJson.present ? locatorJson.value : this.locatorJson,
    progress: progress ?? this.progress,
    darkMode: darkMode ?? this.darkMode,
    scrollMode: scrollMode ?? this.scrollMode,
    fontSize: fontSize ?? this.fontSize,
    addedAt: addedAt ?? this.addedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      coverBytes: data.coverBytes.present
          ? data.coverBytes.value
          : this.coverBytes,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      bookUid: data.bookUid.present ? data.bookUid.value : this.bookUid,
      locatorJson: data.locatorJson.present
          ? data.locatorJson.value
          : this.locatorJson,
      progress: data.progress.present ? data.progress.value : this.progress,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      scrollMode: data.scrollMode.present
          ? data.scrollMode.value
          : this.scrollMode,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('coverBytes: $coverBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('bookUid: $bookUid, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('progress: $progress, ')
          ..write('darkMode: $darkMode, ')
          ..write('scrollMode: $scrollMode, ')
          ..write('fontSize: $fontSize, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    filePath,
    coverPath,
    $driftBlobEquality.hash(coverBytes),
    contentHash,
    bookUid,
    locatorJson,
    progress,
    darkMode,
    scrollMode,
    fontSize,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.filePath == this.filePath &&
          other.coverPath == this.coverPath &&
          $driftBlobEquality.equals(other.coverBytes, this.coverBytes) &&
          other.contentHash == this.contentHash &&
          other.bookUid == this.bookUid &&
          other.locatorJson == this.locatorJson &&
          other.progress == this.progress &&
          other.darkMode == this.darkMode &&
          other.scrollMode == this.scrollMode &&
          other.fontSize == this.fontSize &&
          other.addedAt == this.addedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> filePath;
  final Value<String?> coverPath;
  final Value<Uint8List?> coverBytes;
  final Value<String?> contentHash;
  final Value<String?> bookUid;
  final Value<String?> locatorJson;
  final Value<double> progress;
  final Value<bool> darkMode;
  final Value<bool> scrollMode;
  final Value<double> fontSize;
  final Value<DateTime> addedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.filePath = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.coverBytes = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.bookUid = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.progress = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.scrollMode = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    required String filePath,
    this.coverPath = const Value.absent(),
    this.coverBytes = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.bookUid = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.progress = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.scrollMode = const Value.absent(),
    this.fontSize = const Value.absent(),
    required DateTime addedAt,
  }) : title = Value(title),
       filePath = Value(filePath),
       addedAt = Value(addedAt);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? filePath,
    Expression<String>? coverPath,
    Expression<Uint8List>? coverBytes,
    Expression<String>? contentHash,
    Expression<String>? bookUid,
    Expression<String>? locatorJson,
    Expression<double>? progress,
    Expression<bool>? darkMode,
    Expression<bool>? scrollMode,
    Expression<double>? fontSize,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (filePath != null) 'file_path': filePath,
      if (coverPath != null) 'cover_path': coverPath,
      if (coverBytes != null) 'cover_bytes': coverBytes,
      if (contentHash != null) 'content_hash': contentHash,
      if (bookUid != null) 'book_uid': bookUid,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (progress != null) 'progress': progress,
      if (darkMode != null) 'dark_mode': darkMode,
      if (scrollMode != null) 'scroll_mode': scrollMode,
      if (fontSize != null) 'font_size': fontSize,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? filePath,
    Value<String?>? coverPath,
    Value<Uint8List?>? coverBytes,
    Value<String?>? contentHash,
    Value<String?>? bookUid,
    Value<String?>? locatorJson,
    Value<double>? progress,
    Value<bool>? darkMode,
    Value<bool>? scrollMode,
    Value<double>? fontSize,
    Value<DateTime>? addedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      coverBytes: coverBytes ?? this.coverBytes,
      contentHash: contentHash ?? this.contentHash,
      bookUid: bookUid ?? this.bookUid,
      locatorJson: locatorJson ?? this.locatorJson,
      progress: progress ?? this.progress,
      darkMode: darkMode ?? this.darkMode,
      scrollMode: scrollMode ?? this.scrollMode,
      fontSize: fontSize ?? this.fontSize,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (coverBytes.present) {
      map['cover_bytes'] = Variable<Uint8List>(coverBytes.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (bookUid.present) {
      map['book_uid'] = Variable<String>(bookUid.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (scrollMode.present) {
      map['scroll_mode'] = Variable<bool>(scrollMode.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('coverBytes: $coverBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('bookUid: $bookUid, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('progress: $progress, ')
          ..write('darkMode: $darkMode, ')
          ..write('scrollMode: $scrollMode, ')
          ..write('fontSize: $fontSize, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engagedSecondsMeta = const VerificationMeta(
    'engagedSeconds',
  );
  @override
  late final GeneratedColumn<int> engagedSeconds = GeneratedColumn<int>(
    'engaged_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    startedAt,
    endedAt,
    engagedSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('engaged_seconds')) {
      context.handle(
        _engagedSecondsMeta,
        engagedSeconds.isAcceptableOrUnknown(
          data['engaged_seconds']!,
          _engagedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engagedSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      engagedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}engaged_seconds'],
      )!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final int bookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int engagedSeconds;
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.endedAt,
    required this.engagedSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['engaged_seconds'] = Variable<int>(engagedSeconds);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      engagedSeconds: Value(engagedSeconds),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      engagedSeconds: serializer.fromJson<int>(json['engagedSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'engagedSeconds': serializer.toJson<int>(engagedSeconds),
    };
  }

  ReadingSession copyWith({
    int? id,
    int? bookId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? engagedSeconds,
  }) => ReadingSession(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    engagedSeconds: engagedSeconds ?? this.engagedSeconds,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      engagedSeconds: data.engagedSeconds.present
          ? data.engagedSeconds.value
          : this.engagedSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('engagedSeconds: $engagedSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, startedAt, endedAt, engagedSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.engagedSeconds == this.engagedSeconds);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> engagedSeconds;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.engagedSeconds = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int engagedSeconds,
  }) : bookId = Value(bookId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       engagedSeconds = Value(engagedSeconds);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? engagedSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (engagedSeconds != null) 'engaged_seconds': engagedSeconds,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? engagedSeconds,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      engagedSeconds: engagedSeconds ?? this.engagedSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (engagedSeconds.present) {
      map['engaged_seconds'] = Variable<int>(engagedSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('engagedSeconds: $engagedSeconds')
          ..write(')'))
        .toString();
  }
}

class $ReaderProfilesTable extends ReaderProfiles
    with TableInfo<$ReaderProfilesTable, ReaderProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motivationsMeta = const VerificationMeta(
    'motivations',
  );
  @override
  late final GeneratedColumn<String> motivations = GeneratedColumn<String>(
    'motivations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineMeta = const VerificationMeta(
    'routine',
  );
  @override
  late final GeneratedColumn<String> routine = GeneratedColumn<String>(
    'routine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineHourMeta = const VerificationMeta(
    'routineHour',
  );
  @override
  late final GeneratedColumn<int> routineHour = GeneratedColumn<int>(
    'routine_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routineDaysMeta = const VerificationMeta(
    'routineDays',
  );
  @override
  late final GeneratedColumn<String> routineDays = GeneratedColumn<String>(
    'routine_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsPromptedMeta =
      const VerificationMeta('notificationsPrompted');
  @override
  late final GeneratedColumn<bool> notificationsPrompted =
      GeneratedColumn<bool>(
        'notifications_prompted',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_prompted" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _notificationPromptSkippedOnMeta =
      const VerificationMeta('notificationPromptSkippedOn');
  @override
  late final GeneratedColumn<String> notificationPromptSkippedOn =
      GeneratedColumn<String>(
        'notification_prompt_skipped_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _focusModeMeta = const VerificationMeta(
    'focusMode',
  );
  @override
  late final GeneratedColumn<bool> focusMode = GeneratedColumn<bool>(
    'focus_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("focus_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motivations,
    dailyGoalMinutes,
    routine,
    routineHour,
    routineDays,
    completedAt,
    notificationsPrompted,
    notificationPromptSkippedOn,
    focusMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motivations')) {
      context.handle(
        _motivationsMeta,
        motivations.isAcceptableOrUnknown(
          data['motivations']!,
          _motivationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_motivationsMeta);
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyGoalMinutesMeta);
    }
    if (data.containsKey('routine')) {
      context.handle(
        _routineMeta,
        routine.isAcceptableOrUnknown(data['routine']!, _routineMeta),
      );
    } else if (isInserting) {
      context.missing(_routineMeta);
    }
    if (data.containsKey('routine_hour')) {
      context.handle(
        _routineHourMeta,
        routineHour.isAcceptableOrUnknown(
          data['routine_hour']!,
          _routineHourMeta,
        ),
      );
    }
    if (data.containsKey('routine_days')) {
      context.handle(
        _routineDaysMeta,
        routineDays.isAcceptableOrUnknown(
          data['routine_days']!,
          _routineDaysMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('notifications_prompted')) {
      context.handle(
        _notificationsPromptedMeta,
        notificationsPrompted.isAcceptableOrUnknown(
          data['notifications_prompted']!,
          _notificationsPromptedMeta,
        ),
      );
    }
    if (data.containsKey('notification_prompt_skipped_on')) {
      context.handle(
        _notificationPromptSkippedOnMeta,
        notificationPromptSkippedOn.isAcceptableOrUnknown(
          data['notification_prompt_skipped_on']!,
          _notificationPromptSkippedOnMeta,
        ),
      );
    }
    if (data.containsKey('focus_mode')) {
      context.handle(
        _focusModeMeta,
        focusMode.isAcceptableOrUnknown(data['focus_mode']!, _focusModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motivations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivations'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
      routine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine'],
      )!,
      routineHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_hour'],
      ),
      routineDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_days'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      notificationsPrompted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_prompted'],
      )!,
      notificationPromptSkippedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_prompt_skipped_on'],
      ),
      focusMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}focus_mode'],
      )!,
    );
  }

  @override
  $ReaderProfilesTable createAlias(String alias) {
    return $ReaderProfilesTable(attachedDatabase, alias);
  }
}

class ReaderProfile extends DataClass implements Insertable<ReaderProfile> {
  final int id;
  final String motivations;
  final int dailyGoalMinutes;
  final String routine;
  final int? routineHour;
  final String? routineDays;
  final DateTime completedAt;

  /// True after the reader turns notifications on, or for a profile saved
  /// before this prompt existed. A skip leaves this false.
  final bool notificationsPrompted;

  /// Local calendar day (yyyy-MM-dd) of the last "not now".
  final String? notificationPromptSkippedOn;

  /// Reader asked Liora to silence the phone while the app is open.
  final bool focusMode;
  const ReaderProfile({
    required this.id,
    required this.motivations,
    required this.dailyGoalMinutes,
    required this.routine,
    this.routineHour,
    this.routineDays,
    required this.completedAt,
    required this.notificationsPrompted,
    this.notificationPromptSkippedOn,
    required this.focusMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motivations'] = Variable<String>(motivations);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    map['routine'] = Variable<String>(routine);
    if (!nullToAbsent || routineHour != null) {
      map['routine_hour'] = Variable<int>(routineHour);
    }
    if (!nullToAbsent || routineDays != null) {
      map['routine_days'] = Variable<String>(routineDays);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['notifications_prompted'] = Variable<bool>(notificationsPrompted);
    if (!nullToAbsent || notificationPromptSkippedOn != null) {
      map['notification_prompt_skipped_on'] = Variable<String>(
        notificationPromptSkippedOn,
      );
    }
    map['focus_mode'] = Variable<bool>(focusMode);
    return map;
  }

  ReaderProfilesCompanion toCompanion(bool nullToAbsent) {
    return ReaderProfilesCompanion(
      id: Value(id),
      motivations: Value(motivations),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      routine: Value(routine),
      routineHour: routineHour == null && nullToAbsent
          ? const Value.absent()
          : Value(routineHour),
      routineDays: routineDays == null && nullToAbsent
          ? const Value.absent()
          : Value(routineDays),
      completedAt: Value(completedAt),
      notificationsPrompted: Value(notificationsPrompted),
      notificationPromptSkippedOn:
          notificationPromptSkippedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationPromptSkippedOn),
      focusMode: Value(focusMode),
    );
  }

  factory ReaderProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderProfile(
      id: serializer.fromJson<int>(json['id']),
      motivations: serializer.fromJson<String>(json['motivations']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      routine: serializer.fromJson<String>(json['routine']),
      routineHour: serializer.fromJson<int?>(json['routineHour']),
      routineDays: serializer.fromJson<String?>(json['routineDays']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      notificationsPrompted: serializer.fromJson<bool>(
        json['notificationsPrompted'],
      ),
      notificationPromptSkippedOn: serializer.fromJson<String?>(
        json['notificationPromptSkippedOn'],
      ),
      focusMode: serializer.fromJson<bool>(json['focusMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motivations': serializer.toJson<String>(motivations),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'routine': serializer.toJson<String>(routine),
      'routineHour': serializer.toJson<int?>(routineHour),
      'routineDays': serializer.toJson<String?>(routineDays),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'notificationsPrompted': serializer.toJson<bool>(notificationsPrompted),
      'notificationPromptSkippedOn': serializer.toJson<String?>(
        notificationPromptSkippedOn,
      ),
      'focusMode': serializer.toJson<bool>(focusMode),
    };
  }

  ReaderProfile copyWith({
    int? id,
    String? motivations,
    int? dailyGoalMinutes,
    String? routine,
    Value<int?> routineHour = const Value.absent(),
    Value<String?> routineDays = const Value.absent(),
    DateTime? completedAt,
    bool? notificationsPrompted,
    Value<String?> notificationPromptSkippedOn = const Value.absent(),
    bool? focusMode,
  }) => ReaderProfile(
    id: id ?? this.id,
    motivations: motivations ?? this.motivations,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    routine: routine ?? this.routine,
    routineHour: routineHour.present ? routineHour.value : this.routineHour,
    routineDays: routineDays.present ? routineDays.value : this.routineDays,
    completedAt: completedAt ?? this.completedAt,
    notificationsPrompted: notificationsPrompted ?? this.notificationsPrompted,
    notificationPromptSkippedOn: notificationPromptSkippedOn.present
        ? notificationPromptSkippedOn.value
        : this.notificationPromptSkippedOn,
    focusMode: focusMode ?? this.focusMode,
  );
  ReaderProfile copyWithCompanion(ReaderProfilesCompanion data) {
    return ReaderProfile(
      id: data.id.present ? data.id.value : this.id,
      motivations: data.motivations.present
          ? data.motivations.value
          : this.motivations,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      routine: data.routine.present ? data.routine.value : this.routine,
      routineHour: data.routineHour.present
          ? data.routineHour.value
          : this.routineHour,
      routineDays: data.routineDays.present
          ? data.routineDays.value
          : this.routineDays,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notificationsPrompted: data.notificationsPrompted.present
          ? data.notificationsPrompted.value
          : this.notificationsPrompted,
      notificationPromptSkippedOn: data.notificationPromptSkippedOn.present
          ? data.notificationPromptSkippedOn.value
          : this.notificationPromptSkippedOn,
      focusMode: data.focusMode.present ? data.focusMode.value : this.focusMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderProfile(')
          ..write('id: $id, ')
          ..write('motivations: $motivations, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('routine: $routine, ')
          ..write('routineHour: $routineHour, ')
          ..write('routineDays: $routineDays, ')
          ..write('completedAt: $completedAt, ')
          ..write('notificationsPrompted: $notificationsPrompted, ')
          ..write('notificationPromptSkippedOn: $notificationPromptSkippedOn, ')
          ..write('focusMode: $focusMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motivations,
    dailyGoalMinutes,
    routine,
    routineHour,
    routineDays,
    completedAt,
    notificationsPrompted,
    notificationPromptSkippedOn,
    focusMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderProfile &&
          other.id == this.id &&
          other.motivations == this.motivations &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.routine == this.routine &&
          other.routineHour == this.routineHour &&
          other.routineDays == this.routineDays &&
          other.completedAt == this.completedAt &&
          other.notificationsPrompted == this.notificationsPrompted &&
          other.notificationPromptSkippedOn ==
              this.notificationPromptSkippedOn &&
          other.focusMode == this.focusMode);
}

class ReaderProfilesCompanion extends UpdateCompanion<ReaderProfile> {
  final Value<int> id;
  final Value<String> motivations;
  final Value<int> dailyGoalMinutes;
  final Value<String> routine;
  final Value<int?> routineHour;
  final Value<String?> routineDays;
  final Value<DateTime> completedAt;
  final Value<bool> notificationsPrompted;
  final Value<String?> notificationPromptSkippedOn;
  final Value<bool> focusMode;
  const ReaderProfilesCompanion({
    this.id = const Value.absent(),
    this.motivations = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.routine = const Value.absent(),
    this.routineHour = const Value.absent(),
    this.routineDays = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notificationsPrompted = const Value.absent(),
    this.notificationPromptSkippedOn = const Value.absent(),
    this.focusMode = const Value.absent(),
  });
  ReaderProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String motivations,
    required int dailyGoalMinutes,
    required String routine,
    this.routineHour = const Value.absent(),
    this.routineDays = const Value.absent(),
    required DateTime completedAt,
    this.notificationsPrompted = const Value.absent(),
    this.notificationPromptSkippedOn = const Value.absent(),
    this.focusMode = const Value.absent(),
  }) : motivations = Value(motivations),
       dailyGoalMinutes = Value(dailyGoalMinutes),
       routine = Value(routine),
       completedAt = Value(completedAt);
  static Insertable<ReaderProfile> custom({
    Expression<int>? id,
    Expression<String>? motivations,
    Expression<int>? dailyGoalMinutes,
    Expression<String>? routine,
    Expression<int>? routineHour,
    Expression<String>? routineDays,
    Expression<DateTime>? completedAt,
    Expression<bool>? notificationsPrompted,
    Expression<String>? notificationPromptSkippedOn,
    Expression<bool>? focusMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motivations != null) 'motivations': motivations,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (routine != null) 'routine': routine,
      if (routineHour != null) 'routine_hour': routineHour,
      if (routineDays != null) 'routine_days': routineDays,
      if (completedAt != null) 'completed_at': completedAt,
      if (notificationsPrompted != null)
        'notifications_prompted': notificationsPrompted,
      if (notificationPromptSkippedOn != null)
        'notification_prompt_skipped_on': notificationPromptSkippedOn,
      if (focusMode != null) 'focus_mode': focusMode,
    });
  }

  ReaderProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? motivations,
    Value<int>? dailyGoalMinutes,
    Value<String>? routine,
    Value<int?>? routineHour,
    Value<String?>? routineDays,
    Value<DateTime>? completedAt,
    Value<bool>? notificationsPrompted,
    Value<String?>? notificationPromptSkippedOn,
    Value<bool>? focusMode,
  }) {
    return ReaderProfilesCompanion(
      id: id ?? this.id,
      motivations: motivations ?? this.motivations,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      routine: routine ?? this.routine,
      routineHour: routineHour ?? this.routineHour,
      routineDays: routineDays ?? this.routineDays,
      completedAt: completedAt ?? this.completedAt,
      notificationsPrompted:
          notificationsPrompted ?? this.notificationsPrompted,
      notificationPromptSkippedOn:
          notificationPromptSkippedOn ?? this.notificationPromptSkippedOn,
      focusMode: focusMode ?? this.focusMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motivations.present) {
      map['motivations'] = Variable<String>(motivations.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (routine.present) {
      map['routine'] = Variable<String>(routine.value);
    }
    if (routineHour.present) {
      map['routine_hour'] = Variable<int>(routineHour.value);
    }
    if (routineDays.present) {
      map['routine_days'] = Variable<String>(routineDays.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notificationsPrompted.present) {
      map['notifications_prompted'] = Variable<bool>(
        notificationsPrompted.value,
      );
    }
    if (notificationPromptSkippedOn.present) {
      map['notification_prompt_skipped_on'] = Variable<String>(
        notificationPromptSkippedOn.value,
      );
    }
    if (focusMode.present) {
      map['focus_mode'] = Variable<bool>(focusMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderProfilesCompanion(')
          ..write('id: $id, ')
          ..write('motivations: $motivations, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('routine: $routine, ')
          ..write('routineHour: $routineHour, ')
          ..write('routineDays: $routineDays, ')
          ..write('completedAt: $completedAt, ')
          ..write('notificationsPrompted: $notificationsPrompted, ')
          ..write('notificationPromptSkippedOn: $notificationPromptSkippedOn, ')
          ..write('focusMode: $focusMode')
          ..write(')'))
        .toString();
  }
}

class $SavedQuotesTable extends SavedQuotes
    with TableInfo<$SavedQuotesTable, SavedQuote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedQuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _passageMeta = const VerificationMeta(
    'passage',
  );
  @override
  late final GeneratedColumn<String> passage = GeneratedColumn<String>(
    'passage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorJsonMeta = const VerificationMeta(
    'locatorJson',
  );
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
    'locator_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    passage,
    locatorJson,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedQuote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('passage')) {
      context.handle(
        _passageMeta,
        passage.isAcceptableOrUnknown(data['passage']!, _passageMeta),
      );
    } else if (isInserting) {
      context.missing(_passageMeta);
    }
    if (data.containsKey('locator_json')) {
      context.handle(
        _locatorJsonMeta,
        locatorJson.isAcceptableOrUnknown(
          data['locator_json']!,
          _locatorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedQuote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedQuote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      passage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passage'],
      )!,
      locatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_json'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $SavedQuotesTable createAlias(String alias) {
    return $SavedQuotesTable(attachedDatabase, alias);
  }
}

class SavedQuote extends DataClass implements Insertable<SavedQuote> {
  final int id;
  final int bookId;
  final String passage;
  final String locatorJson;
  final DateTime savedAt;
  const SavedQuote({
    required this.id,
    required this.bookId,
    required this.passage,
    required this.locatorJson,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['passage'] = Variable<String>(passage);
    map['locator_json'] = Variable<String>(locatorJson);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  SavedQuotesCompanion toCompanion(bool nullToAbsent) {
    return SavedQuotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      passage: Value(passage),
      locatorJson: Value(locatorJson),
      savedAt: Value(savedAt),
    );
  }

  factory SavedQuote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedQuote(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      passage: serializer.fromJson<String>(json['passage']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'passage': serializer.toJson<String>(passage),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  SavedQuote copyWith({
    int? id,
    int? bookId,
    String? passage,
    String? locatorJson,
    DateTime? savedAt,
  }) => SavedQuote(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    passage: passage ?? this.passage,
    locatorJson: locatorJson ?? this.locatorJson,
    savedAt: savedAt ?? this.savedAt,
  );
  SavedQuote copyWithCompanion(SavedQuotesCompanion data) {
    return SavedQuote(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      passage: data.passage.present ? data.passage.value : this.passage,
      locatorJson: data.locatorJson.present
          ? data.locatorJson.value
          : this.locatorJson,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedQuote(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('passage: $passage, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, passage, locatorJson, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedQuote &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.passage == this.passage &&
          other.locatorJson == this.locatorJson &&
          other.savedAt == this.savedAt);
}

class SavedQuotesCompanion extends UpdateCompanion<SavedQuote> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> passage;
  final Value<String> locatorJson;
  final Value<DateTime> savedAt;
  const SavedQuotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.passage = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  SavedQuotesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String passage,
    required String locatorJson,
    required DateTime savedAt,
  }) : bookId = Value(bookId),
       passage = Value(passage),
       locatorJson = Value(locatorJson),
       savedAt = Value(savedAt);
  static Insertable<SavedQuote> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? passage,
    Expression<String>? locatorJson,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (passage != null) 'passage': passage,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  SavedQuotesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? passage,
    Value<String>? locatorJson,
    Value<DateTime>? savedAt,
  }) {
    return SavedQuotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      passage: passage ?? this.passage,
      locatorJson: locatorJson ?? this.locatorJson,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (passage.present) {
      map['passage'] = Variable<String>(passage.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedQuotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('passage: $passage, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $ReaderProfilesTable readerProfiles = $ReaderProfilesTable(this);
  late final $SavedQuotesTable savedQuotes = $SavedQuotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    readingSessions,
    readerProfiles,
    savedQuotes,
  ];
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> author,
  required String filePath,
  Value<String?> coverPath,
  Value<Uint8List?> coverBytes,
  Value<String?> contentHash,
  Value<String?> bookUid,
  Value<String?> locatorJson,
  Value<double> progress,
  Value<bool> darkMode,
  Value<bool> scrollMode,
  Value<double> fontSize,
  required DateTime addedAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> author,
  Value<String> filePath,
  Value<String?> coverPath,
  Value<Uint8List?> coverBytes,
  Value<String?> contentHash,
  Value<String?> bookUid,
  Value<String?> locatorJson,
  Value<double> progress,
  Value<bool> darkMode,
  Value<bool> scrollMode,
  Value<double> fontSize,
  Value<DateTime> addedAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReadingSessionsTable, List<ReadingSession>>
  _readingSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingSessions,
    aliasName: 'books__id__reading_sessions__book_id',
  );

  $$ReadingSessionsTableProcessedTableManager get readingSessionsRefs {
    final manager = $$ReadingSessionsTableTableManager(
      $_db,
      $_db.readingSessions,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedQuotesTable, List<SavedQuote>>
  _savedQuotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedQuotes,
    aliasName: 'books__id__saved_quotes__book_id',
  );

  $$SavedQuotesTableProcessedTableManager get savedQuotesRefs {
    final manager = $$SavedQuotesTableTableManager(
      $_db,
      $_db.savedQuotes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedQuotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get coverBytes => $composableBuilder(
    column: $table.coverBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookUid => $composableBuilder(
    column: $table.bookUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scrollMode => $composableBuilder(
    column: $table.scrollMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readingSessionsRefs(
    Expression<bool> Function($$ReadingSessionsTableFilterComposer f) f,
  ) {
    final $$ReadingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedQuotesRefs(
    Expression<bool> Function($$SavedQuotesTableFilterComposer f) f,
  ) {
    final $$SavedQuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedQuotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedQuotesTableFilterComposer(
            $db: $db,
            $table: $db.savedQuotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get coverBytes => $composableBuilder(
    column: $table.coverBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookUid => $composableBuilder(
    column: $table.bookUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scrollMode => $composableBuilder(
    column: $table.scrollMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<Uint8List> get coverBytes => $composableBuilder(
    column: $table.coverBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookUid =>
      $composableBuilder(column: $table.bookUid, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<bool> get scrollMode => $composableBuilder(
    column: $table.scrollMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  Expression<T> readingSessionsRefs<T extends Object>(
    Expression<T> Function($$ReadingSessionsTableAnnotationComposer a) f,
  ) {
    final $$ReadingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedQuotesRefs<T extends Object>(
    Expression<T> Function($$SavedQuotesTableAnnotationComposer a) f,
  ) {
    final $$SavedQuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedQuotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedQuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.savedQuotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool readingSessionsRefs,
            bool savedQuotesRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<Uint8List?> coverBytes = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> bookUid = const Value.absent(),
                Value<String?> locatorJson = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<bool> scrollMode = const Value.absent(),
                Value<double> fontSize = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                filePath: filePath,
                coverPath: coverPath,
                coverBytes: coverBytes,
                contentHash: contentHash,
                bookUid: bookUid,
                locatorJson: locatorJson,
                progress: progress,
                darkMode: darkMode,
                scrollMode: scrollMode,
                fontSize: fontSize,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> author = const Value.absent(),
                required String filePath,
                Value<String?> coverPath = const Value.absent(),
                Value<Uint8List?> coverBytes = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> bookUid = const Value.absent(),
                Value<String?> locatorJson = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<bool> darkMode = const Value.absent(),
                Value<bool> scrollMode = const Value.absent(),
                Value<double> fontSize = const Value.absent(),
                required DateTime addedAt,
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                filePath: filePath,
                coverPath: coverPath,
                coverBytes: coverBytes,
                contentHash: contentHash,
                bookUid: bookUid,
                locatorJson: locatorJson,
                progress: progress,
                darkMode: darkMode,
                scrollMode: scrollMode,
                fontSize: fontSize,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({readingSessionsRefs = false, savedQuotesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readingSessionsRefs) db.readingSessions,
                    if (savedQuotesRefs) db.savedQuotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readingSessionsRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReadingSession
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedQuotesRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          SavedQuote
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._savedQuotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).savedQuotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({bool readingSessionsRefs, bool savedQuotesRefs})
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      required int bookId,
      required DateTime startedAt,
      required DateTime endedAt,
      required int engagedSeconds,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<int> engagedSeconds,
    });

final class $$ReadingSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSession> {
  $$ReadingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_sessions__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get engagedSeconds => $composableBuilder(
    column: $table.engagedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get engagedSeconds => $composableBuilder(
    column: $table.engagedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get engagedSeconds => $composableBuilder(
    column: $table.engagedSeconds,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (ReadingSession, $$ReadingSessionsTableReferences),
          ReadingSession,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingSessionsTableTableManager(
    _$AppDatabase db,
    $ReadingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> engagedSeconds = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                engagedSeconds: engagedSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required DateTime startedAt,
                required DateTime endedAt,
                required int engagedSeconds,
              }) => ReadingSessionsCompanion.insert(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                engagedSeconds: engagedSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingSessionsTable, ReadingSession>(table),
                  $$ReadingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingSessionsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingSessionsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (ReadingSession, $$ReadingSessionsTableReferences),
      ReadingSession,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReaderProfilesTableCreateCompanionBuilder =
    ReaderProfilesCompanion Function({
      Value<int> id,
      required String motivations,
      required int dailyGoalMinutes,
      required String routine,
      Value<int?> routineHour,
      Value<String?> routineDays,
      required DateTime completedAt,
      Value<bool> notificationsPrompted,
      Value<String?> notificationPromptSkippedOn,
      Value<bool> focusMode,
    });
typedef $$ReaderProfilesTableUpdateCompanionBuilder =
    ReaderProfilesCompanion Function({
      Value<int> id,
      Value<String> motivations,
      Value<int> dailyGoalMinutes,
      Value<String> routine,
      Value<int?> routineHour,
      Value<String?> routineDays,
      Value<DateTime> completedAt,
      Value<bool> notificationsPrompted,
      Value<String?> notificationPromptSkippedOn,
      Value<bool> focusMode,
    });

class $$ReaderProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderProfilesTable> {
  $$ReaderProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivations => $composableBuilder(
    column: $table.motivations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routine => $composableBuilder(
    column: $table.routine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routineHour => $composableBuilder(
    column: $table.routineHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineDays => $composableBuilder(
    column: $table.routineDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsPrompted => $composableBuilder(
    column: $table.notificationsPrompted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationPromptSkippedOn => $composableBuilder(
    column: $table.notificationPromptSkippedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReaderProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderProfilesTable> {
  $$ReaderProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivations => $composableBuilder(
    column: $table.motivations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routine => $composableBuilder(
    column: $table.routine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routineHour => $composableBuilder(
    column: $table.routineHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineDays => $composableBuilder(
    column: $table.routineDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsPrompted => $composableBuilder(
    column: $table.notificationsPrompted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationPromptSkippedOn => $composableBuilder(
    column: $table.notificationPromptSkippedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReaderProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderProfilesTable> {
  $$ReaderProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get motivations => $composableBuilder(
    column: $table.motivations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routine =>
      $composableBuilder(column: $table.routine, builder: (column) => column);

  GeneratedColumn<int> get routineHour => $composableBuilder(
    column: $table.routineHour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routineDays => $composableBuilder(
    column: $table.routineDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsPrompted => $composableBuilder(
    column: $table.notificationsPrompted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationPromptSkippedOn => $composableBuilder(
    column: $table.notificationPromptSkippedOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get focusMode =>
      $composableBuilder(column: $table.focusMode, builder: (column) => column);
}

class $$ReaderProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderProfilesTable,
          ReaderProfile,
          $$ReaderProfilesTableFilterComposer,
          $$ReaderProfilesTableOrderingComposer,
          $$ReaderProfilesTableAnnotationComposer,
          $$ReaderProfilesTableCreateCompanionBuilder,
          $$ReaderProfilesTableUpdateCompanionBuilder,
          (
            ReaderProfile,
            BaseReferences<_$AppDatabase, $ReaderProfilesTable, ReaderProfile>,
          ),
          ReaderProfile,
          PrefetchHooks Function()
        > {
  $$ReaderProfilesTableTableManager(
    _$AppDatabase db,
    $ReaderProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> motivations = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<String> routine = const Value.absent(),
                Value<int?> routineHour = const Value.absent(),
                Value<String?> routineDays = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<bool> notificationsPrompted = const Value.absent(),
                Value<String?> notificationPromptSkippedOn =
                    const Value.absent(),
                Value<bool> focusMode = const Value.absent(),
              }) => ReaderProfilesCompanion(
                id: id,
                motivations: motivations,
                dailyGoalMinutes: dailyGoalMinutes,
                routine: routine,
                routineHour: routineHour,
                routineDays: routineDays,
                completedAt: completedAt,
                notificationsPrompted: notificationsPrompted,
                notificationPromptSkippedOn: notificationPromptSkippedOn,
                focusMode: focusMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String motivations,
                required int dailyGoalMinutes,
                required String routine,
                Value<int?> routineHour = const Value.absent(),
                Value<String?> routineDays = const Value.absent(),
                required DateTime completedAt,
                Value<bool> notificationsPrompted = const Value.absent(),
                Value<String?> notificationPromptSkippedOn =
                    const Value.absent(),
                Value<bool> focusMode = const Value.absent(),
              }) => ReaderProfilesCompanion.insert(
                id: id,
                motivations: motivations,
                dailyGoalMinutes: dailyGoalMinutes,
                routine: routine,
                routineHour: routineHour,
                routineDays: routineDays,
                completedAt: completedAt,
                notificationsPrompted: notificationsPrompted,
                notificationPromptSkippedOn: notificationPromptSkippedOn,
                focusMode: focusMode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReaderProfilesTable, ReaderProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReaderProfilesTable,
                    ReaderProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReaderProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderProfilesTable,
      ReaderProfile,
      $$ReaderProfilesTableFilterComposer,
      $$ReaderProfilesTableOrderingComposer,
      $$ReaderProfilesTableAnnotationComposer,
      $$ReaderProfilesTableCreateCompanionBuilder,
      $$ReaderProfilesTableUpdateCompanionBuilder,
      (
        ReaderProfile,
        BaseReferences<_$AppDatabase, $ReaderProfilesTable, ReaderProfile>,
      ),
      ReaderProfile,
      PrefetchHooks Function()
    >;
typedef $$SavedQuotesTableCreateCompanionBuilder =
    SavedQuotesCompanion Function({
      Value<int> id,
      required int bookId,
      required String passage,
      required String locatorJson,
      required DateTime savedAt,
    });
typedef $$SavedQuotesTableUpdateCompanionBuilder =
    SavedQuotesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> passage,
      Value<String> locatorJson,
      Value<DateTime> savedAt,
    });

final class $$SavedQuotesTableReferences
    extends BaseReferences<_$AppDatabase, $SavedQuotesTable, SavedQuote> {
  $$SavedQuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('saved_quotes__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedQuotesTable> {
  $$SavedQuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedQuotesTable> {
  $$SavedQuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedQuotesTable> {
  $$SavedQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get passage =>
      $composableBuilder(column: $table.passage, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedQuotesTable,
          SavedQuote,
          $$SavedQuotesTableFilterComposer,
          $$SavedQuotesTableOrderingComposer,
          $$SavedQuotesTableAnnotationComposer,
          $$SavedQuotesTableCreateCompanionBuilder,
          $$SavedQuotesTableUpdateCompanionBuilder,
          (SavedQuote, $$SavedQuotesTableReferences),
          SavedQuote,
          PrefetchHooks Function({bool bookId})
        > {
  $$SavedQuotesTableTableManager(_$AppDatabase db, $SavedQuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedQuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> passage = const Value.absent(),
                Value<String> locatorJson = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => SavedQuotesCompanion(
                id: id,
                bookId: bookId,
                passage: passage,
                locatorJson: locatorJson,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String passage,
                required String locatorJson,
                required DateTime savedAt,
              }) => SavedQuotesCompanion.insert(
                id: id,
                bookId: bookId,
                passage: passage,
                locatorJson: locatorJson,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedQuotesTable, SavedQuote>(table),
                  $$SavedQuotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$SavedQuotesTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$SavedQuotesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedQuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedQuotesTable,
      SavedQuote,
      $$SavedQuotesTableFilterComposer,
      $$SavedQuotesTableOrderingComposer,
      $$SavedQuotesTableAnnotationComposer,
      $$SavedQuotesTableCreateCompanionBuilder,
      $$SavedQuotesTableUpdateCompanionBuilder,
      (SavedQuote, $$SavedQuotesTableReferences),
      SavedQuote,
      PrefetchHooks Function({bool bookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$ReaderProfilesTableTableManager get readerProfiles =>
      $$ReaderProfilesTableTableManager(_db, _db.readerProfiles);
  $$SavedQuotesTableTableManager get savedQuotes =>
      $$SavedQuotesTableTableManager(_db, _db.savedQuotes);
}
