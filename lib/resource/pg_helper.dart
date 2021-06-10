import 'package:postgres/postgres.dart';

class PgHelper {
  static String getUpdateSql(
      String table, Map<String, dynamic> values, String whereStr) {
    final update = StringBuffer();
    update.write('UPDATE ');
    update.write(_escapeName(table));
    update.write(' SET ');

    final size = (values != null) ? values.length : 0;

    if (size > 0) {
      var i = 0;
      values.forEach((String colName, dynamic value) {
        if (i++ > 0) {
          update.write(', ');
        }

        /// This should be just a column name
        update
            .write('${_escapeName(colName)} = ${PostgreSQLFormat.id(colName)}');
      });
    }
    update.write(' ${whereStr}');

    var sql = update.toString();
    return sql;
  }

  static String getInsertSql(String table, Map<String, dynamic> values,
      {List<String> ignores}) {
    if (ignores != null && ignores.length > 0) {
      ignores = ignores.map((e) => e.toLowerCase()).toList();
    }

    final insert = StringBuffer();
    insert.write('INSERT');
    insert.write(' INTO ');
    insert.write(_escapeName(table));
    insert.write(' (');

    final size = (values != null) ? values.length : 0;

    if (size > 0) {
      final sbValues = StringBuffer(') VALUES (');

      var i = 0;
      values.forEach((String colName, dynamic value) {
        if (ignores == null || !ignores.contains(colName.toLowerCase())) {
          if (i++ > 0) {
            insert.write(', ');
            sbValues.write(', ');
          }

          /// This should be just a column name
          insert.write(_escapeName(colName));
          sbValues.write(PostgreSQLFormat.id(colName));
        }
      });
      insert.write(sbValues);
    }
    insert.write(')');

    var sql = insert.toString();
    return sql;
  }

  static String _escapeName(String name) {
    if (name == null) {
      return name;
    }
    if (escapeNames.contains(name.toLowerCase())) {
      return _doEscape(name);
    }
    return name;
  }

  static String _doEscape(String name) => '"$name"';

  static final Set<String> escapeNames = <String>{
    'add',
    'all',
    'alter',
    'and',
    'as',
    'autoincrement',
    'between',
    'case',
    'check',
    'collate',
    'commit',
    'constraint',
    'create',
    'default',
    'deferrable',
    'delete',
    'distinct',
    'drop',
    'else',
    'escape',
    'except',
    'exists',
    'foreign',
    'from',
    'group',
    'having',
    'if',
    'in',
    'index',
    'insert',
    'intersect',
    'into',
    'is',
    'isnull',
    'join',
    'limit',
    'not',
    'notnull',
    'null',
    'on',
    'or',
    'order',
    'primary',
    'references',
    'select',
    'set',
    'table',
    'then',
    'to',
    'transaction',
    'union',
    'unique',
    'update',
    'using',
    'values',
    'when',
    'where'
  };
}
