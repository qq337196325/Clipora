// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_content_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArticleContentDbCollection on Isar {
  IsarCollection<ArticleContentDb> get articleContentDbs => this.collection();
}

const ArticleContentDbSchema = CollectionSchema(
  name: r'ArticleContentDb',
  id: 4845562575963066893,
  properties: {
    r'articleId': PropertySchema(
      id: 0,
      name: r'articleId',
      type: IsarType.long,
    ),
    r'contentHeight': PropertySchema(
      id: 1,
      name: r'contentHeight',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentElementId': PropertySchema(
      id: 3,
      name: r'currentElementId',
      type: IsarType.string,
    ),
    r'currentElementOffset': PropertySchema(
      id: 4,
      name: r'currentElementOffset',
      type: IsarType.long,
    ),
    r'currentElementText': PropertySchema(
      id: 5,
      name: r'currentElementText',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 6,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'isOriginal': PropertySchema(
      id: 7,
      name: r'isOriginal',
      type: IsarType.bool,
    ),
    r'languageCode': PropertySchema(
      id: 8,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'lastReadTime': PropertySchema(
      id: 9,
      name: r'lastReadTime',
      type: IsarType.dateTime,
    ),
    r'markdown': PropertySchema(
      id: 10,
      name: r'markdown',
      type: IsarType.string,
    ),
    r'markdownScrollX': PropertySchema(
      id: 11,
      name: r'markdownScrollX',
      type: IsarType.long,
    ),
    r'markdownScrollY': PropertySchema(
      id: 12,
      name: r'markdownScrollY',
      type: IsarType.long,
    ),
    r'serviceArticleId': PropertySchema(
      id: 13,
      name: r'serviceArticleId',
      type: IsarType.string,
    ),
    r'serviceId': PropertySchema(
      id: 14,
      name: r'serviceId',
      type: IsarType.string,
    ),
    r'textContent': PropertySchema(
      id: 15,
      name: r'textContent',
      type: IsarType.string,
    ),
    r'updateTimestamp': PropertySchema(
      id: 16,
      name: r'updateTimestamp',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 18,
      name: r'userId',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 19,
      name: r'version',
      type: IsarType.long,
    ),
    r'viewportHeight': PropertySchema(
      id: 20,
      name: r'viewportHeight',
      type: IsarType.long,
    )
  },
  estimateSize: _articleContentDbEstimateSize,
  serialize: _articleContentDbSerialize,
  deserialize: _articleContentDbDeserialize,
  deserializeProp: _articleContentDbDeserializeProp,
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
    r'serviceArticleId': IndexSchema(
      id: 2692428994754822370,
      name: r'serviceArticleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'serviceArticleId',
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
    r'languageCode': IndexSchema(
      id: -2261715960661104426,
      name: r'languageCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'languageCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'markdown': IndexSchema(
      id: 8956440606025981778,
      name: r'markdown',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'markdown',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'textContent': IndexSchema(
      id: 1990746073331052909,
      name: r'textContent',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'textContent',
          type: IndexType.hash,
          caseSensitive: true,
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
  links: {},
  embeddedSchemas: {},
  getId: _articleContentDbGetId,
  getLinks: _articleContentDbGetLinks,
  attach: _articleContentDbAttach,
  version: '3.1.8',
);

int _articleContentDbEstimateSize(
  ArticleContentDb object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currentElementId.length * 3;
  bytesCount += 3 + object.currentElementText.length * 3;
  bytesCount += 3 + object.languageCode.length * 3;
  bytesCount += 3 + object.markdown.length * 3;
  bytesCount += 3 + object.serviceArticleId.length * 3;
  bytesCount += 3 + object.serviceId.length * 3;
  bytesCount += 3 + object.textContent.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _articleContentDbSerialize(
  ArticleContentDb object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.articleId);
  writer.writeLong(offsets[1], object.contentHeight);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currentElementId);
  writer.writeLong(offsets[4], object.currentElementOffset);
  writer.writeString(offsets[5], object.currentElementText);
  writer.writeDateTime(offsets[6], object.deletedAt);
  writer.writeBool(offsets[7], object.isOriginal);
  writer.writeString(offsets[8], object.languageCode);
  writer.writeDateTime(offsets[9], object.lastReadTime);
  writer.writeString(offsets[10], object.markdown);
  writer.writeLong(offsets[11], object.markdownScrollX);
  writer.writeLong(offsets[12], object.markdownScrollY);
  writer.writeString(offsets[13], object.serviceArticleId);
  writer.writeString(offsets[14], object.serviceId);
  writer.writeString(offsets[15], object.textContent);
  writer.writeLong(offsets[16], object.updateTimestamp);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeString(offsets[18], object.userId);
  writer.writeLong(offsets[19], object.version);
  writer.writeLong(offsets[20], object.viewportHeight);
}

ArticleContentDb _articleContentDbDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArticleContentDb();
  object.articleId = reader.readLong(offsets[0]);
  object.contentHeight = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currentElementId = reader.readString(offsets[3]);
  object.currentElementOffset = reader.readLong(offsets[4]);
  object.currentElementText = reader.readString(offsets[5]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[6]);
  object.id = id;
  object.isOriginal = reader.readBool(offsets[7]);
  object.languageCode = reader.readString(offsets[8]);
  object.lastReadTime = reader.readDateTimeOrNull(offsets[9]);
  object.markdown = reader.readString(offsets[10]);
  object.markdownScrollX = reader.readLong(offsets[11]);
  object.markdownScrollY = reader.readLong(offsets[12]);
  object.serviceArticleId = reader.readString(offsets[13]);
  object.serviceId = reader.readString(offsets[14]);
  object.textContent = reader.readString(offsets[15]);
  object.updateTimestamp = reader.readLong(offsets[16]);
  object.updatedAt = reader.readDateTime(offsets[17]);
  object.userId = reader.readString(offsets[18]);
  object.version = reader.readLong(offsets[19]);
  object.viewportHeight = reader.readLong(offsets[20]);
  return object;
}

P _articleContentDbDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _articleContentDbGetId(ArticleContentDb object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _articleContentDbGetLinks(ArticleContentDb object) {
  return [];
}

void _articleContentDbAttach(
    IsarCollection<dynamic> col, Id id, ArticleContentDb object) {
  object.id = id;
}

extension ArticleContentDbQueryWhereSort
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QWhere> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere> anyArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'articleId'),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere> anyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'version'),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhere>
      anyUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updateTimestamp'),
      );
    });
  }
}

extension ArticleContentDbQueryWhere
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QWhereClause> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause> idBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      serviceIdEqualTo(String serviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceId',
        value: [serviceId],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      serviceIdNotEqualTo(String serviceId) {
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      articleIdEqualTo(int articleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'articleId',
        value: [articleId],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      serviceArticleIdEqualTo(String serviceArticleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceArticleId',
        value: [serviceArticleId],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      serviceArticleIdNotEqualTo(String serviceArticleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceArticleId',
              lower: [],
              upper: [serviceArticleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceArticleId',
              lower: [serviceArticleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceArticleId',
              lower: [serviceArticleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceArticleId',
              lower: [],
              upper: [serviceArticleId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      languageCodeEqualTo(String languageCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'languageCode',
        value: [languageCode],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      languageCodeNotEqualTo(String languageCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'languageCode',
              lower: [],
              upper: [languageCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'languageCode',
              lower: [languageCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'languageCode',
              lower: [languageCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'languageCode',
              lower: [],
              upper: [languageCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      markdownEqualTo(String markdown) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'markdown',
        value: [markdown],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      markdownNotEqualTo(String markdown) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'markdown',
              lower: [],
              upper: [markdown],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'markdown',
              lower: [markdown],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'markdown',
              lower: [markdown],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'markdown',
              lower: [],
              upper: [markdown],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      textContentEqualTo(String textContent) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'textContent',
        value: [textContent],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      textContentNotEqualTo(String textContent) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textContent',
              lower: [],
              upper: [textContent],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textContent',
              lower: [textContent],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textContent',
              lower: [textContent],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'textContent',
              lower: [],
              upper: [textContent],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      versionEqualTo(int version) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'version',
        value: [version],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      versionNotEqualTo(int version) {
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      versionGreaterThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      versionLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      versionBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      updateTimestampEqualTo(int updateTimestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updateTimestamp',
        value: [updateTimestamp],
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      updateTimestampLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterWhereClause>
      updateTimestampBetween(
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

extension ArticleContentDbQueryFilter
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QFilterCondition> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      articleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'articleId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      contentHeightEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      contentHeightGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      contentHeightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      contentHeightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentHeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentElementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentElementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentElementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentElementId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElementOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentElementOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentElementOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentElementOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentElementText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentElementText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentElementText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentElementText',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      currentElementTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentElementText',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      deletedAtLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      deletedAtBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      isOriginalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOriginal',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      lastReadTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      lastReadTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadTime',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      lastReadTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      lastReadTimeBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markdown',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'markdown',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'markdown',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdown',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'markdown',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollXEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdownScrollX',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollXGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markdownScrollX',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollXLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markdownScrollX',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollXBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markdownScrollX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollYEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markdownScrollY',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollYGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markdownScrollY',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollYLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markdownScrollY',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      markdownScrollYBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markdownScrollY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceArticleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serviceArticleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serviceArticleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceArticleId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceArticleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serviceArticleId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdEqualTo(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdStartsWith(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdEndsWith(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      serviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      textContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      updateTimestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdEqualTo(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdGreaterThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdStartsWith(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdEndsWith(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      versionGreaterThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      versionLessThan(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      versionBetween(
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

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      viewportHeightEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewportHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      viewportHeightGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewportHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      viewportHeightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewportHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterFilterCondition>
      viewportHeightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewportHeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArticleContentDbQueryObject
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QFilterCondition> {}

extension ArticleContentDbQueryLinks
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QFilterCondition> {}

extension ArticleContentDbQuerySortBy
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QSortBy> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByContentHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHeight', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByContentHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHeight', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementOffset', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementOffset', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementText', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByCurrentElementTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementText', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByIsOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdown', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdown', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdownScrollX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollX', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdownScrollXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollX', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdownScrollY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollY', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByMarkdownScrollYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollY', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByServiceArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceArticleId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByServiceArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceArticleId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByServiceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByServiceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUpdateTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByViewportHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewportHeight', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      sortByViewportHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewportHeight', Sort.desc);
    });
  }
}

extension ArticleContentDbQuerySortThenBy
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QSortThenBy> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'articleId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByContentHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHeight', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByContentHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHeight', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementOffset', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementOffset', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementText', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByCurrentElementTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentElementText', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByIsOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOriginal', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByLastReadTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTime', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdown', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdown', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdownScrollX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollX', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdownScrollXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollX', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdownScrollY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollY', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByMarkdownScrollYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markdownScrollY', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByServiceArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceArticleId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByServiceArticleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceArticleId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByServiceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByServiceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUpdateTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByViewportHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewportHeight', Sort.asc);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QAfterSortBy>
      thenByViewportHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewportHeight', Sort.desc);
    });
  }
}

extension ArticleContentDbQueryWhereDistinct
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct> {
  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByArticleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'articleId');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByContentHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHeight');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByCurrentElementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentElementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByCurrentElementOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentElementOffset');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByCurrentElementText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentElementText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByIsOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOriginal');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByLanguageCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByLastReadTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTime');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByMarkdown({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markdown', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByMarkdownScrollX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markdownScrollX');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByMarkdownScrollY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markdownScrollY');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByServiceArticleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceArticleId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByServiceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByTextContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByUpdateTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTimestamp');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<ArticleContentDb, ArticleContentDb, QDistinct>
      distinctByViewportHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewportHeight');
    });
  }
}

extension ArticleContentDbQueryProperty
    on QueryBuilder<ArticleContentDb, ArticleContentDb, QQueryProperty> {
  QueryBuilder<ArticleContentDb, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations> articleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'articleId');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      contentHeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHeight');
    });
  }

  QueryBuilder<ArticleContentDb, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations>
      currentElementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentElementId');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      currentElementOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentElementOffset');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations>
      currentElementTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentElementText');
    });
  }

  QueryBuilder<ArticleContentDb, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<ArticleContentDb, bool, QQueryOperations> isOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOriginal');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations>
      languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<ArticleContentDb, DateTime?, QQueryOperations>
      lastReadTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTime');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations> markdownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markdown');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      markdownScrollXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markdownScrollX');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      markdownScrollYProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markdownScrollY');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations>
      serviceArticleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceArticleId');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations> serviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceId');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations>
      textContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textContent');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      updateTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTimestamp');
    });
  }

  QueryBuilder<ArticleContentDb, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ArticleContentDb, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<ArticleContentDb, int, QQueryOperations>
      viewportHeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewportHeight');
    });
  }
}
