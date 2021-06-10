import 'dart:async';

import 'package:innout/resource/local_db_provider.dart';
import 'package:innout/resource/pg_helper.dart';
import 'package:oktoast/oktoast.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:innout/model/transaction.dart';

import 'keys.dart';

final String tableName = 'transactions';
final String colId = 'id';
final String colUuid = 'uuid';
final String colTimestamp = 'timestamp';
final String colDescription = 'description';
final String colType = 'transactiontype';
final String colAmount = 'amount';

class DBProvider {
  static final DBProvider db = DBProvider._();

  DBProvider._();

  PostgreSQLConnection _database;
  bool _local;

  clear() {
    _local = null;
    _database = null;
  }

  Future<PostgreSQLConnection> get database async {
    if (_local != null && _local) return null;
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<PostgreSQLConnection> initDB({bool refresh = false}) async {
    _local = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbAddr = prefs.getString(Keys.dbAddr);
    String dbIp, dbName, dbAccount, dbPasswd;
    int dbPort;
    if (dbAddr != null && dbAddr != '') {
      var a = dbAddr.split(':');
      if (a == null || a.length < 2) {
        return null;
      }
      dbIp = a[0];
      dbPort = int.parse(a[1]);
      dbName = prefs.getString(Keys.dbName);
      dbAccount = prefs.getString(Keys.dbAccount);
      dbPasswd = prefs.getString(Keys.dbPasswd);
      _local = false;
    }

    if (_local) {
      return null;
    }

    PostgreSQLConnection connection;

    try {
      connection = PostgreSQLConnection(dbIp, dbPort, dbName,
          username: dbAccount, password: dbPasswd);
      await connection.open();
    } catch (e) {
      connection = null;
      showToast(e.toString(), duration: Duration(seconds: 5));
      print(e);
    }

    if (connection == null) return null;

    try {
      await connection.execute("""
        CREATE TABLE $tableName (
                  $colId SERIAL PRIMARY KEY,
                  $colUuid TEXT,
                  $colTimestamp BIGINT,
                  $colDescription TEXT,
                  $colType INTEGER,
                  $colAmount REAL);
        """);
    } catch (e) {
      print(e);
    }

    return connection;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    if (db == null)
      return await LocalDBProvider.db.updateTransaction(transaction);

    var sql = PgHelper.getUpdateSql(
        tableName,
        transaction.toMap(),
        'WHERE $colId = '
        '${transaction.id}');
    var res = await db.execute(sql, substitutionValues: transaction.toMap());
    return res;
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    final db = await database;
    if (db == null)
      return await LocalDBProvider.db.deleteTransaction(transaction);

    int res = await db
        .execute('DELETE FROM $tableName WHERE $colId = ${transaction.id}');
    return res;
  }

  Future<int> addTransaction(Transaction transaction) async {
    final db = await database;
    if (db == null) return await LocalDBProvider.db.addTransaction(transaction);

    var sql = PgHelper.getInsertSql(tableName, transaction.toMap(), ignores: [colId]);
    var res = await db.execute(sql, substitutionValues: transaction.toMap());
    return res;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    if (db == null) return await LocalDBProvider.db.getAllTransactions();

    var list = await db.mappedResultsQuery('SELECT * FROM $tableName;');
    var mapList = list.map((e) => e[tableName]).toList();
    return mapList.map((r) => Transaction.fromPgMap(r)).toList();
  }

  Future<int> getNextId() async {
    final db = await database;
    if (db == null) return await LocalDBProvider.db.getNextId();

    var table = await db.mappedResultsQuery('SELECT MAX(Id)+1 as Id FROM $tableName');
    int id = table.first[tableName]['id'];

    return id;
  }
}
