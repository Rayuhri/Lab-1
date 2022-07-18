import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ConversionPage());

class ConversionPage extends StatefulWidget {
  const ConversionPage({Key? key}) : super(key: key);

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoCurrency Converter',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('CryptoCurrency Converter'),
          ),
          backgroundColor: Colors.teal[100],
          body: Column(
            children: const [
              SizedBox(height: 10),
              Flexible(
                flex: 6,
                child: ConversionForm(),
              )
            ],
          )),
    );
  }
}

class ConversionForm extends StatefulWidget {
  const ConversionForm({Key? key}) : super(key: key);

  @override
  _ConversionFormState createState() => _ConversionFormState();
}

class _ConversionFormState extends State<ConversionForm> {
  TextEditingController inputEditingController = TextEditingController();
  TextEditingController outputEditingController = TextEditingController();
  double input = 0.0,
      output = 0.0,
      inputCurr = 0.0,
      outputCurr = 0.0,
      rate = 0.0;
  String desc = "No data ";
  String desctype = "";
  String descRate = "";

  String selectCur1 = "btc", selectCur2 = "bnb";
  var name1 = " ",
      unit1 = " ",
      type1 = " ",
      name2 = " ",
      unit2 = " ",
      type2 = " ";
  List<String> curList = [
    "btc",
    "eth",
    "ltc",
    "bch",
    "bnb",
    "eos",
    "xrp",
    "xlm",
    "link",
    "dot",
    "yfi",
    "usd",
    "aed",
    "ars",
    "aud",
    "bdt",
    "bhd",
    "bmd",
    "brl",
    "cad",
    "chf",
    "clp",
    "cny",
    "czk",
    "dkk",
    "eur",
    "gbp",
    "hkd",
    "huf",
    "idr",
    "ils",
    "inr",
    "jpy",
    "krw",
    "kwd",
    "lkr",
    "mmk",
    "mxn",
    "myr",
    "ngn",
    "nok",
    "nzd",
    "php",
    "pkr",
    "pln",
    "rub",
    "sar",
    "sek",
    "sgd",
    "thb",
    "try",
    "twd",
    "uah",
    "vef",
    "vnd",
    "zar",
    "xdr",
    "xag",
    "xau",
    "bits",
    "sats"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: inputEditingController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(),
                    onChanged: (newValue) {
                      _convert();
                    },
                    decoration: InputDecoration(
                      hintText: "Enter the value",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    itemHeight: 60,
                    value: selectCur1,
                    onChanged: (newValue) {
                      selectCur1 = newValue.toString();
                      _convert();
                    },
                    items: curList.map((selectCur1) {
                      return DropdownMenuItem(
                        child: Text(
                          selectCur1,
                        ),
                        value: selectCur1,
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    maxLines: null,
                    controller: outputEditingController,
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    itemHeight: 60,
                    value: selectCur2,
                    items: curList.map((selectCur2) {
                      return DropdownMenuItem(
                        child: Text(
                          selectCur2,
                        ),
                        value: selectCur2,
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selectCur2 = newValue.toString();
                      _convert();
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(descRate,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 14.0)),
                  ),
                  const SizedBox(height: 5),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(desctype,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 14.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _clear, child: const Text("Clear")),
          ],
        ),
      ),
    );
  }

  Future<void> _convert() async {
    var url = Uri.parse('https://api.coingecko.com/api/v3/exchange_rates');
    var response = await http.get(url);
    var rescode = response.statusCode;

    setState(() {
      if (rescode == 200) {
        var jsonData = response.body;
        var parsedJson = json.decode(jsonData);
        name1 = parsedJson['rates'][selectCur1]['name'];
        unit1 = parsedJson['rates'][selectCur1]['unit'];
        type1 = parsedJson['rates'][selectCur1]['type'];
        name2 = parsedJson['rates'][selectCur2]['name'];
        unit2 = parsedJson['rates'][selectCur2]['unit'];
        type2 = parsedJson['rates'][selectCur2]['type'];

        if (selectCur1 == "btc") {
          inputCurr = 1.0;
        } else {
          inputCurr = parsedJson['rates'][selectCur1]['value'];
        }

        if (selectCur2 == "btc") {
          outputCurr = 1.0;
        } else {
          outputCurr = parsedJson['rates'][selectCur2]['value'];
        }
      } else {
        desc = "No data";
      }

      if (inputEditingController.text != "") {
        input = double.parse(inputEditingController.text);
        output = (input / inputCurr) *
            outputCurr; //calculation of rate of currencies
        rate = (outputCurr / inputCurr);
        outputEditingController.text = output.toString();
        descRate = "1 " +
            selectCur1 +
            " = " +
            rate.toStringAsFixed(2) +
            " " +
            selectCur2 +
            ". ";
        desc = unit1 +
            " " +
            input.toString() +
            " " +
            " = " +
            unit2 +
            " " +
            output.toStringAsFixed(2) +
            " ";
      }
    });
  }

  void _clear() {
    setState(() {
      inputEditingController.clear();
      outputEditingController.clear();
      desc = "No Data";
      descRate = " ";
      desctype = " ";
    });
  }
}
