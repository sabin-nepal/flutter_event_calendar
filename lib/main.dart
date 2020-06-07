import 'package:event_picker/src/core/data/app_theme.dart';
import 'package:event_picker/src/core/data/event.dart';
import 'package:event_picker/src/screen/eventcalendar.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Picker',
      theme: AppThemes.gradientTheme,
      home: MyHomePage(title: 'Child Activity Tracker..'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});
  //initialize the title
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = Firestore.instance;
  List<Event> _events= [];
  @override
  void initState(){
    super.initState();
    _getData();
  }

  void _getData() async{
    var getDates = await databaseReference.collection("events").orderBy("date", descending: true).getDocuments();
    getDates.documents.forEach((e){
       var dateTime = e.data['date'].toDate();
      var _event = Event(title:e.data['title'],dateTime:dateTime);
      _events.add(_event);
    });
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 12),
        ),
        gradient:
            LinearGradient(colors: [Color(0xFF5F52BC), Color(0xFF50BE91)]),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundColor: Color(0xffFFFFFF),
              radius: 30,
              child: IconButton(
                  icon:
                      Image.asset('assets/calendar.png', height: 18, width: 15),
                  // Within the `FirstRoute` widget
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => DisplayCalendar()),
                    );
                  }),
            ),
          )
        ],
      ),
      body:Container(
        padding: EdgeInsets.only(left:10,right: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(25)
          ),
          child:
              _childActivity(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
              onPressed: (){},
              tooltip: 'Add',
              child: Icon(Icons.add),
              backgroundColor: Color(0xff50BE91),
        ), 
    );
  }

  Widget _childActivity(){
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context,i)=>Divider(),
        itemCount: _events.length,
        itemBuilder: (context,i){
          var event = _events[i];
          var _dateTime = DateFormat('MMMM d, yyyy - hh:mm a').format(event.dateTime);
          return ListTile(
            title: Text(_dateTime),
            trailing: Icon(Icons.chevron_right,color: Colors.black,),
          );
        }
        );
  }
}
