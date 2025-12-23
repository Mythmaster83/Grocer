// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGroceryListCollection on Isar {
  IsarCollection<GroceryList> get groceryLists => this.collection();
}

const GroceryListSchema = CollectionSchema(
  name: r'GroceryList',
  id: 7373088707388194375,
  properties: {
    r'dayOfWeek': PropertySchema(
      id: 0,
      name: r'dayOfWeek',
      type: IsarType.long,
    ),
    r'frequency': PropertySchema(
      id: 1,
      name: r'frequency',
      type: IsarType.string,
      enumMap: _GroceryListfrequencyEnumValueMap,
    ),
    r'imagePath': PropertySchema(
      id: 2,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isStockList': PropertySchema(
      id: 4,
      name: r'isStockList',
      type: IsarType.bool,
    ),
    r'lastCompletedDate': PropertySchema(
      id: 5,
      name: r'lastCompletedDate',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'scheduledDate': PropertySchema(
      id: 7,
      name: r'scheduledDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _groceryListEstimateSize,
  serialize: _groceryListSerialize,
  deserialize: _groceryListDeserialize,
  deserializeProp: _groceryListDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _groceryListGetId,
  getLinks: _groceryListGetLinks,
  attach: _groceryListAttach,
  version: '3.1.0+1',
);

int _groceryListEstimateSize(
  GroceryList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.frequency;
    if (value != null) {
      bytesCount += 3 + value.name.length * 3;
    }
  }
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _groceryListSerialize(
  GroceryList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dayOfWeek);
  writer.writeString(offsets[1], object.frequency?.name);
  writer.writeString(offsets[2], object.imagePath);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeBool(offsets[4], object.isStockList);
  writer.writeDateTime(offsets[5], object.lastCompletedDate);
  writer.writeString(offsets[6], object.name);
  writer.writeDateTime(offsets[7], object.scheduledDate);
}

GroceryList _groceryListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroceryList(
    dayOfWeek: reader.readLongOrNull(offsets[0]),
    frequency:
        _GroceryListfrequencyValueEnumMap[reader.readStringOrNull(offsets[1])],
    id: id,
    imagePath: reader.readStringOrNull(offsets[2]),
    isCompleted: reader.readBoolOrNull(offsets[3]) ?? false,
    isStockList: reader.readBool(offsets[4]),
    lastCompletedDate: reader.readDateTimeOrNull(offsets[5]),
    name: reader.readString(offsets[6]),
    scheduledDate: reader.readDateTimeOrNull(offsets[7]),
  );
  return object;
}

P _groceryListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (_GroceryListfrequencyValueEnumMap[
          reader.readStringOrNull(offset)]) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GroceryListfrequencyEnumValueMap = {
  r'once': r'once',
  r'weekly': r'weekly',
  r'biweekly': r'biweekly',
  r'monthly': r'monthly',
};
const _GroceryListfrequencyValueEnumMap = {
  r'once': ScheduleFrequency.once,
  r'weekly': ScheduleFrequency.weekly,
  r'biweekly': ScheduleFrequency.biweekly,
  r'monthly': ScheduleFrequency.monthly,
};

Id _groceryListGetId(GroceryList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groceryListGetLinks(GroceryList object) {
  return [];
}

void _groceryListAttach(
    IsarCollection<dynamic> col, Id id, GroceryList object) {
  object.id = id;
}

extension GroceryListQueryWhereSort
    on QueryBuilder<GroceryList, GroceryList, QWhere> {
  QueryBuilder<GroceryList, GroceryList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GroceryListQueryWhere
    on QueryBuilder<GroceryList, GroceryList, QWhereClause> {
  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GroceryListQueryFilter
    on QueryBuilder<GroceryList, GroceryList, QFilterCondition> {
  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dayOfWeek',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dayOfWeek',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      dayOfWeekBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'frequency',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'frequency',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyEqualTo(
    ScheduleFrequency? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyGreaterThan(
    ScheduleFrequency? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyLessThan(
    ScheduleFrequency? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyBetween(
    ScheduleFrequency? lower,
    ScheduleFrequency? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      frequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      isStockListEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStockList',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCompletedDate',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCompletedDate',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCompletedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCompletedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCompletedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      lastCompletedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCompletedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledDate',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledDate',
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterFilterCondition>
      scheduledDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GroceryListQueryObject
    on QueryBuilder<GroceryList, GroceryList, QFilterCondition> {}

extension GroceryListQueryLinks
    on QueryBuilder<GroceryList, GroceryList, QFilterCondition> {}

extension GroceryListQuerySortBy
    on QueryBuilder<GroceryList, GroceryList, QSortBy> {
  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByIsStockList() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStockList', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByIsStockListDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStockList', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      sortByLastCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletedDate', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      sortByLastCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletedDate', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> sortByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      sortByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }
}

extension GroceryListQuerySortThenBy
    on QueryBuilder<GroceryList, GroceryList, QSortThenBy> {
  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfWeek', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByIsStockList() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStockList', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByIsStockListDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStockList', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      thenByLastCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletedDate', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      thenByLastCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompletedDate', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy> thenByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QAfterSortBy>
      thenByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }
}

extension GroceryListQueryWhereDistinct
    on QueryBuilder<GroceryList, GroceryList, QDistinct> {
  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayOfWeek');
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByFrequency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByIsStockList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStockList');
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct>
      distinctByLastCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCompletedDate');
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroceryList, GroceryList, QDistinct> distinctByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDate');
    });
  }
}

extension GroceryListQueryProperty
    on QueryBuilder<GroceryList, GroceryList, QQueryProperty> {
  QueryBuilder<GroceryList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroceryList, int?, QQueryOperations> dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayOfWeek');
    });
  }

  QueryBuilder<GroceryList, ScheduleFrequency?, QQueryOperations>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<GroceryList, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<GroceryList, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<GroceryList, bool, QQueryOperations> isStockListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStockList');
    });
  }

  QueryBuilder<GroceryList, DateTime?, QQueryOperations>
      lastCompletedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCompletedDate');
    });
  }

  QueryBuilder<GroceryList, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<GroceryList, DateTime?, QQueryOperations>
      scheduledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDate');
    });
  }
}
