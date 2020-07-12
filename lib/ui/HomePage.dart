import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _searchText;
  int _limit = 19;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_searchText == null || _searchText.isEmpty) response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=UcfvVixHJ3UYElkPELg90lHEJDHh9mH8&limit=$_limit&rating=g');
    else response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=UcfvVixHJ3UYElkPELg90lHEJDHh9mH8&q=$_searchText&limit=$_limit&offset=$_offset&rating=g&lang=en');
    return json.decode(response.body);
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch(snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.none:
        return Container(
          width: 200.0,
          height: 200.0,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      default:
        if (snapshot.hasError) {
          return Container(child: Text(snapshot.error.toString(), style: TextStyle(color:Colors.white),),);
        }
        else return _gifTableBuilder(context, snapshot);
    }
  }

  Widget _gifTableBuilder (BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(9.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: snapshot.data['data'].length + 1,
      itemBuilder: (context, index){
        if (index < snapshot.data['data'].length)
          return GestureDetector(
            child: Image.network(
              snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text(
                    'carregar mais...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += _limit;
                });
              },
            ),
          );

      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(9.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Pesquise aqui',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(
                  color:Colors.white,
                  fontSize: 18.0
              ),
              onSubmitted: (text) {
                setState(() {
                  _searchText = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: _futureBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
