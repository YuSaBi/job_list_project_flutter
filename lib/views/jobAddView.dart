//import 'package:flutter/cupertino.dart';
//import 'dart:js';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/httpConfig.dart';
import 'package:job_list_project/models/jobRequestModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:job_list_project/models/jobResponseModel.dart';

/// MAIN CLASS ///
class jobAdd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _jobAdd();
  }
}

/// MAIN STATE ///
class _jobAdd extends State {
  jobRequestModel eklenecekJob = jobRequestModel(-1, "", "", -1, -1, -1, -1);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late SharedPreferences sharedPreferences;
  int userID = -1;
  //jobAdd({Key? key}) : super(key: key);

  List<String> musteri = ["shell", "bp", "opet"];
  String? musteriSelectedVal;
  List<String> durum = ["yeni", "devam", "bitti"];
  String? durumSelectedVal;
  List<String> oncelik = ["düşük", "orta", "yüksek"]; // SUNUCUDAN ÇEKİLECEK
  String? oncelikSelectedVal;

  @override
  void initState() {
    getUserID();
    super.initState();
  }

  getUserID() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      userID = int.parse(sharedPreferences.getString('userID').toString());
    } catch (e) {
      print(e.toString());
      print("Shared Proferences ile ilgili hata var");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İş ekle"),
        backgroundColor: Colors.teal.shade300,
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  /// BODY ///
  buildBody() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      buildBaslikField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildDetayField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildHarcanansureField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildCustomerIdField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildDurumField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildPriorityField(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      buildSubmitButton(),
                    ],
                  ),
          )),
    );
  }

  buildBaslikField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Başlık",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "başlık değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.baslik = newValue;
      },
    );
  }

  buildDetayField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        labelText: "Detay",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "Detay değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.detay = newValue;
      },
    );
  }

  buildHarcanansureField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Harcanan Süre (dk)",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "Harcanan süre değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.harcananSure = int.parse(newValue.toString());
      },
    );
  }

  buildCustomerIdField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Müşteri"),
        DropdownButton<String>(
          items: musteri.map(buildMusteriItem).toList(),
          //onChanged: (value) => setState(() => this.musteriSelectedVal =value),
          onChanged: (value) {
            setState(() {
              this.musteriSelectedVal = value;
            });
            eklenecekJob.musteri = musteri.indexOf(value.toString()) + 1;
          },
          value: musteriSelectedVal,
          alignment: Alignment.centerRight,
        ),
      ],
    );
    /*
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Müsteri",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "Müşteri değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.musteri=int.parse(newValue.toString()); // DEĞİŞTİRİLECEK
      },
    );
    */
  }

  DropdownMenuItem<String> buildMusteriItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
        ),
      );

  buildDurumField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Durum"),
        DropdownButton<String>(
          items: durum.map(buildDurumItem).toList(),
          //onChanged: (value) => setState(() => this.musteriSelectedVal =value),
          onChanged: (value) {
            setState(() {
              this.durumSelectedVal = value;
            });
            eklenecekJob.durum = durum.indexOf(value.toString()) + 1;
          },
          value: durumSelectedVal,
          alignment: Alignment.centerRight,
        ),
      ],
    );
    /*
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Durum",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "Durum değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.durum=int.parse(newValue.toString()); // DEĞİŞTİRİLECEK
      },
    );
    */
  }

  DropdownMenuItem<String> buildDurumItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
        ),
      );

  buildPriorityField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Öncelik"),
        DropdownButton<String>(
          items: oncelik.map(buildOncelikItem).toList(),
          //onChanged: (value) => setState(() => this.musteriSelectedVal =value),
          onChanged: (value) {
            setState(() {
              this.oncelikSelectedVal = value;
            });
            eklenecekJob.oncelik = oncelik.indexOf(value.toString()) + 1;
          },
          value: oncelikSelectedVal,
          alignment: Alignment.centerRight,
        ),
      ],
    );
    /*
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Öncelik",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "Öncelik değeri boş bırakılamaz";
        }
      }),
      onSaved: (newValue) {
        eklenecekJob.oncelik=int.parse(newValue.toString()); // DEĞİŞTİRİLECEK
      },
    );
    */
  }

  DropdownMenuItem<String> buildOncelikItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          //style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  bool isDropDownValidate() {
    bool validate = true;
    if (musteriSelectedVal == null ||
        durumSelectedVal == null ||
        oncelikSelectedVal == null) {
      validate = false;
    }
    return validate;
  }

  buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.teal, minimumSize: const Size(80, 40)),
      child: const Text("Kaydet"),
      onPressed: () {
        if (_formKey.currentState!.validate() && isDropDownValidate()) {
          setState(() {
            _isLoading = true;
          });
          _formKey.currentState!.save();
          addJob(eklenecekJob);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen boş alanları doldurunuz')),
          );
        }
      },
    );
  }

  void addJob(jobRequestModel eklenecekJob) async {
    try {
      postMethodConfig config = postMethodConfig();
      var jsonData;
      final response = await http.post(
        Uri.parse('${config.baseUrl}saveJob_Manager'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "userID": userID,
          "baslik": eklenecekJob.baslik,
          "harcananSure": eklenecekJob.harcananSure,
          "detay": eklenecekJob.detay,
          "customerID": eklenecekJob.musteri,
          "durum": eklenecekJob.durum,
          "priorityID": eklenecekJob.oncelik,
        }),
      );
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData['responseCode'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt işlemi başarılı')),
          );
        } else if (jsonData['responseCode'] == 303) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu iş zaten mevcut')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata kodu: ${jsonData['responseCode']}')),
          );
        }
      } else {
        // responseStatus != 200
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('sistemsel hata Kod: 139')),
        );
      }
    } catch (e) {
      print(e.toString());
      print("post methodunda sorun var :(");
    }
  }
}
