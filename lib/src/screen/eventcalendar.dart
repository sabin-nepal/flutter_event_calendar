import 'package:event_picker/src/core/data/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayCalendar extends StatefulWidget{
  @override
  _DisplayCalendarState createState()  => _DisplayCalendarState();

}

class _DisplayCalendarState extends State<DisplayCalendar>{
  final databaseReference = Firestore.instance;
  Map<DateTime,List<Event>> _events = {};
  List _selectedEvents= [];
  CalendarController _controller;
  
  @override
  void initState(){
    super.initState();
    showData();
    _controller = CalendarController();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void  showData ()async{
    var getEvents = await databaseReference.collection('events').getDocuments();
    getEvents.documents.forEach((e){
      var dateTime = e.data['date'].toDate();
      var _event = Event(title:e.data['title'],dateTime:dateTime);
      if(_events[dateTime]==null){
        _events[dateTime] = [_event];
      }
      else{
        _events[dateTime].add(_event);
      }
     // _events = 
    });
    _selectedEvents = _events[DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    )];
    setState(() {});
  }

  void _onDaySelected(DateTime day, List events) {
  
    setState(() {
      _selectedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.clear),
          tooltip: "Back",
          color: Colors.black,
          onPressed:() => Navigator.pop(context),
          ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body:Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildTableCalendar(),
            Divider(),
          Expanded(child: _buildEventList()),
        ],)
      
    );
  }

  
  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      initialCalendarFormat: CalendarFormat.twoWeeks,
      calendarController: _controller,
      events: _events,
      headerStyle: HeaderStyle(
        centerHeaderTitle:true,
        formatButtonVisible:false,
      ),
      builders: CalendarBuilders(

        todayDayBuilder: (context, date, _) {
          return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
              color: Color(0xFF5F52BC),
              shape: BoxShape.circle
            ),
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
          );
        },

        selectedDayBuilder: (context, date,_) {
          var hasData = _events[date]==null ? false : _events[date].length > 0 ;
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
              color: hasData? Color(0xff50BE91) : Color(0xFFE1E1E1),
              shape: BoxShape.circle
            ),
        
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
          );
        },
      
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                color: _controller.isSelected(date)
              ? Color(0xff50BE91)
              : _controller.isToday(date) ? Color(0xffFFFFFF) : Color(0xffFFFFFF),
            
              border: Border.all(
                color: Color(0xff50BE91),
                width: 2
              ),
                shape: BoxShape.circle
              ),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              )
            );
          }
          return children;
        },
      ),
      onDaySelected: _onDaySelected,
      );
  }
  Widget _buildEventList() {
    if(_selectedEvents.length == 0 ){
      return Container(
        alignment: Alignment.center,
        child: Column(
          children:<Widget>[
            Image.asset('assets/form_empty.png',height: 93, width: 98,),
            Padding(padding:EdgeInsets.only(top: 16)),
            Text("No Form Entry Record Found",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            Padding(padding:EdgeInsets.only(top: 8)),
            Text("No form entries for that date. Green circle above in  \n calender indicate the dates that have recrods",
              style: TextStyle(
                fontSize: 9
              ),
            )
          ]
        ),
        );
    }
    return ListView.separated(
      itemCount: _selectedEvents.length,
      separatorBuilder: (context,i)=>Divider(),
      itemBuilder: (context,i){
        var event = _selectedEvents[i];
        return ListTile(
          title: Text(event.title.toString()),
          trailing: Icon(Icons.chevron_right,color: Color(0xFF50BE91),),
        );
      },
    );
  }
}