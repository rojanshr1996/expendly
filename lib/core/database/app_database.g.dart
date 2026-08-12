// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransactionType>($CategoriesTable.$convertertype);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, color, type, isDefault, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      type: $CategoriesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  final String icon;
  final String color;
  final TransactionType type;
  final bool isDefault;
  final int sortOrder;
  const CategoryData(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.type,
      required this.isDefault,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    {
      map['type'] = Variable<int>($CategoriesTable.$convertertype.toSql(type));
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      type: $CategoriesTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'type':
          serializer.toJson<int>($CategoriesTable.$convertertype.toJson(type)),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryData copyWith(
          {int? id,
          String? name,
          String? icon,
          String? color,
          TransactionType? type,
          bool? isDefault,
          int? sortOrder}) =>
      CategoryData(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        type: type ?? this.type,
        isDefault: isDefault ?? this.isDefault,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CategoryData copyWithCompanion(CategoriesCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, type, isDefault, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<TransactionType> type;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : name = Value(name),
        icon = Value(icon),
        color = Value(color),
        type = Value(type);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? type,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<String>? color,
      Value<TransactionType>? type,
      Value<bool>? isDefault,
      Value<int>? sortOrder}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($CategoriesTable.$convertertype.toSql(type.value));
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SubcategoriesTable extends Subcategories
    with TableInfo<$SubcategoriesTable, SubcategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubcategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _parentCategoryIdMeta =
      const VerificationMeta('parentCategoryId');
  @override
  late final GeneratedColumn<int> parentCategoryId = GeneratedColumn<int>(
      'parent_category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, parentCategoryId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subcategories';
  @override
  VerificationContext validateIntegrity(Insertable<SubcategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
          _parentCategoryIdMeta,
          parentCategoryId.isAcceptableOrUnknown(
              data['parent_category_id']!, _parentCategoryIdMeta));
    } else if (isInserting) {
      context.missing(_parentCategoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubcategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubcategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      parentCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}parent_category_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $SubcategoriesTable createAlias(String alias) {
    return $SubcategoriesTable(attachedDatabase, alias);
  }
}

class SubcategoryData extends DataClass implements Insertable<SubcategoryData> {
  final int id;
  final int parentCategoryId;
  final String name;
  const SubcategoryData(
      {required this.id, required this.parentCategoryId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['parent_category_id'] = Variable<int>(parentCategoryId);
    map['name'] = Variable<String>(name);
    return map;
  }

  SubcategoriesCompanion toCompanion(bool nullToAbsent) {
    return SubcategoriesCompanion(
      id: Value(id),
      parentCategoryId: Value(parentCategoryId),
      name: Value(name),
    );
  }

  factory SubcategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubcategoryData(
      id: serializer.fromJson<int>(json['id']),
      parentCategoryId: serializer.fromJson<int>(json['parentCategoryId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentCategoryId': serializer.toJson<int>(parentCategoryId),
      'name': serializer.toJson<String>(name),
    };
  }

  SubcategoryData copyWith({int? id, int? parentCategoryId, String? name}) =>
      SubcategoryData(
        id: id ?? this.id,
        parentCategoryId: parentCategoryId ?? this.parentCategoryId,
        name: name ?? this.name,
      );
  SubcategoryData copyWithCompanion(SubcategoriesCompanion data) {
    return SubcategoryData(
      id: data.id.present ? data.id.value : this.id,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubcategoryData(')
          ..write('id: $id, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, parentCategoryId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubcategoryData &&
          other.id == this.id &&
          other.parentCategoryId == this.parentCategoryId &&
          other.name == this.name);
}

class SubcategoriesCompanion extends UpdateCompanion<SubcategoryData> {
  final Value<int> id;
  final Value<int> parentCategoryId;
  final Value<String> name;
  const SubcategoriesCompanion({
    this.id = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.name = const Value.absent(),
  });
  SubcategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int parentCategoryId,
    required String name,
  })  : parentCategoryId = Value(parentCategoryId),
        name = Value(name);
  static Insertable<SubcategoryData> custom({
    Expression<int>? id,
    Expression<int>? parentCategoryId,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (name != null) 'name': name,
    });
  }

  SubcategoriesCompanion copyWith(
      {Value<int>? id, Value<int>? parentCategoryId, Value<String>? name}) {
    return SubcategoriesCompanion(
      id: id ?? this.id,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<int>(parentCategoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubcategoriesCompanion(')
          ..write('id: $id, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransactionType>(
              $RecurringTransactionsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE RESTRICT'));
  static const VerificationMeta _subcategoryIdMeta =
      const VerificationMeta('subcategoryId');
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
      'subcategory_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subcategories (id) ON DELETE SET NULL'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceFrequency, int>
      frequency = GeneratedColumn<int>('frequency', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<RecurrenceFrequency>(
              $RecurringTransactionsTable.$converterfrequency);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isAutoCreateMeta =
      const VerificationMeta('isAutoCreate');
  @override
  late final GeneratedColumn<bool> isAutoCreate = GeneratedColumn<bool>(
      'is_auto_create', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_create" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastProcessedDateMeta =
      const VerificationMeta('lastProcessedDate');
  @override
  late final GeneratedColumn<DateTime> lastProcessedDate =
      GeneratedColumn<DateTime>('last_processed_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        categoryId,
        subcategoryId,
        note,
        frequency,
        nextDueDate,
        isAutoCreate,
        isActive,
        lastProcessedDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTransactionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
          _subcategoryIdMeta,
          subcategoryId.isAcceptableOrUnknown(
              data['subcategory_id']!, _subcategoryIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    context.handle(_frequencyMeta, const VerificationResult.success());
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('is_auto_create')) {
      context.handle(
          _isAutoCreateMeta,
          isAutoCreate.isAcceptableOrUnknown(
              data['is_auto_create']!, _isAutoCreateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_processed_date')) {
      context.handle(
          _lastProcessedDateMeta,
          lastProcessedDate.isAcceptableOrUnknown(
              data['last_processed_date']!, _lastProcessedDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransactionData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransactionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $RecurringTransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      subcategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subcategory_id']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      frequency: $RecurringTransactionsTable.$converterfrequency.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!),
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
      isAutoCreate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_auto_create'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastProcessedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_processed_date']),
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<RecurrenceFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<RecurrenceFrequency>(RecurrenceFrequency.values);
}

class RecurringTransactionData extends DataClass
    implements Insertable<RecurringTransactionData> {
  final int id;
  final TransactionType type;
  final int amount;
  final int categoryId;
  final int? subcategoryId;
  final String? note;
  final RecurrenceFrequency frequency;
  final DateTime nextDueDate;
  final bool isAutoCreate;
  final bool isActive;
  final DateTime? lastProcessedDate;
  const RecurringTransactionData(
      {required this.id,
      required this.type,
      required this.amount,
      required this.categoryId,
      this.subcategoryId,
      this.note,
      required this.frequency,
      required this.nextDueDate,
      required this.isAutoCreate,
      required this.isActive,
      this.lastProcessedDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<int>($RecurringTransactionsTable.$convertertype.toSql(type));
    }
    map['amount'] = Variable<int>(amount);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['frequency'] = Variable<int>(
          $RecurringTransactionsTable.$converterfrequency.toSql(frequency));
    }
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['is_auto_create'] = Variable<bool>(isAutoCreate);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastProcessedDate != null) {
      map['last_processed_date'] = Variable<DateTime>(lastProcessedDate);
    }
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      isAutoCreate: Value(isAutoCreate),
      isActive: Value(isActive),
      lastProcessedDate: lastProcessedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProcessedDate),
    );
  }

  factory RecurringTransactionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransactionData(
      id: serializer.fromJson<int>(json['id']),
      type: $RecurringTransactionsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      note: serializer.fromJson<String?>(json['note']),
      frequency: $RecurringTransactionsTable.$converterfrequency
          .fromJson(serializer.fromJson<int>(json['frequency'])),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      isAutoCreate: serializer.fromJson<bool>(json['isAutoCreate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastProcessedDate:
          serializer.fromJson<DateTime?>(json['lastProcessedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<int>($RecurringTransactionsTable.$convertertype.toJson(type)),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<int>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'note': serializer.toJson<String?>(note),
      'frequency': serializer.toJson<int>(
          $RecurringTransactionsTable.$converterfrequency.toJson(frequency)),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'isAutoCreate': serializer.toJson<bool>(isAutoCreate),
      'isActive': serializer.toJson<bool>(isActive),
      'lastProcessedDate': serializer.toJson<DateTime?>(lastProcessedDate),
    };
  }

  RecurringTransactionData copyWith(
          {int? id,
          TransactionType? type,
          int? amount,
          int? categoryId,
          Value<int?> subcategoryId = const Value.absent(),
          Value<String?> note = const Value.absent(),
          RecurrenceFrequency? frequency,
          DateTime? nextDueDate,
          bool? isAutoCreate,
          bool? isActive,
          Value<DateTime?> lastProcessedDate = const Value.absent()}) =>
      RecurringTransactionData(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        subcategoryId:
            subcategoryId.present ? subcategoryId.value : this.subcategoryId,
        note: note.present ? note.value : this.note,
        frequency: frequency ?? this.frequency,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        isAutoCreate: isAutoCreate ?? this.isAutoCreate,
        isActive: isActive ?? this.isActive,
        lastProcessedDate: lastProcessedDate.present
            ? lastProcessedDate.value
            : this.lastProcessedDate,
      );
  RecurringTransactionData copyWithCompanion(
      RecurringTransactionsCompanion data) {
    return RecurringTransactionData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      note: data.note.present ? data.note.value : this.note,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      isAutoCreate: data.isAutoCreate.present
          ? data.isAutoCreate.value
          : this.isAutoCreate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastProcessedDate: data.lastProcessedDate.present
          ? data.lastProcessedDate.value
          : this.lastProcessedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isAutoCreate: $isAutoCreate, ')
          ..write('isActive: $isActive, ')
          ..write('lastProcessedDate: $lastProcessedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, amount, categoryId, subcategoryId,
      note, frequency, nextDueDate, isAutoCreate, isActive, lastProcessedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransactionData &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.note == this.note &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.isAutoCreate == this.isAutoCreate &&
          other.isActive == this.isActive &&
          other.lastProcessedDate == this.lastProcessedDate);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransactionData> {
  final Value<int> id;
  final Value<TransactionType> type;
  final Value<int> amount;
  final Value<int> categoryId;
  final Value<int?> subcategoryId;
  final Value<String?> note;
  final Value<RecurrenceFrequency> frequency;
  final Value<DateTime> nextDueDate;
  final Value<bool> isAutoCreate;
  final Value<bool> isActive;
  final Value<DateTime?> lastProcessedDate;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.isAutoCreate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastProcessedDate = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required TransactionType type,
    required int amount,
    required int categoryId,
    this.subcategoryId = const Value.absent(),
    this.note = const Value.absent(),
    required RecurrenceFrequency frequency,
    required DateTime nextDueDate,
    this.isAutoCreate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastProcessedDate = const Value.absent(),
  })  : type = Value(type),
        amount = Value(amount),
        categoryId = Value(categoryId),
        frequency = Value(frequency),
        nextDueDate = Value(nextDueDate);
  static Insertable<RecurringTransactionData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<int>? amount,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<String>? note,
    Expression<int>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? isAutoCreate,
    Expression<bool>? isActive,
    Expression<DateTime>? lastProcessedDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (note != null) 'note': note,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (isAutoCreate != null) 'is_auto_create': isAutoCreate,
      if (isActive != null) 'is_active': isActive,
      if (lastProcessedDate != null) 'last_processed_date': lastProcessedDate,
    });
  }

  RecurringTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<TransactionType>? type,
      Value<int>? amount,
      Value<int>? categoryId,
      Value<int?>? subcategoryId,
      Value<String?>? note,
      Value<RecurrenceFrequency>? frequency,
      Value<DateTime>? nextDueDate,
      Value<bool>? isAutoCreate,
      Value<bool>? isActive,
      Value<DateTime?>? lastProcessedDate}) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isAutoCreate: isAutoCreate ?? this.isAutoCreate,
      isActive: isActive ?? this.isActive,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
          $RecurringTransactionsTable.$convertertype.toSql(type.value));
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>($RecurringTransactionsTable
          .$converterfrequency
          .toSql(frequency.value));
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (isAutoCreate.present) {
      map['is_auto_create'] = Variable<bool>(isAutoCreate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastProcessedDate.present) {
      map['last_processed_date'] = Variable<DateTime>(lastProcessedDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isAutoCreate: $isAutoCreate, ')
          ..write('isActive: $isActive, ')
          ..write('lastProcessedDate: $lastProcessedDate')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE RESTRICT'));
  static const VerificationMeta _subcategoryIdMeta =
      const VerificationMeta('subcategoryId');
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
      'subcategory_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subcategories (id) ON DELETE SET NULL'));
  static const VerificationMeta _recurringTransactionIdMeta =
      const VerificationMeta('recurringTransactionId');
  @override
  late final GeneratedColumn<int> recurringTransactionId = GeneratedColumn<int>(
      'recurring_transaction_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_transactions (id) ON DELETE SET NULL'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, int>
      paymentMethod = GeneratedColumn<int>('payment_method', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<PaymentMethod?>(
              $TransactionsTable.$converterpaymentMethodn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        currencyCode,
        categoryId,
        subcategoryId,
        recurringTransactionId,
        timestamp,
        note,
        paymentMethod
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
          _subcategoryIdMeta,
          subcategoryId.isAcceptableOrUnknown(
              data['subcategory_id']!, _subcategoryIdMeta));
    }
    if (data.containsKey('recurring_transaction_id')) {
      context.handle(
          _recurringTransactionIdMeta,
          recurringTransactionId.isAcceptableOrUnknown(
              data['recurring_transaction_id']!, _recurringTransactionIdMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    context.handle(_paymentMethodMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $TransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      subcategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subcategory_id']),
      recurringTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}recurring_transaction_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      paymentMethod: $TransactionsTable.$converterpaymentMethodn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}payment_method'])),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<PaymentMethod, int, int> $converterpaymentMethod =
      const EnumIndexConverter<PaymentMethod>(PaymentMethod.values);
  static JsonTypeConverter2<PaymentMethod?, int?, int?>
      $converterpaymentMethodn =
      JsonTypeConverter2.asNullable($converterpaymentMethod);
}

class TransactionData extends DataClass implements Insertable<TransactionData> {
  final int id;
  final TransactionType type;
  final int amount;
  final String currencyCode;
  final int categoryId;
  final int? subcategoryId;
  final int? recurringTransactionId;
  final DateTime timestamp;
  final String? note;
  final PaymentMethod? paymentMethod;
  const TransactionData(
      {required this.id,
      required this.type,
      required this.amount,
      required this.currencyCode,
      required this.categoryId,
      this.subcategoryId,
      this.recurringTransactionId,
      required this.timestamp,
      this.note,
      this.paymentMethod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<int>($TransactionsTable.$convertertype.toSql(type));
    }
    map['amount'] = Variable<int>(amount);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    if (!nullToAbsent || recurringTransactionId != null) {
      map['recurring_transaction_id'] = Variable<int>(recurringTransactionId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<int>(
          $TransactionsTable.$converterpaymentMethodn.toSql(paymentMethod));
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      currencyCode: Value(currencyCode),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      recurringTransactionId: recurringTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringTransactionId),
      timestamp: Value(timestamp),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
    );
  }

  factory TransactionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionData(
      id: serializer.fromJson<int>(json['id']),
      type: $TransactionsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      amount: serializer.fromJson<int>(json['amount']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      recurringTransactionId:
          serializer.fromJson<int?>(json['recurringTransactionId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      note: serializer.fromJson<String?>(json['note']),
      paymentMethod: $TransactionsTable.$converterpaymentMethodn
          .fromJson(serializer.fromJson<int?>(json['paymentMethod'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<int>($TransactionsTable.$convertertype.toJson(type)),
      'amount': serializer.toJson<int>(amount),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryId': serializer.toJson<int>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'recurringTransactionId': serializer.toJson<int?>(recurringTransactionId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'note': serializer.toJson<String?>(note),
      'paymentMethod': serializer.toJson<int?>(
          $TransactionsTable.$converterpaymentMethodn.toJson(paymentMethod)),
    };
  }

  TransactionData copyWith(
          {int? id,
          TransactionType? type,
          int? amount,
          String? currencyCode,
          int? categoryId,
          Value<int?> subcategoryId = const Value.absent(),
          Value<int?> recurringTransactionId = const Value.absent(),
          DateTime? timestamp,
          Value<String?> note = const Value.absent(),
          Value<PaymentMethod?> paymentMethod = const Value.absent()}) =>
      TransactionData(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        currencyCode: currencyCode ?? this.currencyCode,
        categoryId: categoryId ?? this.categoryId,
        subcategoryId:
            subcategoryId.present ? subcategoryId.value : this.subcategoryId,
        recurringTransactionId: recurringTransactionId.present
            ? recurringTransactionId.value
            : this.recurringTransactionId,
        timestamp: timestamp ?? this.timestamp,
        note: note.present ? note.value : this.note,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
      );
  TransactionData copyWithCompanion(TransactionsCompanion data) {
    return TransactionData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      recurringTransactionId: data.recurringTransactionId.present
          ? data.recurringTransactionId.value
          : this.recurringTransactionId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      note: data.note.present ? data.note.value : this.note,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('recurringTransactionId: $recurringTransactionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, amount, currencyCode, categoryId,
      subcategoryId, recurringTransactionId, timestamp, note, paymentMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionData &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.recurringTransactionId == this.recurringTransactionId &&
          other.timestamp == this.timestamp &&
          other.note == this.note &&
          other.paymentMethod == this.paymentMethod);
}

class TransactionsCompanion extends UpdateCompanion<TransactionData> {
  final Value<int> id;
  final Value<TransactionType> type;
  final Value<int> amount;
  final Value<String> currencyCode;
  final Value<int> categoryId;
  final Value<int?> subcategoryId;
  final Value<int?> recurringTransactionId;
  final Value<DateTime> timestamp;
  final Value<String?> note;
  final Value<PaymentMethod?> paymentMethod;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.recurringTransactionId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentMethod = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required TransactionType type,
    required int amount,
    this.currencyCode = const Value.absent(),
    required int categoryId,
    this.subcategoryId = const Value.absent(),
    this.recurringTransactionId = const Value.absent(),
    required DateTime timestamp,
    this.note = const Value.absent(),
    this.paymentMethod = const Value.absent(),
  })  : type = Value(type),
        amount = Value(amount),
        categoryId = Value(categoryId),
        timestamp = Value(timestamp);
  static Insertable<TransactionData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<int>? amount,
    Expression<String>? currencyCode,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<int>? recurringTransactionId,
    Expression<DateTime>? timestamp,
    Expression<String>? note,
    Expression<int>? paymentMethod,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (recurringTransactionId != null)
        'recurring_transaction_id': recurringTransactionId,
      if (timestamp != null) 'timestamp': timestamp,
      if (note != null) 'note': note,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<TransactionType>? type,
      Value<int>? amount,
      Value<String>? currencyCode,
      Value<int>? categoryId,
      Value<int?>? subcategoryId,
      Value<int?>? recurringTransactionId,
      Value<DateTime>? timestamp,
      Value<String?>? note,
      Value<PaymentMethod?>? paymentMethod}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      recurringTransactionId:
          recurringTransactionId ?? this.recurringTransactionId,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($TransactionsTable.$convertertype.toSql(type.value));
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (recurringTransactionId.present) {
      map['recurring_transaction_id'] =
          Variable<int>(recurringTransactionId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<int>($TransactionsTable
          .$converterpaymentMethodn
          .toSql(paymentMethod.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('recurringTransactionId: $recurringTransactionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagData extends DataClass implements Insertable<TagData> {
  final int id;
  final String name;
  const TagData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory TagData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagData copyWith({int? id, String? name}) => TagData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  TagData copyWithCompanion(TagsCompanion data) {
    return TagData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagData && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagData> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TagData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [transactionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionTagData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, tagId};
  @override
  TransactionTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTagData(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTagData extends DataClass
    implements Insertable<TransactionTagData> {
  final int transactionId;
  final int tagId;
  const TransactionTagData({required this.transactionId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<int>(transactionId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      transactionId: Value(transactionId),
      tagId: Value(tagId),
    );
  }

  factory TransactionTagData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTagData(
      transactionId: serializer.fromJson<int>(json['transactionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<int>(transactionId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  TransactionTagData copyWith({int? transactionId, int? tagId}) =>
      TransactionTagData(
        transactionId: transactionId ?? this.transactionId,
        tagId: tagId ?? this.tagId,
      );
  TransactionTagData copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTagData(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagData(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTagData &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTagData> {
  final Value<int> transactionId;
  final Value<int> tagId;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required int transactionId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : transactionId = Value(transactionId),
        tagId = Value(tagId);
  static Insertable<TransactionTagData> custom({
    Expression<int>? transactionId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith(
      {Value<int>? transactionId, Value<int>? tagId, Value<int>? rowid}) {
    return TransactionTagsCompanion(
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE CASCADE'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, filePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<AttachmentData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentData extends DataClass implements Insertable<AttachmentData> {
  final int id;
  final int transactionId;
  final String filePath;
  const AttachmentData(
      {required this.id, required this.transactionId, required this.filePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['file_path'] = Variable<String>(filePath);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      filePath: Value(filePath),
    );
  }

  factory AttachmentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentData(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'filePath': serializer.toJson<String>(filePath),
    };
  }

  AttachmentData copyWith({int? id, int? transactionId, String? filePath}) =>
      AttachmentData(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        filePath: filePath ?? this.filePath,
      );
  AttachmentData copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentData(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentData(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, filePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentData &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.filePath == this.filePath);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentData> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<String> filePath;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.filePath = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required String filePath,
  })  : transactionId = Value(transactionId),
        filePath = Value(filePath);
  static Insertable<AttachmentData> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? filePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (filePath != null) 'file_path': filePath,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<int>? id, Value<int>? transactionId, Value<String>? filePath}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE CASCADE'));
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumnWithTypeConverter<BudgetPeriod, int> period =
      GeneratedColumn<int>('period', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<BudgetPeriod>($BudgetsTable.$converterperiod);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _notifyAtThresholdMeta =
      const VerificationMeta('notifyAtThreshold');
  @override
  late final GeneratedColumn<bool> notifyAtThreshold = GeneratedColumn<bool>(
      'notify_at_threshold', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notify_at_threshold" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _thresholdPercentageMeta =
      const VerificationMeta('thresholdPercentage');
  @override
  late final GeneratedColumn<int> thresholdPercentage = GeneratedColumn<int>(
      'threshold_percentage', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(80));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        targetAmount,
        period,
        year,
        month,
        currencyCode,
        notifyAtThreshold,
        thresholdPercentage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    context.handle(_periodMeta, const VerificationResult.success());
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('notify_at_threshold')) {
      context.handle(
          _notifyAtThresholdMeta,
          notifyAtThreshold.isAcceptableOrUnknown(
              data['notify_at_threshold']!, _notifyAtThresholdMeta));
    }
    if (data.containsKey('threshold_percentage')) {
      context.handle(
          _thresholdPercentageMeta,
          thresholdPercentage.isAcceptableOrUnknown(
              data['threshold_percentage']!, _thresholdPercentageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_amount'])!,
      period: $BudgetsTable.$converterperiod.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period'])!),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month']),
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      notifyAtThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notify_at_threshold'])!,
      thresholdPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}threshold_percentage'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BudgetPeriod, int, int> $converterperiod =
      const EnumIndexConverter<BudgetPeriod>(BudgetPeriod.values);
}

class BudgetData extends DataClass implements Insertable<BudgetData> {
  final int id;
  final int? categoryId;
  final int targetAmount;
  final BudgetPeriod period;
  final int? year;
  final int? month;
  final String currencyCode;
  final bool notifyAtThreshold;
  final int thresholdPercentage;
  const BudgetData(
      {required this.id,
      this.categoryId,
      required this.targetAmount,
      required this.period,
      this.year,
      this.month,
      required this.currencyCode,
      required this.notifyAtThreshold,
      required this.thresholdPercentage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['target_amount'] = Variable<int>(targetAmount);
    {
      map['period'] =
          Variable<int>($BudgetsTable.$converterperiod.toSql(period));
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || month != null) {
      map['month'] = Variable<int>(month);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['notify_at_threshold'] = Variable<bool>(notifyAtThreshold);
    map['threshold_percentage'] = Variable<int>(thresholdPercentage);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      targetAmount: Value(targetAmount),
      period: Value(period),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      month:
          month == null && nullToAbsent ? const Value.absent() : Value(month),
      currencyCode: Value(currencyCode),
      notifyAtThreshold: Value(notifyAtThreshold),
      thresholdPercentage: Value(thresholdPercentage),
    );
  }

  factory BudgetData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetData(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      period: $BudgetsTable.$converterperiod
          .fromJson(serializer.fromJson<int>(json['period'])),
      year: serializer.fromJson<int?>(json['year']),
      month: serializer.fromJson<int?>(json['month']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      notifyAtThreshold: serializer.fromJson<bool>(json['notifyAtThreshold']),
      thresholdPercentage:
          serializer.fromJson<int>(json['thresholdPercentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int?>(categoryId),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'period':
          serializer.toJson<int>($BudgetsTable.$converterperiod.toJson(period)),
      'year': serializer.toJson<int?>(year),
      'month': serializer.toJson<int?>(month),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'notifyAtThreshold': serializer.toJson<bool>(notifyAtThreshold),
      'thresholdPercentage': serializer.toJson<int>(thresholdPercentage),
    };
  }

  BudgetData copyWith(
          {int? id,
          Value<int?> categoryId = const Value.absent(),
          int? targetAmount,
          BudgetPeriod? period,
          Value<int?> year = const Value.absent(),
          Value<int?> month = const Value.absent(),
          String? currencyCode,
          bool? notifyAtThreshold,
          int? thresholdPercentage}) =>
      BudgetData(
        id: id ?? this.id,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        targetAmount: targetAmount ?? this.targetAmount,
        period: period ?? this.period,
        year: year.present ? year.value : this.year,
        month: month.present ? month.value : this.month,
        currencyCode: currencyCode ?? this.currencyCode,
        notifyAtThreshold: notifyAtThreshold ?? this.notifyAtThreshold,
        thresholdPercentage: thresholdPercentage ?? this.thresholdPercentage,
      );
  BudgetData copyWithCompanion(BudgetsCompanion data) {
    return BudgetData(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      period: data.period.present ? data.period.value : this.period,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      notifyAtThreshold: data.notifyAtThreshold.present
          ? data.notifyAtThreshold.value
          : this.notifyAtThreshold,
      thresholdPercentage: data.thresholdPercentage.present
          ? data.thresholdPercentage.value
          : this.thresholdPercentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('period: $period, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('notifyAtThreshold: $notifyAtThreshold, ')
          ..write('thresholdPercentage: $thresholdPercentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, targetAmount, period, year,
      month, currencyCode, notifyAtThreshold, thresholdPercentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.targetAmount == this.targetAmount &&
          other.period == this.period &&
          other.year == this.year &&
          other.month == this.month &&
          other.currencyCode == this.currencyCode &&
          other.notifyAtThreshold == this.notifyAtThreshold &&
          other.thresholdPercentage == this.thresholdPercentage);
}

class BudgetsCompanion extends UpdateCompanion<BudgetData> {
  final Value<int> id;
  final Value<int?> categoryId;
  final Value<int> targetAmount;
  final Value<BudgetPeriod> period;
  final Value<int?> year;
  final Value<int?> month;
  final Value<String> currencyCode;
  final Value<bool> notifyAtThreshold;
  final Value<int> thresholdPercentage;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.notifyAtThreshold = const Value.absent(),
    this.thresholdPercentage = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int targetAmount,
    required BudgetPeriod period,
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.notifyAtThreshold = const Value.absent(),
    this.thresholdPercentage = const Value.absent(),
  })  : targetAmount = Value(targetAmount),
        period = Value(period);
  static Insertable<BudgetData> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? targetAmount,
    Expression<int>? period,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? currencyCode,
    Expression<bool>? notifyAtThreshold,
    Expression<int>? thresholdPercentage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (period != null) 'period': period,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (notifyAtThreshold != null) 'notify_at_threshold': notifyAtThreshold,
      if (thresholdPercentage != null)
        'threshold_percentage': thresholdPercentage,
    });
  }

  BudgetsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? categoryId,
      Value<int>? targetAmount,
      Value<BudgetPeriod>? period,
      Value<int?>? year,
      Value<int?>? month,
      Value<String>? currencyCode,
      Value<bool>? notifyAtThreshold,
      Value<int>? thresholdPercentage}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      targetAmount: targetAmount ?? this.targetAmount,
      period: period ?? this.period,
      year: year ?? this.year,
      month: month ?? this.month,
      currencyCode: currencyCode ?? this.currencyCode,
      notifyAtThreshold: notifyAtThreshold ?? this.notifyAtThreshold,
      thresholdPercentage: thresholdPercentage ?? this.thresholdPercentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (period.present) {
      map['period'] =
          Variable<int>($BudgetsTable.$converterperiod.toSql(period.value));
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (notifyAtThreshold.present) {
      map['notify_at_threshold'] = Variable<bool>(notifyAtThreshold.value);
    }
    if (thresholdPercentage.present) {
      map['threshold_percentage'] = Variable<int>(thresholdPercentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('period: $period, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('notifyAtThreshold: $notifyAtThreshold, ')
          ..write('thresholdPercentage: $thresholdPercentage')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
      'bio', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, phone, bio, imagePath, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('bio')) {
      context.handle(
          _bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      bio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bio']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfileData(
      {required this.id,
      required this.name,
      this.email,
      this.phone,
      this.bio,
      this.imagePath,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      bio: serializer.fromJson<String?>(json['bio']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'bio': serializer.toJson<String?>(bio),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileData copyWith(
          {int? id,
          String? name,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> bio = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        bio: bio.present ? bio.value : this.bio,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfileData copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      bio: data.bio.present ? data.bio.value : this.bio,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('bio: $bio, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, phone, bio, imagePath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.bio == this.bio &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> bio;
  final Value<String?> imagePath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.bio = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.bio = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? bio,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? bio,
      Value<String?>? imagePath,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('bio: $bio, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SubcategoriesTable subcategories = $SubcategoriesTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransactionTagsTable transactionTags =
      $TransactionTagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final Index idxTransactionsTimestamp = Index(
      'idx_transactions_timestamp',
      'CREATE INDEX idx_transactions_timestamp ON transactions (timestamp)');
  late final Index idxTransactionsCategoryId = Index(
      'idx_transactions_category_id',
      'CREATE INDEX idx_transactions_category_id ON transactions (category_id)');
  late final Index idxTagsName =
      Index('idx_tags_name', 'CREATE INDEX idx_tags_name ON tags (name)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        subcategories,
        recurringTransactions,
        transactions,
        tags,
        transactionTags,
        attachments,
        budgets,
        userProfiles,
        idxTransactionsTimestamp,
        idxTransactionsCategoryId,
        idxTagsName
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subcategories', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('subcategories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recurring_transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('subcategories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recurring_transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transaction_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transaction_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('budgets', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String icon,
  required String color,
  required TransactionType type,
  Value<bool> isDefault,
  Value<int> sortOrder,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<String> color,
  Value<TransactionType> type,
  Value<bool> isDefault,
  Value<int> sortOrder,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryData> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubcategoriesTable, List<SubcategoryData>>
      _subcategoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.subcategories,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.subcategories.parentCategoryId));

  $$SubcategoriesTableProcessedTableManager get subcategoriesRefs {
    final manager = $$SubcategoriesTableTableManager($_db, $_db.subcategories)
        .filter((f) => f.parentCategoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_subcategoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringTransactionsTable,
      List<RecurringTransactionData>> _recurringTransactionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTransactions,
          aliasName: $_aliasNameGenerator(
              db.categories.id, db.recurringTransactions.categoryId));

  $$RecurringTransactionsTableProcessedTableManager
      get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
            $_db, $_db.recurringTransactions)
        .filter((f) => f.categoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionData>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.transactions.categoryId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetsTable, List<BudgetData>> _budgetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.budgets,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.budgets.categoryId));

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  Expression<bool> subcategoriesRefs(
      Expression<bool> Function($$SubcategoriesTableFilterComposer f) f) {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.parentCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableFilterComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> recurringTransactionsRefs(
      Expression<bool> Function($$RecurringTransactionsTableFilterComposer f)
          f) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableFilterComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetsRefs(
      Expression<bool> Function($$BudgetsTableFilterComposer f) f) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> subcategoriesRefs<T extends Object>(
      Expression<T> Function($$SubcategoriesTableAnnotationComposer a) f) {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.parentCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> recurringTransactionsRefs<T extends Object>(
      Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a)
          f) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableAnnotationComposer a) f) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryData, $$CategoriesTableReferences),
    CategoryData,
    PrefetchHooks Function(
        {bool subcategoriesRefs,
        bool recurringTransactionsRefs,
        bool transactionsRefs,
        bool budgetsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String icon,
            required String color,
            required TransactionType type,
            Value<bool> isDefault = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {subcategoriesRefs = false,
              recurringTransactionsRefs = false,
              transactionsRefs = false,
              budgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subcategoriesRefs) db.subcategories,
                if (recurringTransactionsRefs) db.recurringTransactions,
                if (transactionsRefs) db.transactions,
                if (budgetsRefs) db.budgets
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subcategoriesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._subcategoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .subcategoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.parentCategoryId == item.id),
                        typedResults: items),
                  if (recurringTransactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._recurringTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .recurringTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._budgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryData, $$CategoriesTableReferences),
    CategoryData,
    PrefetchHooks Function(
        {bool subcategoriesRefs,
        bool recurringTransactionsRefs,
        bool transactionsRefs,
        bool budgetsRefs})>;
typedef $$SubcategoriesTableCreateCompanionBuilder = SubcategoriesCompanion
    Function({
  Value<int> id,
  required int parentCategoryId,
  required String name,
});
typedef $$SubcategoriesTableUpdateCompanionBuilder = SubcategoriesCompanion
    Function({
  Value<int> id,
  Value<int> parentCategoryId,
  Value<String> name,
});

final class $$SubcategoriesTableReferences extends BaseReferences<_$AppDatabase,
    $SubcategoriesTable, SubcategoryData> {
  $$SubcategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentCategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.subcategories.parentCategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get parentCategoryId {
    if ($_item.parentCategoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.parentCategoryId!));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RecurringTransactionsTable,
      List<RecurringTransactionData>> _recurringTransactionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTransactions,
          aliasName: $_aliasNameGenerator(
              db.subcategories.id, db.recurringTransactions.subcategoryId));

  $$RecurringTransactionsTableProcessedTableManager
      get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
            $_db, $_db.recurringTransactions)
        .filter((f) => f.subcategoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_recurringTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionData>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.subcategories.id, db.transactions.subcategoryId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.subcategoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubcategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get parentCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> recurringTransactionsRefs(
      Expression<bool> Function($$RecurringTransactionsTableFilterComposer f)
          f) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.subcategoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableFilterComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.subcategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubcategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get parentCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubcategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> recurringTransactionsRefs<T extends Object>(
      Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a)
          f) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.subcategoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.subcategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubcategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubcategoriesTable,
    SubcategoryData,
    $$SubcategoriesTableFilterComposer,
    $$SubcategoriesTableOrderingComposer,
    $$SubcategoriesTableAnnotationComposer,
    $$SubcategoriesTableCreateCompanionBuilder,
    $$SubcategoriesTableUpdateCompanionBuilder,
    (SubcategoryData, $$SubcategoriesTableReferences),
    SubcategoryData,
    PrefetchHooks Function(
        {bool parentCategoryId,
        bool recurringTransactionsRefs,
        bool transactionsRefs})> {
  $$SubcategoriesTableTableManager(_$AppDatabase db, $SubcategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubcategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubcategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubcategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> parentCategoryId = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              SubcategoriesCompanion(
            id: id,
            parentCategoryId: parentCategoryId,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int parentCategoryId,
            required String name,
          }) =>
              SubcategoriesCompanion.insert(
            id: id,
            parentCategoryId: parentCategoryId,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubcategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {parentCategoryId = false,
              recurringTransactionsRefs = false,
              transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringTransactionsRefs) db.recurringTransactions,
                if (transactionsRefs) db.transactions
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (parentCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentCategoryId,
                    referencedTable: $$SubcategoriesTableReferences
                        ._parentCategoryIdTable(db),
                    referencedColumn: $$SubcategoriesTableReferences
                        ._parentCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringTransactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SubcategoriesTableReferences
                            ._recurringTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubcategoriesTableReferences(db, table, p0)
                                .recurringTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subcategoryId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SubcategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubcategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subcategoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubcategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubcategoriesTable,
    SubcategoryData,
    $$SubcategoriesTableFilterComposer,
    $$SubcategoriesTableOrderingComposer,
    $$SubcategoriesTableAnnotationComposer,
    $$SubcategoriesTableCreateCompanionBuilder,
    $$SubcategoriesTableUpdateCompanionBuilder,
    (SubcategoryData, $$SubcategoriesTableReferences),
    SubcategoryData,
    PrefetchHooks Function(
        {bool parentCategoryId,
        bool recurringTransactionsRefs,
        bool transactionsRefs})>;
typedef $$RecurringTransactionsTableCreateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<int> id,
  required TransactionType type,
  required int amount,
  required int categoryId,
  Value<int?> subcategoryId,
  Value<String?> note,
  required RecurrenceFrequency frequency,
  required DateTime nextDueDate,
  Value<bool> isAutoCreate,
  Value<bool> isActive,
  Value<DateTime?> lastProcessedDate,
});
typedef $$RecurringTransactionsTableUpdateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<int> id,
  Value<TransactionType> type,
  Value<int> amount,
  Value<int> categoryId,
  Value<int?> subcategoryId,
  Value<String?> note,
  Value<RecurrenceFrequency> frequency,
  Value<DateTime> nextDueDate,
  Value<bool> isAutoCreate,
  Value<bool> isActive,
  Value<DateTime?> lastProcessedDate,
});

final class $$RecurringTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTransactionsTable, RecurringTransactionData> {
  $$RecurringTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.recurringTransactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubcategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.subcategories.createAlias($_aliasNameGenerator(
          db.recurringTransactions.subcategoryId, db.subcategories.id));

  $$SubcategoriesTableProcessedTableManager? get subcategoryId {
    if ($_item.subcategoryId == null) return null;
    final manager = $$SubcategoriesTableTableManager($_db, $_db.subcategories)
        .filter((f) => f.id($_item.subcategoryId!));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionData>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(db.recurringTransactions.id,
                  db.transactions.recurringTransactionId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.recurringTransactionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurrenceFrequency, RecurrenceFrequency, int>
      get frequency => $composableBuilder(
          column: $table.frequency,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAutoCreate => $composableBuilder(
      column: $table.isAutoCreate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastProcessedDate => $composableBuilder(
      column: $table.lastProcessedDate,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableFilterComposer get subcategoryId {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableFilterComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.recurringTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAutoCreate => $composableBuilder(
      column: $table.isAutoCreate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastProcessedDate => $composableBuilder(
      column: $table.lastProcessedDate,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableOrderingComposer get subcategoryId {
    final $$SubcategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<bool> get isAutoCreate => $composableBuilder(
      column: $table.isAutoCreate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastProcessedDate => $composableBuilder(
      column: $table.lastProcessedDate, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableAnnotationComposer get subcategoryId {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.recurringTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTransactionsTable,
    RecurringTransactionData,
    $$RecurringTransactionsTableFilterComposer,
    $$RecurringTransactionsTableOrderingComposer,
    $$RecurringTransactionsTableAnnotationComposer,
    $$RecurringTransactionsTableCreateCompanionBuilder,
    $$RecurringTransactionsTableUpdateCompanionBuilder,
    (RecurringTransactionData, $$RecurringTransactionsTableReferences),
    RecurringTransactionData,
    PrefetchHooks Function(
        {bool categoryId, bool subcategoryId, bool transactionsRefs})> {
  $$RecurringTransactionsTableTableManager(
      _$AppDatabase db, $RecurringTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> subcategoryId = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<RecurrenceFrequency> frequency = const Value.absent(),
            Value<DateTime> nextDueDate = const Value.absent(),
            Value<bool> isAutoCreate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastProcessedDate = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            note: note,
            frequency: frequency,
            nextDueDate: nextDueDate,
            isAutoCreate: isAutoCreate,
            isActive: isActive,
            lastProcessedDate: lastProcessedDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required TransactionType type,
            required int amount,
            required int categoryId,
            Value<int?> subcategoryId = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required RecurrenceFrequency frequency,
            required DateTime nextDueDate,
            Value<bool> isAutoCreate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastProcessedDate = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            note: note,
            frequency: frequency,
            nextDueDate: nextDueDate,
            isAutoCreate: isAutoCreate,
            isActive: isActive,
            lastProcessedDate: lastProcessedDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              subcategoryId = false,
              transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$RecurringTransactionsTableReferences
                        ._categoryIdTable(db),
                    referencedColumn: $$RecurringTransactionsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (subcategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcategoryId,
                    referencedTable: $$RecurringTransactionsTableReferences
                        ._subcategoryIdTable(db),
                    referencedColumn: $$RecurringTransactionsTableReferences
                        ._subcategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RecurringTransactionsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTransactionsTableReferences(
                                    db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringTransactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecurringTransactionsTable,
        RecurringTransactionData,
        $$RecurringTransactionsTableFilterComposer,
        $$RecurringTransactionsTableOrderingComposer,
        $$RecurringTransactionsTableAnnotationComposer,
        $$RecurringTransactionsTableCreateCompanionBuilder,
        $$RecurringTransactionsTableUpdateCompanionBuilder,
        (RecurringTransactionData, $$RecurringTransactionsTableReferences),
        RecurringTransactionData,
        PrefetchHooks Function(
            {bool categoryId, bool subcategoryId, bool transactionsRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required TransactionType type,
  required int amount,
  Value<String> currencyCode,
  required int categoryId,
  Value<int?> subcategoryId,
  Value<int?> recurringTransactionId,
  required DateTime timestamp,
  Value<String?> note,
  Value<PaymentMethod?> paymentMethod,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<TransactionType> type,
  Value<int> amount,
  Value<String> currencyCode,
  Value<int> categoryId,
  Value<int?> subcategoryId,
  Value<int?> recurringTransactionId,
  Value<DateTime> timestamp,
  Value<String?> note,
  Value<PaymentMethod?> paymentMethod,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionData> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.transactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubcategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.subcategories.createAlias($_aliasNameGenerator(
          db.transactions.subcategoryId, db.subcategories.id));

  $$SubcategoriesTableProcessedTableManager? get subcategoryId {
    if ($_item.subcategoryId == null) return null;
    final manager = $$SubcategoriesTableTableManager($_db, $_db.subcategories)
        .filter((f) => f.id($_item.subcategoryId!));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RecurringTransactionsTable _recurringTransactionIdTable(
          _$AppDatabase db) =>
      db.recurringTransactions.createAlias($_aliasNameGenerator(
          db.transactions.recurringTransactionId, db.recurringTransactions.id));

  $$RecurringTransactionsTableProcessedTableManager?
      get recurringTransactionId {
    if ($_item.recurringTransactionId == null) return null;
    final manager = $$RecurringTransactionsTableTableManager(
            $_db, $_db.recurringTransactions)
        .filter((f) => f.id($_item.recurringTransactionId!));
    final item =
        $_typedResult.readTableOrNull(_recurringTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTagData>>
      _transactionTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionTags,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.transactionTags.transactionId));

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager =
        $$TransactionTagsTableTableManager($_db, $_db.transactionTags)
            .filter((f) => f.transactionId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_transactionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentData>>
      _attachmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attachments,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.attachments.transactionId));

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter((f) => f.transactionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, int>
      get paymentMethod => $composableBuilder(
          column: $table.paymentMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableFilterComposer get subcategoryId {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableFilterComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTransactionsTableFilterComposer get recurringTransactionId {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recurringTransactionId,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableFilterComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<bool> transactionTagsRefs(
      Expression<bool> Function($$TransactionTagsTableFilterComposer f) f) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableFilterComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
      Expression<bool> Function($$AttachmentsTableFilterComposer f) f) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableOrderingComposer get subcategoryId {
    final $$SubcategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTransactionsTableOrderingComposer get recurringTransactionId {
    final $$RecurringTransactionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recurringTransactionId,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod?, int> get paymentMethod =>
      $composableBuilder(
          column: $table.paymentMethod, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubcategoriesTableAnnotationComposer get subcategoryId {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.subcategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.subcategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTransactionsTableAnnotationComposer get recurringTransactionId {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recurringTransactionId,
            referencedTable: $db.recurringTransactions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> transactionTagsRefs<T extends Object>(
      Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
      Expression<T> Function($$AttachmentsTableAnnotationComposer a) f) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionData,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TransactionData, $$TransactionsTableReferences),
    TransactionData,
    PrefetchHooks Function(
        {bool categoryId,
        bool subcategoryId,
        bool recurringTransactionId,
        bool transactionTagsRefs,
        bool attachmentsRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> subcategoryId = const Value.absent(),
            Value<int?> recurringTransactionId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            currencyCode: currencyCode,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            recurringTransactionId: recurringTransactionId,
            timestamp: timestamp,
            note: note,
            paymentMethod: paymentMethod,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required TransactionType type,
            required int amount,
            Value<String> currencyCode = const Value.absent(),
            required int categoryId,
            Value<int?> subcategoryId = const Value.absent(),
            Value<int?> recurringTransactionId = const Value.absent(),
            required DateTime timestamp,
            Value<String?> note = const Value.absent(),
            Value<PaymentMethod?> paymentMethod = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            currencyCode: currencyCode,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            recurringTransactionId: recurringTransactionId,
            timestamp: timestamp,
            note: note,
            paymentMethod: paymentMethod,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              subcategoryId = false,
              recurringTransactionId = false,
              transactionTagsRefs = false,
              attachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionTagsRefs) db.transactionTags,
                if (attachmentsRefs) db.attachments
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$TransactionsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (subcategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcategoryId,
                    referencedTable:
                        $$TransactionsTableReferences._subcategoryIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._subcategoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (recurringTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurringTransactionId,
                    referencedTable: $$TransactionsTableReferences
                        ._recurringTransactionIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._recurringTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._transactionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .transactionTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (attachmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._attachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .attachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TransactionData,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TransactionData, $$TransactionsTableReferences),
    TransactionData,
    PrefetchHooks Function(
        {bool categoryId,
        bool subcategoryId,
        bool recurringTransactionId,
        bool transactionTagsRefs,
        bool attachmentsRefs})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagData> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTagData>>
      _transactionTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionTags,
              aliasName:
                  $_aliasNameGenerator(db.tags.id, db.transactionTags.tagId));

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager =
        $$TransactionTagsTableTableManager($_db, $_db.transactionTags)
            .filter((f) => f.tagId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_transactionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionTagsRefs(
      Expression<bool> Function($$TransactionTagsTableFilterComposer f) f) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableFilterComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> transactionTagsRefs<T extends Object>(
      Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, $$TagsTableReferences),
    TagData,
    PrefetchHooks Function({bool transactionTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({transactionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionTagsRefs) db.transactionTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._transactionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0)
                                .transactionTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, $$TagsTableReferences),
    TagData,
    PrefetchHooks Function({bool transactionTagsRefs})>;
typedef $$TransactionTagsTableCreateCompanionBuilder = TransactionTagsCompanion
    Function({
  required int transactionId,
  required int tagId,
  Value<int> rowid,
});
typedef $$TransactionTagsTableUpdateCompanionBuilder = TransactionTagsCompanion
    Function({
  Value<int> transactionId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$TransactionTagsTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionTagsTable, TransactionTagData> {
  $$TransactionTagsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.transactionTags.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get transactionId {
    if ($_item.transactionId == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id($_item.transactionId!));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.transactionTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager? get tagId {
    if ($_item.tagId == null) return null;
    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id($_item.tagId!));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionTagsTable,
    TransactionTagData,
    $$TransactionTagsTableFilterComposer,
    $$TransactionTagsTableOrderingComposer,
    $$TransactionTagsTableAnnotationComposer,
    $$TransactionTagsTableCreateCompanionBuilder,
    $$TransactionTagsTableUpdateCompanionBuilder,
    (TransactionTagData, $$TransactionTagsTableReferences),
    TransactionTagData,
    PrefetchHooks Function({bool transactionId, bool tagId})> {
  $$TransactionTagsTableTableManager(
      _$AppDatabase db, $TransactionTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> transactionId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionTagsCompanion(
            transactionId: transactionId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int transactionId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionTagsCompanion.insert(
            transactionId: transactionId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionTagsTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionTagsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$TransactionTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$TransactionTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionTagsTable,
    TransactionTagData,
    $$TransactionTagsTableFilterComposer,
    $$TransactionTagsTableOrderingComposer,
    $$TransactionTagsTableAnnotationComposer,
    $$TransactionTagsTableCreateCompanionBuilder,
    $$TransactionTagsTableUpdateCompanionBuilder,
    (TransactionTagData, $$TransactionTagsTableReferences),
    TransactionTagData,
    PrefetchHooks Function({bool transactionId, bool tagId})>;
typedef $$AttachmentsTableCreateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<int> id,
  required int transactionId,
  required String filePath,
});
typedef $$AttachmentsTableUpdateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<int> id,
  Value<int> transactionId,
  Value<String> filePath,
});

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentData> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.attachments.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get transactionId {
    if ($_item.transactionId == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id($_item.transactionId!));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    AttachmentData,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (AttachmentData, $$AttachmentsTableReferences),
    AttachmentData,
    PrefetchHooks Function({bool transactionId})> {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
          }) =>
              AttachmentsCompanion(
            id: id,
            transactionId: transactionId,
            filePath: filePath,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required String filePath,
          }) =>
              AttachmentsCompanion.insert(
            id: id,
            transactionId: transactionId,
            filePath: filePath,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$AttachmentsTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$AttachmentsTableReferences._transactionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    AttachmentData,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (AttachmentData, $$AttachmentsTableReferences),
    AttachmentData,
    PrefetchHooks Function({bool transactionId})>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  required int targetAmount,
  required BudgetPeriod period,
  Value<int?> year,
  Value<int?> month,
  Value<String> currencyCode,
  Value<bool> notifyAtThreshold,
  Value<int> thresholdPercentage,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  Value<int?> categoryId,
  Value<int> targetAmount,
  Value<BudgetPeriod> period,
  Value<int?> year,
  Value<int?> month,
  Value<String> currencyCode,
  Value<bool> notifyAtThreshold,
  Value<int> thresholdPercentage,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, BudgetData> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.budgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BudgetPeriod, BudgetPeriod, int> get period =>
      $composableBuilder(
          column: $table.period,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notifyAtThreshold => $composableBuilder(
      column: $table.notifyAtThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get thresholdPercentage => $composableBuilder(
      column: $table.thresholdPercentage,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notifyAtThreshold => $composableBuilder(
      column: $table.notifyAtThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get thresholdPercentage => $composableBuilder(
      column: $table.thresholdPercentage,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BudgetPeriod, int> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<bool> get notifyAtThreshold => $composableBuilder(
      column: $table.notifyAtThreshold, builder: (column) => column);

  GeneratedColumn<int> get thresholdPercentage => $composableBuilder(
      column: $table.thresholdPercentage, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetData,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetData, $$BudgetsTableReferences),
    BudgetData,
    PrefetchHooks Function({bool categoryId})> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> targetAmount = const Value.absent(),
            Value<BudgetPeriod> period = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<int?> month = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<bool> notifyAtThreshold = const Value.absent(),
            Value<int> thresholdPercentage = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryId: categoryId,
            targetAmount: targetAmount,
            period: period,
            year: year,
            month: month,
            currencyCode: currencyCode,
            notifyAtThreshold: notifyAtThreshold,
            thresholdPercentage: thresholdPercentage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required int targetAmount,
            required BudgetPeriod period,
            Value<int?> year = const Value.absent(),
            Value<int?> month = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<bool> notifyAtThreshold = const Value.absent(),
            Value<int> thresholdPercentage = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            targetAmount: targetAmount,
            period: period,
            year: year,
            month: month,
            currencyCode: currencyCode,
            notifyAtThreshold: notifyAtThreshold,
            thresholdPercentage: thresholdPercentage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BudgetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BudgetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetData,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetData, $$BudgetsTableReferences),
    BudgetData,
    PrefetchHooks Function({bool categoryId})>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> bio,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> bio,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bio => $composableBuilder(
      column: $table.bio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bio => $composableBuilder(
      column: $table.bio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileData,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> bio = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            name: name,
            email: email,
            phone: phone,
            bio: bio,
            imagePath: imagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> bio = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            name: name,
            email: email,
            phone: phone,
            bio: bio,
            imagePath: imagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileData,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SubcategoriesTableTableManager get subcategories =>
      $$SubcategoriesTableTableManager(_db, _db.subcategories);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
