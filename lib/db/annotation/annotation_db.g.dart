// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnnotationDbCollection on Isar {
  IsarCollection<AnnotationDb> get annotationDbs => this.collection();
}

const AnnotationDbSchema = CollectionSchema(
  name: r'AnnotationDb',
  id: 7731690199461184975,
  properties: {
    r'afterContext': PropertySchema(
      id: 0,
      name: r'afterContext',
      type: IsarType.string,
    ),
    r'articleId': PropertySchema(
      id: 1,
      name: r'articleId',
      type: IsarType.long,
    ),
    r'beforeContext': PropertySchema(
      id: 2,
      name: r'beforeContext',
      type: IsarType.string,
    ),
    r'colorType': PropertySchema(
      id: 3,
      name: r'colorType',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'endOffset': PropertySchema(
      id: 5,
      name: r'endOffset',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    ),
    r'selectedText': PropertySchema(
      id: 7,
      name: r'selectedText',
      type: IsarType.string,
    ),
    r'startOffset': PropertySchema(
      id: 8,
      name: r'startOffset',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _annotationDbEstimateSize,
  serialize: _annotationDbSerialize,
  deserialize: _annotationDbDeserialize,
  deserializeProp: _annotationDbDeserializeProp,
  idName: r'id',
  indexes: {
    r'articleId': IndexSchema(
      id: 2849477555030470394,
      name: r'articleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'articleId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'colorType': IndexSchema(
      id: -5936211828681974607,
      name: r'colorType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'colorType',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _annotationDbGetId,
  getLinks: _annotationDbGetLinks,
  attach: _annotationDbAttach,
  version: '3.1.8',
);

int _annotationDbEstimateSize(
  AnnotationDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.afterContext;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.beforeContext;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedText.length * 3;
  return bytesCount;
}

void _annotationDbSerialize(
  AnnotationDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.afterContext);
  writer.writeLong(offsets[1], object.articleId);
  writer.writeString(offsets[2], object.beforeContext);
  writer.writeLong(offsets[3], object.colorType);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeLong(offsets[5], object.endOffset);
  writer.writeString(offsets[6], object.note);
  writer.writeString(offsets[7], object.selectedText);
  writer.writeLong(offsets[8], object.startOffset);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

AnnotationDb _annotationDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnnotationDb();
  object.afterContext = reader.readStringOrNull(offsets[0]);
  object.articleId = reader.readLong(offsets[1]);
  object.beforeContext = reader.readStringOrNull(offsets[2]);
  object.colorType = reader.readLong(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.endOffset = reader.readLong(offsets[5]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[6]);
  object.selectedText = reader.readString(offsets[7]);
  object.startOffset = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _annotationDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _annotationDbGetId(AnnotationDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _annotationDbGetLinks(AnnotationDb object) {
  return [];
}

void _annotationDbAttach(
    IsarCollection<dynamic> col, Id id, AnnotationDb object) {
  object.id = id;
}

extension AnnotationDbQueryWhereSort
    on QueryBuilder<AnnotationDb, AnnotationDb, QWhere> {
  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhere> anyArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'articleId'),
      );
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhere> anyColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'colorType'),
      );
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension AnnotationDbQueryWhere
    on QueryBuilder<AnnotationDb, AnnotationDb, QWhereClause> {
  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> articleIdEqualTo(
      int articleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'articleId',
        value: [articleId],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      articleIdNotEqualTo(int articleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleId',
              lower: [],
              upper: [articleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleId',
              lower: [articleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleId',
              lower: [articleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleId',
              lower: [],
              upper: [articleId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      articleIdGreaterThan(
    int articleId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleId',
        lower: [articleId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> articleIdLessThan(
    int articleId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleId',
        lower: [],
        upper: [articleId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> articleIdBetween(
    int lowerArticleId,
    int upperArticleId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleId',
        lower: [lowerArticleId],
        includeLower: includeLower,
        upper: [upperArticleId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> colorTypeEqualTo(
      int colorType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'colorType',
        value: [colorType],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      colorTypeNotEqualTo(int colorType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'colorType',
              lower: [],
              upper: [colorType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'colorType',
              lower: [colorType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'colorType',
              lower: [colorType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'colorType',
              lower: [],
              upper: [colorType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      colorTypeGreaterThan(
    int colorType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'colorType',
        lower: [colorType],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> colorTypeLessThan(
    int colorType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'colorType',
        lower: [],
        upper: [colorType],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> colorTypeBetween(
    int lowerColorType,
    int upperColorType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'colorType',
        lower: [lowerColorType],
        includeLower: includeLower,
        upper: [upperColorType],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> updatedAtEqualTo(
      DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause>
      updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterWhereClause> updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnnotationDbQueryFilter
    on QueryBuilder<AnnotationDb, AnnotationDb, QFilterCondition> {
  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'afterContext',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'afterContext',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'afterContext',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'afterContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterContext',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      afterContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'afterContext',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      articleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      articleIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'articleId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      articleIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'articleId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      articleIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'articleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'beforeContext',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'beforeContext',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'beforeContext',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'beforeContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeContext',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      beforeContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'beforeContext',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      colorTypeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorType',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      colorTypeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorType',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      colorTypeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorType',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      colorTypeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      endOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      endOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      endOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      endOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      selectedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      startOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      startOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      startOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      startOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnnotationDbQueryObject
    on QueryBuilder<AnnotationDb, AnnotationDb, QFilterCondition> {}

extension AnnotationDbQueryLinks
    on QueryBuilder<AnnotationDb, AnnotationDb, QFilterCondition> {}

extension AnnotationDbQuerySortBy
    on QueryBuilder<AnnotationDb, AnnotationDb, QSortBy> {
  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByAfterContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      sortByAfterContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByBeforeContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      sortByBeforeContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByColorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      sortBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      sortByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AnnotationDbQuerySortThenBy
    on QueryBuilder<AnnotationDb, AnnotationDb, QSortThenBy> {
  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByAfterContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      thenByAfterContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByBeforeContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      thenByBeforeContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByColorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      thenBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy>
      thenByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AnnotationDbQueryWhereDistinct
    on QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> {
  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByAfterContext(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'afterContext', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleId');
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByBeforeContext(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beforeContext',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorType');
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endOffset');
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctBySelectedText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startOffset');
    });
  }

  QueryBuilder<AnnotationDb, AnnotationDb, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AnnotationDbQueryProperty
    on QueryBuilder<AnnotationDb, AnnotationDb, QQueryProperty> {
  QueryBuilder<AnnotationDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnnotationDb, String?, QQueryOperations> afterContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'afterContext');
    });
  }

  QueryBuilder<AnnotationDb, int, QQueryOperations> articleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleId');
    });
  }

  QueryBuilder<AnnotationDb, String?, QQueryOperations>
      beforeContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beforeContext');
    });
  }

  QueryBuilder<AnnotationDb, int, QQueryOperations> colorTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorType');
    });
  }

  QueryBuilder<AnnotationDb, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AnnotationDb, int, QQueryOperations> endOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endOffset');
    });
  }

  QueryBuilder<AnnotationDb, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<AnnotationDb, String, QQueryOperations> selectedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedText');
    });
  }

  QueryBuilder<AnnotationDb, int, QQueryOperations> startOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startOffset');
    });
  }

  QueryBuilder<AnnotationDb, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
