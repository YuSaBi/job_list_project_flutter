import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_list_project/views/mainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../decorations/textFieldClass.dart';
import '../models/userLoginResponse.dart';
import '../models/httpConfig.dart';

/// MAIN CLASS ///
class loginScreen extends StatefulWidget {
  loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

/// MAIN STATE ///
class _loginScreenState extends State<loginScreen> {
  //bool _isLogged;
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  //String userName = "";
  //String userPassword = "";
  Future<LoginResponseModel>? _futureUserLogin;
  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  //_loginScreenState ();

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  void checkLogin() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("isLogged") == null ||
        sharedPreferences.getBool("isLogged") == false) {
          // otomatik giriş yapılmıyor.
    } else if (sharedPreferences.getString("userID").toString().isNotEmpty &&
        sharedPreferences.getString("userID").toString() != "0") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tekrar hoşgeldin ${sharedPreferences.getString("userName").toString()} :)')),
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false);
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hatalı giriş, lütfen yeniden giriş yapın'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: Text("Giriş Ekranı"), // uygulama üst barı
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false, // klavye açılınca oynatma
      body: Form(child: buildBody()),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Form(
        key: _formKey,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildUsernameField(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  buildPasswordField(),
                  const SizedBox(
                    height: 30.0,
                  ),
                  buildLoginButton(),
                ],
              ),
      ),
    );
  }

  buildUsernameField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: _usernameController,
      decoration: textDecoration().usernameFieldDecoration(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Kullanıcı adı boş bırakılamaz.";
        }
      },
    );
  }

  buildPasswordField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      controller: _passwordController,
      decoration: textDecoration().passwordFieldDecoration(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Şifre boş bırakılamaz.";
        }
      },
    );
  }

  buildLoginButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      margin: EdgeInsets.only(top: 30.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.teal,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0))),
        child: const Text(
          "Giriş yap",
          //style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });
            _formKey.currentState!.save();
            userLogin(_usernameController.text, _passwordController.text);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lütfen boş alanları doldurunuz')),
            );
          }
        },
      ),
    );
  }

  // future post method
  //Future<LoginResponseModel> userLogin(String name, String password) async {
  userLogin(String name, String password) async {
    var jsonData;
    postMethodConfig config = postMethodConfig();
    //sharedPreferences = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(
          "${config.baseUrl}UserLogin_Manager"), // 10.0.2.2   localhost  Mert : 192.168.177.172  Test_UserLogin
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': name,
        'userpassword': password,
      }),
    );

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);

      if (jsonData['responseCode'] == null) {
        print("HATA: responseCode boş geldi :( beklenmeyen hata :() ");
        //sharedPreferences.setString("responseMsg", "HATA:  responseCode boş geldi :( ");
      } else if (jsonData['responseCode'] == 1) {
        setState(() {
          _isLoading = false;
          //sharedPreferences.setString("responseMsg", "Giriş başarılı");
          sharedPreferences.setString("userID", jsonData['userID'].toString());
          sharedPreferences.setString("userName", name.toString());
          sharedPreferences.setBool('isLogged', true);
          sharedPreferences.commit();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('giriş işlemi başarılı')),
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false);
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hatalı Kullanıcı adı veya şifre girdiniz.')),
        );
      }
      //return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      // responseCode 200 değilken
      print("net hatası olabilir, bağlantı hatası");
      setState(() {
        _isLoading = false;
      });
    }
  }

  //FutureBuilder<LoginResponseModel> buildFutureBuilder() {
  FutureBuilder buildFutureBuilder() {
    // buraya hiç girmiyoruz artık
    return FutureBuilder(
      future: _futureUserLogin,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.responseCode == 1) {
            print("giriş sayfasına yönlendiriliyorsunuz...");
            Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false);
          } else {
            print("responsecode 1 değil");
            return Text("Yanlış girdiniz.");
          }
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text('${snapshot.error}');
        }
        return Center(child: const CircularProgressIndicator());
      },
    );
  }

  buildMainScreen() {
    return Stack(
      //key: _formKey,
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 140, 167,
                      181), //Color(0xFF84FDD9),//Color(0xFF73AEF5),
                  Color.fromARGB(255, 108, 142,
                      159), //Color(0xFF60E6BE),//  Color(0xFF61A4F1),
                  Color.fromARGB(255, 107, 141,
                      155), //Color(0xFF72F5CE),// Color(0xFF478DE0),
                  Color.fromARGB(255, 45, 92,
                      114), //Color(0xFF1AB7AC),// Color(0xFF398AE5),
                ],
                stops: [
                  0.1,
                  0.4,
                  0.7,
                  0.9
                ]),
          ),
        ),
        Container(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 300.0,
            ),
            //key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                //_loginButton()
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                _IsGirisBtn(),
                const SizedBox(
                  height: 30.0,
                ),
                _IsListeleBtn(),
              ],
            ),
          ),
        )
      ],
    );
  }

  //ButtonTheme

  Widget _IsGirisBtn() => ButtonTheme(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.teal,
              onSurface: Colors.amber,
              minimumSize: Size(100.0, 40.0)),
          child: Text("İş ekleme"),
          onPressed: () {
            return null;
          },
        ),
      );

  Widget _IsListeleBtn() => ButtonTheme(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.teal,
              onSurface: Colors.amber,
              minimumSize: Size(100.0, 40.0)),
          child: Text("İşleri listele"),
          onPressed: () {
            return null;
          },
        ),
      );
}
