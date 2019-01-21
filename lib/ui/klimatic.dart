import 'package:flutter/material.dart';
import '../utils/utility.dart' as utility;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered = 'Surat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klimatic'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              goToChangeCityScreen(context);
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('images/umbrella.png',
                width: 490.0, height: 1200.0, fit: BoxFit.fill),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 0.0),
            child: Text('$_cityEntered', style: cityStyle()),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png'),
          ),
          // This will have our weather data.
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(20.0, 250.0, 0.0, 0.0),
            child: updateTemperatureWidget(_cityEntered),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appID, String city) async {
    String apiURL =
        "http://api.openweathermap.org/data/2.5/weather/q=$city&appid=$appID&units=imperial";

    http.Response response = await http.get(apiURL);

    return json.decode(response.body);
  }

  Future goToChangeCityScreen(BuildContext context) async {
    var route = MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    });

    Map results = await Navigator.of(context).push(route);

    if (results != null && results.containsKey('enteredCity')) {
      _cityEntered = results['enteredCity'];

      if (_cityEntered == null || _cityEntered.length == 0) {
        _cityEntered = utility.defaultCity;
      }
    }
  }

  Widget updateTemperatureWidget(String city) {
    return FutureBuilder(
      future: getWeather(utility.apiID, city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        // We get all of the json data, we setup widgets etc.
        if (snapshot.hasData) {
          Map content = snapshot.data;
          print("Yo content is " + content.toString());
          if (content.containsKey('main')) {
            return Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(content['main']['temp'].toString(),
                        style: temperatureStyle()),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
      color: Colors.white, fontStyle: FontStyle.italic, fontSize: 23.0);
}

TextStyle temperatureStyle() {
  return TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontSize: 50.0,
      fontWeight: FontWeight.w500);
}

class ChangeCity extends StatelessWidget {
  final TextEditingController _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change City'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
              child: Image.asset('images/white_snow.png',
                  width: 490.0, height: 1200.0, fit: BoxFit.fill)),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'enteredCity': _cityFieldController.text,
                    });
                  },
                  textColor: Colors.white70,
                  color: Colors.redAccent,
                  child: Text('Get Weather'),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
