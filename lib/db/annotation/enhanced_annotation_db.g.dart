// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_annotation_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEnhancedAnnotationDbCollection on Isar {
  IsarCollection<EnhancedAnnotationDb> get enhancedAnnotationDbs =>
      this.collection();
}

const EnhancedAnnotationDbSchema = CollectionSchema(
  name: r'EnhancedAnnotationDb',
  id: -1194005749494519273,
  properties: {
    r'afterContext': PropertySchema(
      id: 0,
      name: r'afterContext',
      type: IsarType.string,
    ),
    r'annotationType': PropertySchema(
      id: 1,
      name: r'annotationType',
      type: IsarType.byte,
      enumMap: _EnhancedAnnotationDbannotationTypeEnumValueMap,
    ),
    r'articleId': PropertySchema(
      id: 2,
      name: r'articleId',
      type: IsarType.long,
    ),
    r'backupData': PropertySchema(
      id: 3,
      name: r'backupData',
      type: IsarType.string,
    ),
    r'beforeContext': PropertySchema(
      id: 4,
      name: r'beforeContext',
      type: IsarType.string,
    ),
    r'boundingHeight': PropertySchema(
      id: 5,
      name: r'boundingHeight',
      type: IsarType.double,
    ),
    r'boundingWidth': PropertySchema(
      id: 6,
      name: r'boundingWidth',
      type: IsarType.double,
    ),
    r'boundingX': PropertySchema(
      id: 7,
      name: r'boundingX',
      type: IsarType.double,
    ),
    r'boundingY': PropertySchema(
      id: 8,
      name: r'boundingY',
      type: IsarType.double,
    ),
    r'colorType': PropertySchema(
      id: 9,
      name: r'colorType',
      type: IsarType.byte,
      enumMap: _EnhancedAnnotationDbcolorTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 10,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'crossParagraph': PropertySchema(
      id: 11,
      name: r'crossParagraph',
      type: IsarType.bool,
    ),
    r'endOffset': PropertySchema(
      id: 12,
      name: r'endOffset',
      type: IsarType.long,
    ),
    r'endXPath': PropertySchema(
      id: 13,
      name: r'endXPath',
      type: IsarType.string,
    ),
    r'highlightId': PropertySchema(
      id: 14,
      name: r'highlightId',
      type: IsarType.string,
    ),
    r'noteContent': PropertySchema(
      id: 15,
      name: r'noteContent',
      type: IsarType.string,
    ),
    r'rangeFingerprint': PropertySchema(
      id: 16,
      name: r'rangeFingerprint',
      type: IsarType.string,
    ),
    r'selectedText': PropertySchema(
      id: 17,
      name: r'selectedText',
      type: IsarType.string,
    ),
    r'startOffset': PropertySchema(
      id: 18,
      name: r'startOffset',
      type: IsarType.long,
    ),
    r'startXPath': PropertySchema(
      id: 19,
      name: r'startXPath',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 20,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 21,
      name: r'userId',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 22,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _enhancedAnnotationDbEstimateSize,
  serialize: _enhancedAnnotationDbSerialize,
  deserialize: _enhancedAnnotationDbDeserialize,
  deserializeProp: _enhancedAnnotationDbDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
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
    r'highlightId': IndexSchema(
      id: -6411662984405488768,
      name: r'highlightId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'highlightId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'annotationType': IndexSchema(
      id: 4774460578614465591,
      name: r'annotationType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'annotationType',
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
  getId: _enhancedAnnotationDbGetId,
  getLinks: _enhancedAnnotationDbGetLinks,
  attach: _enhancedAnnotationDbAttach,
  version: '3.1.8',
);

int _enhancedAnnotationDbEstimateSize(
  EnhancedAnnotationDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.afterContext.length * 3;
  {
    final value = object.backupData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.beforeContext.length * 3;
  bytesCount += 3 + object.endXPath.length * 3;
  bytesCount += 3 + object.highlightId.length * 3;
  bytesCount += 3 + object.noteContent.length * 3;
  bytesCount += 3 + object.rangeFingerprint.length * 3;
  bytesCount += 3 + object.selectedText.length * 3;
  bytesCount += 3 + object.startXPath.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _enhancedAnnotationDbSerialize(
  EnhancedAnnotationDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.afterContext);
  writer.writeByte(offsets[1], object.annotationType.index);
  writer.writeLong(offsets[2], object.articleId);
  writer.writeString(offsets[3], object.backupData);
  writer.writeString(offsets[4], object.beforeContext);
  writer.writeDouble(offsets[5], object.boundingHeight);
  writer.writeDouble(offsets[6], object.boundingWidth);
  writer.writeDouble(offsets[7], object.boundingX);
  writer.writeDouble(offsets[8], object.boundingY);
  writer.writeByte(offsets[9], object.colorType.index);
  writer.writeDateTime(offsets[10], object.createdAt);
  writer.writeBool(offsets[11], object.crossParagraph);
  writer.writeLong(offsets[12], object.endOffset);
  writer.writeString(offsets[13], object.endXPath);
  writer.writeString(offsets[14], object.highlightId);
  writer.writeString(offsets[15], object.noteContent);
  writer.writeString(offsets[16], object.rangeFingerprint);
  writer.writeString(offsets[17], object.selectedText);
  writer.writeLong(offsets[18], object.startOffset);
  writer.writeString(offsets[19], object.startXPath);
  writer.writeDateTime(offsets[20], object.updatedAt);
  writer.writeString(offsets[21], object.userId);
  writer.writeLong(offsets[22], object.version);
}

EnhancedAnnotationDb _enhancedAnnotationDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EnhancedAnnotationDb();
  object.afterContext = reader.readString(offsets[0]);
  object.annotationType = _EnhancedAnnotationDbannotationTypeValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      AnnotationType.highlight;
  object.articleId = reader.readLong(offsets[2]);
  object.backupData = reader.readStringOrNull(offsets[3]);
  object.beforeContext = reader.readString(offsets[4]);
  object.boundingHeight = reader.readDouble(offsets[5]);
  object.boundingWidth = reader.readDouble(offsets[6]);
  object.boundingX = reader.readDouble(offsets[7]);
  object.boundingY = reader.readDouble(offsets[8]);
  object.colorType = _EnhancedAnnotationDbcolorTypeValueEnumMap[
          reader.readByteOrNull(offsets[9])] ??
      AnnotationColor.yellow;
  object.createdAt = reader.readDateTime(offsets[10]);
  object.crossParagraph = reader.readBool(offsets[11]);
  object.endOffset = reader.readLong(offsets[12]);
  object.endXPath = reader.readString(offsets[13]);
  object.highlightId = reader.readString(offsets[14]);
  object.id = id;
  object.noteContent = reader.readString(offsets[15]);
  object.rangeFingerprint = reader.readString(offsets[16]);
  object.selectedText = reader.readString(offsets[17]);
  object.startOffset = reader.readLong(offsets[18]);
  object.startXPath = reader.readString(offsets[19]);
  object.updatedAt = reader.readDateTime(offsets[20]);
  object.userId = reader.readString(offsets[21]);
  object.version = reader.readLong(offsets[22]);
  return object;
}

P _enhancedAnnotationDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_EnhancedAnnotationDbannotationTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AnnotationType.highlight) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (_EnhancedAnnotationDbcolorTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AnnotationColor.yellow) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EnhancedAnnotationDbannotationTypeEnumValueMap = {
  'highlight': 0,
  'note': 1,
};
const _EnhancedAnnotationDbannotationTypeValueEnumMap = {
  0: AnnotationType.highlight,
  1: AnnotationType.note,
};
const _EnhancedAnnotationDbcolorTypeEnumValueMap = {
  'yellow': 0,
  'green': 1,
  'blue': 2,
  'pink': 3,
  'red': 4,
  'purple': 5,
};
const _EnhancedAnnotationDbcolorTypeValueEnumMap = {
  0: AnnotationColor.yellow,
  1: AnnotationColor.green,
  2: AnnotationColor.blue,
  3: AnnotationColor.pink,
  4: AnnotationColor.red,
  5: AnnotationColor.purple,
};

Id _enhancedAnnotationDbGetId(EnhancedAnnotationDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _enhancedAnnotationDbGetLinks(
    EnhancedAnnotationDb object) {
  return [];
}

void _enhancedAnnotationDbAttach(
    IsarCollection<dynamic> col, Id id, EnhancedAnnotationDb object) {
  object.id = id;
}

extension EnhancedAnnotationDbByIndex on IsarCollection<EnhancedAnnotationDb> {
  Future<EnhancedAnnotationDb?> getByHighlightId(String highlightId) {
    return getByIndex(r'highlightId', [highlightId]);
  }

  EnhancedAnnotationDb? getByHighlightIdSync(String highlightId) {
    return getByIndexSync(r'highlightId', [highlightId]);
  }

  Future<bool> deleteByHighlightId(String highlightId) {
    return deleteByIndex(r'highlightId', [highlightId]);
  }

  bool deleteByHighlightIdSync(String highlightId) {
    return deleteByIndexSync(r'highlightId', [highlightId]);
  }

  Future<List<EnhancedAnnotationDb?>> getAllByHighlightId(
      List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'highlightId', values);
  }

  List<EnhancedAnnotationDb?> getAllByHighlightIdSync(
      List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'highlightId', values);
  }

  Future<int> deleteAllByHighlightId(List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'highlightId', values);
  }

  int deleteAllByHighlightIdSync(List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'highlightId', values);
  }

  Future<Id> putByHighlightId(EnhancedAnnotationDb object) {
    return putByIndex(r'highlightId', object);
  }

  Id putByHighlightIdSync(EnhancedAnnotationDb object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'highlightId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHighlightId(List<EnhancedAnnotationDb> objects) {
    return putAllByIndex(r'highlightId', objects);
  }

  List<Id> putAllByHighlightIdSync(List<EnhancedAnnotationDb> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'highlightId', objects, saveLinks: saveLinks);
  }
}

extension EnhancedAnnotationDbQueryWhereSort
    on QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QWhere> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'articleId'),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyAnnotationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'annotationType'),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'colorType'),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhere>
      anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension EnhancedAnnotationDbQueryWhere
    on QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QWhereClause> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      articleIdEqualTo(int articleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'articleId',
        value: [articleId],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      articleIdLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      articleIdBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      highlightIdEqualTo(String highlightId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'highlightId',
        value: [highlightId],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      highlightIdNotEqualTo(String highlightId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [],
              upper: [highlightId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [highlightId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [highlightId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [],
              upper: [highlightId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      annotationTypeEqualTo(AnnotationType annotationType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'annotationType',
        value: [annotationType],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      annotationTypeNotEqualTo(AnnotationType annotationType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'annotationType',
              lower: [],
              upper: [annotationType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'annotationType',
              lower: [annotationType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'annotationType',
              lower: [annotationType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'annotationType',
              lower: [],
              upper: [annotationType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      annotationTypeGreaterThan(
    AnnotationType annotationType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'annotationType',
        lower: [annotationType],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      annotationTypeLessThan(
    AnnotationType annotationType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'annotationType',
        lower: [],
        upper: [annotationType],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      annotationTypeBetween(
    AnnotationType lowerAnnotationType,
    AnnotationType upperAnnotationType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'annotationType',
        lower: [lowerAnnotationType],
        includeLower: includeLower,
        upper: [upperAnnotationType],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      colorTypeEqualTo(AnnotationColor colorType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'colorType',
        value: [colorType],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      colorTypeNotEqualTo(AnnotationColor colorType) {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      colorTypeGreaterThan(
    AnnotationColor colorType, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      colorTypeLessThan(
    AnnotationColor colorType, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      colorTypeBetween(
    AnnotationColor lowerColorType,
    AnnotationColor upperColorType, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      createdAtLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      createdAtBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      updatedAtLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterWhereClause>
      updatedAtBetween(
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

extension EnhancedAnnotationDbQueryFilter on QueryBuilder<EnhancedAnnotationDb,
    EnhancedAnnotationDb, QFilterCondition> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextEqualTo(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextGreaterThan(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextLessThan(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextBetween(
    String lower,
    String upper, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextStartsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextEndsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      afterContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'afterContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      afterContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'afterContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterContext',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> afterContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'afterContext',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> annotationTypeEqualTo(AnnotationType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'annotationType',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> annotationTypeGreaterThan(
    AnnotationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'annotationType',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> annotationTypeLessThan(
    AnnotationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'annotationType',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> annotationTypeBetween(
    AnnotationType lower,
    AnnotationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'annotationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> articleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleId',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> articleIdGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> articleIdLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> articleIdBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'backupData',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'backupData',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backupData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      backupDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backupData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      backupDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backupData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupData',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> backupDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backupData',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextEqualTo(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextGreaterThan(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextLessThan(
    String value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextBetween(
    String lower,
    String upper, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextStartsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextEndsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      beforeContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'beforeContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      beforeContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'beforeContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeContext',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> beforeContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'beforeContext',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingHeightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boundingHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingHeightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'boundingHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingHeightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'boundingHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingHeightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'boundingHeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingWidthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boundingWidth',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingWidthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'boundingWidth',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingWidthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'boundingWidth',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingWidthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'boundingWidth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingXEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boundingX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingXGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'boundingX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingXLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'boundingX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingXBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'boundingX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingYEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boundingY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingYGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'boundingY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingYLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'boundingY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> boundingYBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'boundingY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> colorTypeEqualTo(AnnotationColor value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorType',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> colorTypeGreaterThan(
    AnnotationColor value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> colorTypeLessThan(
    AnnotationColor value, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> colorTypeBetween(
    AnnotationColor lower,
    AnnotationColor upper, {
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> crossParagraphEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossParagraph',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endOffsetGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endOffsetLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endOffsetBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endXPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      endXPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      endXPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endXPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endXPath',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> endXPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endXPath',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'highlightId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      highlightIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      highlightIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'highlightId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highlightId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> highlightIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'highlightId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'noteContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      noteContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'noteContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      noteContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'noteContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noteContent',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> noteContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'noteContent',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rangeFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      rangeFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rangeFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      rangeFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rangeFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rangeFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> rangeFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rangeFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextEqualTo(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextStartsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextEndsWith(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      selectedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      selectedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> selectedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startOffsetGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startOffsetLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startOffsetBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startXPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      startXPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startXPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      startXPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startXPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startXPath',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> startXPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startXPath',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb,
      QAfterFilterCondition> versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EnhancedAnnotationDbQueryObject on QueryBuilder<EnhancedAnnotationDb,
    EnhancedAnnotationDb, QFilterCondition> {}

extension EnhancedAnnotationDbQueryLinks on QueryBuilder<EnhancedAnnotationDb,
    EnhancedAnnotationDb, QFilterCondition> {}

extension EnhancedAnnotationDbQuerySortBy
    on QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QSortBy> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByAfterContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByAfterContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByAnnotationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annotationType', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByAnnotationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annotationType', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBackupData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupData', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBackupDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupData', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBeforeContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBeforeContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingHeight', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingHeight', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingWidth', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingWidth', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingX', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingX', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingY', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByBoundingYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingY', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByColorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByCrossParagraph() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossParagraph', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByCrossParagraphDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossParagraph', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByEndXPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endXPath', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByEndXPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endXPath', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByHighlightId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByHighlightIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByNoteContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteContent', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByNoteContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteContent', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByRangeFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rangeFingerprint', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByRangeFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rangeFingerprint', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByStartXPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startXPath', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByStartXPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startXPath', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension EnhancedAnnotationDbQuerySortThenBy
    on QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QSortThenBy> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByAfterContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByAfterContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterContext', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByAnnotationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annotationType', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByAnnotationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annotationType', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBackupData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupData', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBackupDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupData', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBeforeContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBeforeContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeContext', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingHeight', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingHeight', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingWidth', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingWidth', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingX', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingX', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingY', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByBoundingYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingY', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByColorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorType', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByCrossParagraph() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossParagraph', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByCrossParagraphDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossParagraph', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByEndXPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endXPath', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByEndXPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endXPath', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByHighlightId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByHighlightIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByNoteContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteContent', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByNoteContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteContent', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByRangeFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rangeFingerprint', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByRangeFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rangeFingerprint', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByStartXPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startXPath', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByStartXPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startXPath', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension EnhancedAnnotationDbQueryWhereDistinct
    on QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct> {
  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByAfterContext({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'afterContext', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByAnnotationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annotationType');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleId');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBackupData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBeforeContext({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beforeContext',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBoundingHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingHeight');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBoundingWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingWidth');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBoundingX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingX');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByBoundingY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingY');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByColorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorType');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByCrossParagraph() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossParagraph');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endOffset');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByEndXPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endXPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByHighlightId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highlightId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByNoteContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noteContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByRangeFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rangeFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctBySelectedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startOffset');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByStartXPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startXPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnhancedAnnotationDb, EnhancedAnnotationDb, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension EnhancedAnnotationDbQueryProperty on QueryBuilder<
    EnhancedAnnotationDb, EnhancedAnnotationDb, QQueryProperty> {
  QueryBuilder<EnhancedAnnotationDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      afterContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'afterContext');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, AnnotationType, QQueryOperations>
      annotationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annotationType');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, int, QQueryOperations>
      articleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleId');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String?, QQueryOperations>
      backupDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupData');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      beforeContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beforeContext');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, double, QQueryOperations>
      boundingHeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingHeight');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, double, QQueryOperations>
      boundingWidthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingWidth');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, double, QQueryOperations>
      boundingXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingX');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, double, QQueryOperations>
      boundingYProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingY');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, AnnotationColor, QQueryOperations>
      colorTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorType');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, bool, QQueryOperations>
      crossParagraphProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossParagraph');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, int, QQueryOperations>
      endOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endOffset');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      endXPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endXPath');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      highlightIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highlightId');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      noteContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noteContent');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      rangeFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rangeFingerprint');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      selectedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedText');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, int, QQueryOperations>
      startOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startOffset');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      startXPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startXPath');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<EnhancedAnnotationDb, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
