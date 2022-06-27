

import 'dart:convert';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'ad_helper.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  final _noteController = TextEditingController();
  
  List _noteList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  BannerAd _ad; 
  bool isLoaded;

  

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _noteList = json.decode(data);
      });
    });
  }

  void _addNote() {
    setState(() {
      Map<String, dynamic> newNote = Map();
      newNote["title"] = _noteController.text;
      _noteController.text = "";
      newNote["ok"] = false;
      _noteList.add(newNote);

      _saveData();
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Widget get checkforAd {
    if (isLoaded == true) {
      return Container(
        child: AdWidget(
          ad: _ad ,
        ),
        width: _ad.size.width.toDouble(),
        height: _ad.size.height.toDouble(),
        alignment: Alignment.bottomCenter,
      );
    } else {
      return CircularProgressIndicator();
    }
  }


  @override
  Widget build(BuildContext context) {
    
     _ad = BannerAd(
      size: AdSize.banner, 
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest() , 
      listener: AdListener(onAdLoaded: (_) {
        setState(() {
          isLoaded = true;
        });
      },
      onAdFailedToLoad: (_, error) {
        print('Ad Failed to Load with Error: $error');
      }),  
      );
      _ad.load();
   

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("anotado",
        style: TextStyle(color: Colors.white,
        fontSize: 28.0, fontWeight: FontWeight.bold),
        textAlign: TextAlign.start
        )
      ),

      backgroundColor: Colors.white,

      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child:TextField(
                  cursorColor: Colors.purple,     
                  style: TextStyle(color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  ),
                  controller: _noteController,  
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    labelText: "Crie sua nota rápida",
                    labelStyle: TextStyle(
                      color: Colors.purple,
                    )
                  )
                 ),  
                ),


                IconButton(
                  iconSize: 36.0,
                  icon: FaIcon(FontAwesomeIcons.plusSquare,
                  color: Colors.purple,
                  ), 
                  onPressed: _addNote,
                )
              ]
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 250.0, 0.0),
            child:Text(
              "Suas Notas",
              style: TextStyle(color: Colors.grey, 
              fontSize: 15.0, fontWeight: FontWeight.bold
              ),
            ), 
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _noteList.length,
              itemBuilder: buildItem,
            )
          ),

          Divider(),

          Container(
            child: checkforAd,
          ), //novo bannerAd    
        ],
      ),
    );
  }


Widget buildItem (context, index){
  return Dismissible(
    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
    background: Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment(-0.9, 0.0),
        child: Icon(Icons.delete, color: Colors.white),
      )
    ),
    direction: DismissDirection.startToEnd,
    child: ListTile(
    title: Text(_noteList[index]["title"],
      style: TextStyle(color: Colors.purple, 
      fontWeight: FontWeight.bold,
      ),
    ),
    leading: IconButton(
    icon: FaIcon(FontAwesomeIcons.shareSquare, color: Colors.purple), 
    onPressed:(){
      Share.share(_noteList[index]["title"]);
    }),
   ),
    onDismissed: (direction){
      setState(() {
      _lastRemoved = Map.from(_noteList[index]);
      _lastRemovedPos = index;
      _noteList.removeAt(index);

      _saveData();

      
      final snack = SnackBar(
        content: Text("Nota ${_lastRemoved["title"]} excluida"),
        action: SnackBarAction(
          label: "Desfazer", 
          onPressed: (){
            setState(() {
              _noteList.insert(_lastRemovedPos, _lastRemoved);
              _saveData();
            });
          }
        ),

        duration: Duration(seconds: 2),

      );

      ScaffoldMessenger.of(context).showSnackBar(snack);

      });
    },
  );
}






Future<File> _getFile() async{
  final diretory = await getApplicationDocumentsDirectory();
  return File("${diretory.path}/data.json");
}

Future<File> _saveData() async{
  String data = json.encode(_noteList);

  final file = await _getFile();
  return file.writeAsString(data);
}

Future<String> _readData() async{
  try {
    final file = await _getFile();

    return file.readAsString();
  } catch (e){
    return "";
  }
}

}

