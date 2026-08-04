// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteDataCollection on Isar {
  IsarCollection<NoteData> get noteDatas => this.collection();
}

const NoteDataSchema = CollectionSchema(
  name: r'NoteData',
  id: 7796460741061007188,
  properties: {
    r'contentDelta': PropertySchema(
      id: 0,
      name: r'contentDelta',
      type: IsarType.string,
    ),
    r'contentText': PropertySchema(
      id: 1,
      name: r'contentText',
      type: IsarType.string,
    ),
    r'contentWords': PropertySchema(
      id: 2,
      name: r'contentWords',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(id: 3, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _noteDataEstimateSize,
  serialize: _noteDataSerialize,
  deserialize: _noteDataDeserialize,
  deserializeProp: _noteDataDeserializeProp,
  idName: r'id',
  indexes: {
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
        ),
      ],
    ),
    r'contentWords': IndexSchema(
      id: -9211142823111558917,
      name: r'contentWords',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contentWords',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _noteDataGetId,
  getLinks: _noteDataGetLinks,
  attach: _noteDataAttach,
  version: '3.3.2',
);

int _noteDataEstimateSize(
  NoteData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.contentDelta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contentText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.contentWords.length * 3;
  {
    for (var i = 0; i < object.contentWords.length; i++) {
      final value = object.contentWords[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _noteDataSerialize(
  NoteData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentDelta);
  writer.writeString(offsets[1], object.contentText);
  writer.writeStringList(offsets[2], object.contentWords);
  writer.writeString(offsets[3], object.title);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

NoteData _noteDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoteData(
    contentDelta: reader.readStringOrNull(offsets[0]),
    contentText: reader.readStringOrNull(offsets[1]),
    title: reader.readStringOrNull(offsets[3]),
    updatedAt: reader.readDateTime(offsets[4]),
  );
  object.id = id;
  return object;
}

P _noteDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _noteDataGetId(NoteData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noteDataGetLinks(NoteData object) {
  return [];
}

void _noteDataAttach(IsarCollection<dynamic> col, Id id, NoteData object) {
  object.id = id;
}

extension NoteDataQueryWhereSort on QueryBuilder<NoteData, NoteData, QWhere> {
  QueryBuilder<NoteData, NoteData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhere> anyContentWordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'contentWords'),
      );
    });
  }
}

extension NoteDataQueryWhere on QueryBuilder<NoteData, NoteData, QWhereClause> {
  QueryBuilder<NoteData, NoteData, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> updatedAtEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> updatedAtNotEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause> updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementEqualTo(String contentWordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'contentWords',
          value: [contentWordsElement],
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementNotEqualTo(String contentWordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentWords',
                lower: [],
                upper: [contentWordsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentWords',
                lower: [contentWordsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentWords',
                lower: [contentWordsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentWords',
                lower: [],
                upper: [contentWordsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementGreaterThan(
    String contentWordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'contentWords',
          lower: [contentWordsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementLessThan(
    String contentWordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'contentWords',
          lower: [],
          upper: [contentWordsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementBetween(
    String lowerContentWordsElement,
    String upperContentWordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'contentWords',
          lower: [lowerContentWordsElement],
          includeLower: includeLower,
          upper: [upperContentWordsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementStartsWith(String ContentWordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'contentWords',
          lower: [ContentWordsElementPrefix],
          upper: ['$ContentWordsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'contentWords', value: ['']),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterWhereClause>
  contentWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'contentWords',
                upper: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'contentWords',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'contentWords',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'contentWords',
                upper: [''],
              ),
            );
      }
    });
  }
}

extension NoteDataQueryFilter
    on QueryBuilder<NoteData, NoteData, QFilterCondition> {
  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'contentDelta'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentDeltaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'contentDelta'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentDeltaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentDelta',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentDeltaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentDeltaMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentDelta',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentDeltaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentDelta', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentDeltaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentDelta', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'contentText'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'contentText'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentText',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> contentTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentText', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentText', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentWords',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentWords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentWords',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentWords', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentWords', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'contentWords', length, true, length, true);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'contentWords', 0, true, 0, true);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'contentWords', 0, false, 999999, true);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'contentWords', 0, true, length, include);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'contentWords', length, include, 999999, true);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition>
  contentWordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contentWords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'title'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'title'),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NoteDataQueryObject
    on QueryBuilder<NoteData, NoteData, QFilterCondition> {}

extension NoteDataQueryLinks
    on QueryBuilder<NoteData, NoteData, QFilterCondition> {}

extension NoteDataQuerySortBy on QueryBuilder<NoteData, NoteData, QSortBy> {
  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByContentDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentDelta', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByContentDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentDelta', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByContentText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentText', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByContentTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentText', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteDataQuerySortThenBy
    on QueryBuilder<NoteData, NoteData, QSortThenBy> {
  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByContentDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentDelta', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByContentDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentDelta', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByContentText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentText', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByContentTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentText', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteData, NoteData, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteDataQueryWhereDistinct
    on QueryBuilder<NoteData, NoteData, QDistinct> {
  QueryBuilder<NoteData, NoteData, QDistinct> distinctByContentDelta({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentDelta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteData, NoteData, QDistinct> distinctByContentText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteData, NoteData, QDistinct> distinctByContentWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentWords');
    });
  }

  QueryBuilder<NoteData, NoteData, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteData, NoteData, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NoteDataQueryProperty
    on QueryBuilder<NoteData, NoteData, QQueryProperty> {
  QueryBuilder<NoteData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NoteData, String?, QQueryOperations> contentDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentDelta');
    });
  }

  QueryBuilder<NoteData, String?, QQueryOperations> contentTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentText');
    });
  }

  QueryBuilder<NoteData, List<String>, QQueryOperations>
  contentWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentWords');
    });
  }

  QueryBuilder<NoteData, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<NoteData, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
