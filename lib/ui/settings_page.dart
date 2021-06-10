import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:innout/resource/db_provider.dart';
import 'package:innout/resource/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController addrController = TextEditingController();
  final TextEditingController dbNameController = TextEditingController();
  final TextEditingController dbAccountController = TextEditingController();
  final TextEditingController dbPasswdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPage();
  }

  void initPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbAddr = prefs.getString(Keys.dbAddr);
    addrController.text = dbAddr;
    var dbName = prefs.getString(Keys.dbName);
    dbNameController.text = dbName;
    var dbAccount = prefs.getString(Keys.dbAccount);
    dbAccountController.text = dbAccount;
    var dbPasswd = prefs.getString(Keys.dbPasswd);
    dbPasswdController.text = dbPasswd;
  }

  void onSkip() {}

  void onSetting() async {
    final dbAddr = addrController.text;
    final dbName = dbNameController.text;
    final dbAccount = dbAccountController.text;
    final dbPasswd = dbPasswdController.text;
    if (dbAddr == null ||
        dbName == null ||
        dbAccount == null ||
        dbPasswd == null ||
        dbAddr == '' ||
        dbName == '' ||
        dbAccount == '' ||
        dbPasswd == '') {
      _showDialog('请将数据库资料填写完整', context);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Keys.dbAddr, dbAddr);
    await prefs.setString(Keys.dbName, dbName);
    await prefs.setString(Keys.dbAccount, dbAccount);
    await prefs.setString(Keys.dbPasswd, dbPasswd);

    DBProvider.db.clear();

    Navigator.of(context).pop();
  }

  void onWeb() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebviewScaffold(
          url: "https://memfiredb.com/db?utm_source=notehwj",
          appBar: new AppBar(
            title: new Text("MemFireDb"),
          ),
        )));
  }

  void _showDialog(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: Text(text),
          );
        });
  }

  Widget buildForm(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final primaryColorLight = Theme.of(context).primaryColorLight;
    final primaryColorDark = Theme.of(context).primaryColorDark;
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(left: 40, right: 40),
      child: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: addrController,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  decoration: InputDecoration(
                      hintText: '输入连接IP:端口号',
                      labelText: '连接地址',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.http,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () => Future.delayed(
                          Duration(milliseconds: 100),
                          () => addrController?.clear(),
                        ),
                      )),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: dbNameController,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  decoration: InputDecoration(
                      hintText: '输入数据库名',
                      labelText: '数据库名',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.data_usage,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () => Future.delayed(
                          Duration(milliseconds: 100),
                          () => dbNameController?.clear(),
                        ),
                      )),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: dbAccountController,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  decoration: InputDecoration(
                      hintText: '输入用户名',
                      labelText: '用户名',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.account_circle,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () => Future.delayed(
                          Duration(milliseconds: 100),
                          () => dbAccountController?.clear(),
                        ),
                      )),
                ),
                TextFormField(
                  controller: dbPasswdController,
                  keyboardType: TextInputType.text,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(textBaseline: TextBaseline.alphabetic),
                  decoration: InputDecoration(
                    hintText: '输入数据库密码',
                    labelText: '密码',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    prefixIcon: Icon(
                      Icons.lock,
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  width: size.width - 80,
                  child: FlatButton(
                    color: primaryColor,
                    highlightColor: primaryColorLight,
                    colorBrightness: Brightness.dark,
                    splashColor: Colors.grey,
                    child: Text(
                      '设置',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    onPressed: onSetting,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  width: size.width - 80,
                  child: FlatButton(
                    color: primaryColor.withOpacity(0.3),
                    highlightColor: primaryColorLight,
                    colorBrightness: Brightness.dark,
                    splashColor: Colors.grey,
                    child: Text(
                      '免费获取一个',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        side: BorderSide(color: primaryColorDark)),
                    onPressed: onWeb,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '设置云数据库',
          ),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  '''    在主页通过长按底部三个按钮中任意一个可以再次进入该页面。\n    温馨提示：MemFireDb (https://memfiredb.com/db?utm_source=crhwj)可以撸羊毛，有免费云数据库供个人开发者使用！''',
                  ),
              ),
              buildForm(context),
            ],
          ),
        ));
  }
}
