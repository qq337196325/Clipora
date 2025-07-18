// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArticleDbCollection on Isar {
  IsarCollection<ArticleDb> get articleDbs => this.collection();
}

const ArticleDbSchema = CollectionSchema(
  name: r'ArticleDb',
  id: 9105731770752749089,
  properties: {
    r'articleDate': PropertySchema(
      id: 0,
      name: r'articleDate',
      type: IsarType.dateTime,
    ),
    r'author': PropertySchema(
      id: 1,
      name: r'author',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 2,
      name: r'content',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 4,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'domain': PropertySchema(
      id: 5,
      name: r'domain',
      type: IsarType.string,
    ),
    r'excerpt': PropertySchema(
      id: 6,
      name: r'excerpt',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 7,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isCreateService': PropertySchema(
      id: 8,
      name: r'isCreateService',
      type: IsarType.bool,
    ),
    r'isGenerateMarkdown': PropertySchema(
      id: 9,
      name: r'isGenerateMarkdown',
      type: IsarType.bool,
    ),
    r'isGenerateMhtml': PropertySchema(
      id: 10,
      name: r'isGenerateMhtml',
      type: IsarType.bool,
    ),
    r'isImportant': PropertySchema(
      id: 11,
      name: r'isImportant',
      type: IsarType.bool,
    ),
    r'isRead': PropertySchema(
      id: 12,
      name: r'isRead',
      type: IsarType.long,
    ),
    r'lastReadTime': PropertySchema(
      id: 13,
      name: r'lastReadTime',
      type: IsarType.dateTime,
    ),
    r'markdownProcessingStartTime': PropertySchema(
      id: 14,
      name: r'markdownProcessingStartTime',
      type: IsarType.dateTime,
    ),
    r'markdownStatus': PropertySchema(
      id: 15,
      name: r'markdownStatus',
      type: IsarType.long,
    ),
    r'mhtmlPath': PropertySchema(
      id: 16,
      name: r'mhtmlPath',
      type: IsarType.string,
    ),
    r'readCount': PropertySchema(
      id: 17,
      name: r'readCount',
      type: IsarType.long,
    ),
    r'readDuration': PropertySchema(
      id: 18,
      name: r'readDuration',
      type: IsarType.long,
    ),
    r'readProgress': PropertySchema(
      id: 19,
      name: r'readProgress',
      type: IsarType.double,
    ),
    r'readingSessionId': PropertySchema(
      id: 20,
      name: r'readingSessionId',
      type: IsarType.string,
    ),
    r'readingStartTime': PropertySchema(
      id: 21,
      name: r'readingStartTime',
      type: IsarType.long,
    ),
    r'serviceId': PropertySchema(
      id: 22,
      name: r'serviceId',
      type: IsarType.string,
    ),
    r'serviceUpdatedAt': PropertySchema(
      id: 23,
      name: r'serviceUpdatedAt',
      type: IsarType.long,
    ),
    r'shareOriginalContent': PropertySchema(
      id: 24,
      name: r'shareOriginalContent',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 25,
      name: r'title',
      type: IsarType.string,
    ),
    r'updateTimestamp': PropertySchema(
      id: 26,
      name: r'updateTimestamp',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 27,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'url': PropertySchema(
      id: 28,
      name: r'url',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 29,
      name: r'userId',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 30,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 31,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _articleDbEstimateSize,
  serialize: _articleDbSerialize,
  deserialize: _articleDbDeserialize,
  deserializeProp: _articleDbDeserializeProp,
  idName: r'id',
  indexes: {
    r'serviceId': IndexSchema(
      id: -2057415921448131436,
      name: r'serviceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'serviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
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
    r'domain': IndexSchema(
      id: 1163864941618423784,
      name: r'domain',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'domain',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'author': IndexSchema(
      id: 1831044620441877526,
      name: r'author',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'author',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'articleDate': IndexSchema(
      id: 7578881227902430341,
      name: r'articleDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'articleDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isCreateService': IndexSchema(
      id: -566756087340374678,
      name: r'isCreateService',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isCreateService',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isGenerateMhtml': IndexSchema(
      id: 6244298069370056548,
      name: r'isGenerateMhtml',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isGenerateMhtml',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isGenerateMarkdown': IndexSchema(
      id: 7840021492461074430,
      name: r'isGenerateMarkdown',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isGenerateMarkdown',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isArchived': IndexSchema(
      id: 655844772568347876,
      name: r'isArchived',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isImportant': IndexSchema(
      id: -878819913280491997,
      name: r'isImportant',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isImportant',
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
    ),
    r'version': IndexSchema(
      id: -3425991338577364869,
      name: r'version',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'version',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updateTimestamp': IndexSchema(
      id: -2874489669811602764,
      name: r'updateTimestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updateTimestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'tags': LinkSchema(
      id: 517979699855733339,
      name: r'tags',
      target: r'TagDb',
      single: false,
    ),
    r'category': LinkSchema(
      id: -2321539935029527768,
      name: r'category',
      target: r'CategoryDb',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _articleDbGetId,
  getLinks: _articleDbGetLinks,
  attach: _articleDbAttach,
  version: '3.1.8',
);

int _articleDbEstimateSize(
  ArticleDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.author.length * 3;
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.domain.length * 3;
  {
    final value = object.excerpt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mhtmlPath.length * 3;
  bytesCount += 3 + object.readingSessionId.length * 3;
  bytesCount += 3 + object.serviceId.length * 3;
  bytesCount += 3 + object.shareOriginalContent.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _articleDbSerialize(
  ArticleDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.articleDate);
  writer.writeString(offsets[1], object.author);
  writer.writeString(offsets[2], object.content);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.deletedAt);
  writer.writeString(offsets[5], object.domain);
  writer.writeString(offsets[6], object.excerpt);
  writer.writeBool(offsets[7], object.isArchived);
  writer.writeBool(offsets[8], object.isCreateService);
  writer.writeBool(offsets[9], object.isGenerateMarkdown);
  writer.writeBool(offsets[10], object.isGenerateMhtml);
  writer.writeBool(offsets[11], object.isImportant);
  writer.writeLong(offsets[12], object.isRead);
  writer.writeDateTime(offsets[13], object.lastReadTime);
  writer.writeDateTime(offsets[14], object.markdownProcessingStartTime);
  writer.writeLong(offsets[15], object.markdownStatus);
  writer.writeString(offsets[16], object.mhtmlPath);
  writer.writeLong(offsets[17], object.readCount);
  writer.writeLong(offsets[18], object.readDuration);
  writer.writeDouble(offsets[19], object.readProgress);
  writer.writeString(offsets[20], object.readingSessionId);
  writer.writeLong(offsets[21], object.readingStartTime);
  writer.writeString(offsets[22], object.serviceId);
  writer.writeLong(offsets[23], object.serviceUpdatedAt);
  writer.writeString(offsets[24], object.shareOriginalContent);
  writer.writeString(offsets[25], object.title);
  writer.writeLong(offsets[26], object.updateTimestamp);
  writer.writeDateTime(offsets[27], object.updatedAt);
  writer.writeString(offsets[28], object.url);
  writer.writeString(offsets[29], object.userId);
  writer.writeString(offsets[30], object.uuid);
  writer.writeLong(offsets[31], object.version);
}

ArticleDb _articleDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArticleDb();
  object.articleDate = reader.readDateTimeOrNull(offsets[0]);
  object.author = reader.readString(offsets[1]);
  object.content = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[4]);
  object.domain = reader.readString(offsets[5]);
  object.excerpt = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.isArchived = reader.readBool(offsets[7]);
  object.isCreateService = reader.readBool(offsets[8]);
  object.isGenerateMarkdown = reader.readBool(offsets[9]);
  object.isGenerateMhtml = reader.readBool(offsets[10]);
  object.isImportant = reader.readBool(offsets[11]);
  object.isRead = reader.readLong(offsets[12]);
  object.lastReadTime = reader.readDateTimeOrNull(offsets[13]);
  object.markdownProcessingStartTime = reader.readDateTimeOrNull(offsets[14]);
  object.markdownStatus = reader.readLong(offsets[15]);
  object.mhtmlPath = reader.readString(offsets[16]);
  object.readCount = reader.readLong(offsets[17]);
  object.readDuration = reader.readLong(offsets[18]);
  object.readProgress = reader.readDouble(offsets[19]);
  object.readingSessionId = reader.readString(offsets[20]);
  object.readingStartTime = reader.readLong(offsets[21]);
  object.serviceId = reader.readString(offsets[22]);
  object.serviceUpdatedAt = reader.readLong(offsets[23]);
  object.shareOriginalContent = reader.readString(offsets[24]);
  object.title = reader.readString(offsets[25]);
  object.updateTimestamp = reader.readLong(offsets[26]);
  object.updatedAt = reader.readDateTime(offsets[27]);
  object.url = reader.readString(offsets[28]);
  object.userId = reader.readString(offsets[29]);
  object.uuid = reader.readString(offsets[30]);
  object.version = reader.readLong(offsets[31]);
  return object;
}

P _articleDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readLong(offset)) as P;
    case 27:
      return (reader.readDateTime(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _articleDbGetId(ArticleDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _articleDbGetLinks(ArticleDb object) {
  return [object.tags, object.category];
}

void _articleDbAttach(IsarCollection<dynamic> col, Id id, ArticleDb object) {
  object.id = id;
  object.tags.attach(col, col.isar.collection<TagDb>(), r'tags', id);
  object.category
      .attach(col, col.isar.collection<CategoryDb>(), r'category', id);
}

extension ArticleDbQueryWhereSort
    on QueryBuilder<ArticleDb, ArticleDb, QWhere> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyArticleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'articleDate'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyIsCreateService() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isCreateService'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyIsGenerateMhtml() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isGenerateMhtml'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyIsGenerateMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isGenerateMarkdown'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isArchived'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isImportant'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'version'),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhere> anyUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updateTimestamp'),
      );
    });
  }
}

extension ArticleDbQueryWhere
    on QueryBuilder<ArticleDb, ArticleDb, QWhereClause> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> idBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> serviceIdEqualTo(
      String serviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceId',
        value: [serviceId],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> serviceIdNotEqualTo(
      String serviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceId',
              lower: [],
              upper: [serviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceId',
              lower: [serviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceId',
              lower: [serviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceId',
              lower: [],
              upper: [serviceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> domainEqualTo(
      String domain) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'domain',
        value: [domain],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> domainNotEqualTo(
      String domain) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domain',
              lower: [],
              upper: [domain],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domain',
              lower: [domain],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domain',
              lower: [domain],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domain',
              lower: [],
              upper: [domain],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> authorEqualTo(
      String author) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'author',
        value: [author],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> authorNotEqualTo(
      String author) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'author',
              lower: [],
              upper: [author],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'author',
              lower: [author],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'author',
              lower: [author],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'author',
              lower: [],
              upper: [author],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'articleDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateEqualTo(
      DateTime? articleDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'articleDate',
        value: [articleDate],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateNotEqualTo(
      DateTime? articleDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleDate',
              lower: [],
              upper: [articleDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleDate',
              lower: [articleDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleDate',
              lower: [articleDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'articleDate',
              lower: [],
              upper: [articleDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateGreaterThan(
    DateTime? articleDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleDate',
        lower: [articleDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateLessThan(
    DateTime? articleDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleDate',
        lower: [],
        upper: [articleDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> articleDateBetween(
    DateTime? lowerArticleDate,
    DateTime? upperArticleDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'articleDate',
        lower: [lowerArticleDate],
        includeLower: includeLower,
        upper: [upperArticleDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isCreateServiceEqualTo(
      bool isCreateService) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isCreateService',
        value: [isCreateService],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      isCreateServiceNotEqualTo(bool isCreateService) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCreateService',
              lower: [],
              upper: [isCreateService],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCreateService',
              lower: [isCreateService],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCreateService',
              lower: [isCreateService],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCreateService',
              lower: [],
              upper: [isCreateService],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isGenerateMhtmlEqualTo(
      bool isGenerateMhtml) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isGenerateMhtml',
        value: [isGenerateMhtml],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      isGenerateMhtmlNotEqualTo(bool isGenerateMhtml) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMhtml',
              lower: [],
              upper: [isGenerateMhtml],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMhtml',
              lower: [isGenerateMhtml],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMhtml',
              lower: [isGenerateMhtml],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMhtml',
              lower: [],
              upper: [isGenerateMhtml],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      isGenerateMarkdownEqualTo(bool isGenerateMarkdown) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isGenerateMarkdown',
        value: [isGenerateMarkdown],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      isGenerateMarkdownNotEqualTo(bool isGenerateMarkdown) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMarkdown',
              lower: [],
              upper: [isGenerateMarkdown],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMarkdown',
              lower: [isGenerateMarkdown],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMarkdown',
              lower: [isGenerateMarkdown],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGenerateMarkdown',
              lower: [],
              upper: [isGenerateMarkdown],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isArchivedEqualTo(
      bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isArchivedNotEqualTo(
      bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isImportantEqualTo(
      bool isImportant) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isImportant',
        value: [isImportant],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> isImportantNotEqualTo(
      bool isImportant) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isImportant',
              lower: [],
              upper: [isImportant],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isImportant',
              lower: [isImportant],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isImportant',
              lower: [isImportant],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isImportant',
              lower: [],
              upper: [isImportant],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> createdAtNotEqualTo(
      DateTime createdAt) {
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> createdAtGreaterThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> createdAtLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> createdAtBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updatedAtEqualTo(
      DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updatedAtNotEqualTo(
      DateTime updatedAt) {
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updatedAtGreaterThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updatedAtLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updatedAtBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> versionEqualTo(
      int version) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'version',
        value: [version],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> versionNotEqualTo(
      int version) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'version',
              lower: [],
              upper: [version],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'version',
              lower: [version],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'version',
              lower: [version],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'version',
              lower: [],
              upper: [version],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> versionGreaterThan(
    int version, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'version',
        lower: [version],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> versionLessThan(
    int version, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'version',
        lower: [],
        upper: [version],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> versionBetween(
    int lowerVersion,
    int upperVersion, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'version',
        lower: [lowerVersion],
        includeLower: includeLower,
        upper: [upperVersion],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updateTimestampEqualTo(
      int updateTimestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updateTimestamp',
        value: [updateTimestamp],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      updateTimestampNotEqualTo(int updateTimestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTimestamp',
              lower: [],
              upper: [updateTimestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTimestamp',
              lower: [updateTimestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTimestamp',
              lower: [updateTimestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTimestamp',
              lower: [],
              upper: [updateTimestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause>
      updateTimestampGreaterThan(
    int updateTimestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTimestamp',
        lower: [updateTimestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updateTimestampLessThan(
    int updateTimestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTimestamp',
        lower: [],
        upper: [updateTimestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterWhereClause> updateTimestampBetween(
    int lowerUpdateTimestamp,
    int upperUpdateTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTimestamp',
        lower: [lowerUpdateTimestamp],
        includeLower: includeLower,
        upper: [upperUpdateTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArticleDbQueryFilter
    on QueryBuilder<ArticleDb, ArticleDb, QFilterCondition> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      articleDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'articleDate',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      articleDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'articleDate',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> articleDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      articleDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'articleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> articleDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'articleDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> articleDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'articleDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> deletedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      deletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'domain',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'domain',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'domain',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domain',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> domainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domain',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'excerpt',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'excerpt',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'excerpt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'excerpt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'excerpt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> excerptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excerpt',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      excerptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'excerpt',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isArchivedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      isCreateServiceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCreateService',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      isGenerateMarkdownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGenerateMarkdown',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      isGenerateMhtmlEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGenerateMhtml',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isImportantEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImportant',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isReadEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> isReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      lastReadTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      lastReadTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> lastReadTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      lastReadTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      lastReadTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> lastReadTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'markdownProcessingStartTime',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'markdownProcessingStartTime',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdownProcessingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markdownProcessingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markdownProcessingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownProcessingStartTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markdownProcessingStartTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdownStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownStatusGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markdownStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownStatusLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markdownStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      markdownStatusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markdownStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      mhtmlPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mhtmlPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mhtmlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mhtmlPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> mhtmlPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mhtmlPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      mhtmlPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mhtmlPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readDurationEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> readProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readingSessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'readingSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'readingSessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingSessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingSessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'readingSessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingStartTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingStartTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingStartTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readingStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      readingStartTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readingStartTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> serviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceUpdatedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceUpdatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceUpdatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      serviceUpdatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shareOriginalContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shareOriginalContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shareOriginalContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shareOriginalContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      shareOriginalContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shareOriginalContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      updateTimestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      updateTimestampGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      updateTimestampLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      updateTimestampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdGreaterThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdStartsWith(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> versionEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> versionGreaterThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> versionLessThan(
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

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> versionBetween(
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

extension ArticleDbQueryObject
    on QueryBuilder<ArticleDb, ArticleDb, QFilterCondition> {}

extension ArticleDbQueryLinks
    on QueryBuilder<ArticleDb, ArticleDb, QFilterCondition> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tags(
      FilterQuery<TagDb> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> category(
      FilterQuery<CategoryDb> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'category');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterFilterCondition> categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'category', 0, true, 0, true);
    });
  }
}

extension ArticleDbQuerySortBy on QueryBuilder<ArticleDb, ArticleDb, QSortBy> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByArticleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleDate', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByArticleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleDate', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByExcerpt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excerpt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByExcerptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excerpt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsCreateService() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreateService', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsCreateServiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreateService', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsGenerateMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMarkdown', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByIsGenerateMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMarkdown', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsGenerateMhtml() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMhtml', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsGenerateMhtmlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMhtml', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByMarkdownProcessingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownProcessingStartTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByMarkdownProcessingStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownProcessingStartTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByMarkdownStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownStatus', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByMarkdownStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownStatus', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByMhtmlPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mhtmlPath', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByMhtmlPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mhtmlPath', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readCount', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readCount', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readDuration', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readDuration', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadingSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingSessionId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByReadingSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingSessionId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByReadingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStartTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByReadingStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStartTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByServiceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByServiceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByServiceUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByServiceUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByShareOriginalContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shareOriginalContent', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      sortByShareOriginalContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shareOriginalContent', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUpdateTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ArticleDbQuerySortThenBy
    on QueryBuilder<ArticleDb, ArticleDb, QSortThenBy> {
  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByArticleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleDate', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByArticleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleDate', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByDomain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByDomainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domain', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByExcerpt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excerpt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByExcerptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excerpt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsCreateService() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreateService', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsCreateServiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreateService', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsGenerateMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMarkdown', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByIsGenerateMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMarkdown', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsGenerateMhtml() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMhtml', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsGenerateMhtmlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerateMhtml', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByMarkdownProcessingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownProcessingStartTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByMarkdownProcessingStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownProcessingStartTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByMarkdownStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownStatus', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByMarkdownStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownStatus', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByMhtmlPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mhtmlPath', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByMhtmlPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mhtmlPath', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readCount', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readCount', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readDuration', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readDuration', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readProgress', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadingSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingSessionId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByReadingSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingSessionId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByReadingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStartTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByReadingStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStartTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByServiceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByServiceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByServiceUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByServiceUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByShareOriginalContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shareOriginalContent', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy>
      thenByShareOriginalContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shareOriginalContent', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUpdateTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ArticleDbQueryWhereDistinct
    on QueryBuilder<ArticleDb, ArticleDb, QDistinct> {
  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByArticleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleDate');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByDomain(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByExcerpt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'excerpt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsCreateService() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCreateService');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsGenerateMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGenerateMarkdown');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsGenerateMhtml() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGenerateMhtml');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImportant');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRead');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTime');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct>
      distinctByMarkdownProcessingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markdownProcessingStartTime');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByMarkdownStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markdownStatus');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByMhtmlPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mhtmlPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByReadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readCount');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByReadDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readDuration');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByReadProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readProgress');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByReadingSessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingSessionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByReadingStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingStartTime');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByServiceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByServiceUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceUpdatedAt');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByShareOriginalContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shareOriginalContent',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTimestamp');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleDb, ArticleDb, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension ArticleDbQueryProperty
    on QueryBuilder<ArticleDb, ArticleDb, QQueryProperty> {
  QueryBuilder<ArticleDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArticleDb, DateTime?, QQueryOperations> articleDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleDate');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<ArticleDb, String?, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<ArticleDb, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ArticleDb, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> domainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domain');
    });
  }

  QueryBuilder<ArticleDb, String?, QQueryOperations> excerptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'excerpt');
    });
  }

  QueryBuilder<ArticleDb, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<ArticleDb, bool, QQueryOperations> isCreateServiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCreateService');
    });
  }

  QueryBuilder<ArticleDb, bool, QQueryOperations> isGenerateMarkdownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGenerateMarkdown');
    });
  }

  QueryBuilder<ArticleDb, bool, QQueryOperations> isGenerateMhtmlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGenerateMhtml');
    });
  }

  QueryBuilder<ArticleDb, bool, QQueryOperations> isImportantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImportant');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRead');
    });
  }

  QueryBuilder<ArticleDb, DateTime?, QQueryOperations> lastReadTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTime');
    });
  }

  QueryBuilder<ArticleDb, DateTime?, QQueryOperations>
      markdownProcessingStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markdownProcessingStartTime');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> markdownStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markdownStatus');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> mhtmlPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mhtmlPath');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> readCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readCount');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> readDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readDuration');
    });
  }

  QueryBuilder<ArticleDb, double, QQueryOperations> readProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readProgress');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> readingSessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingSessionId');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> readingStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingStartTime');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> serviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceId');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> serviceUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceUpdatedAt');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations>
      shareOriginalContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shareOriginalContent');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> updateTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTimestamp');
    });
  }

  QueryBuilder<ArticleDb, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<ArticleDb, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<ArticleDb, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
