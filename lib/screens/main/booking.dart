import 'package:booker/services/activities.dart';
import 'package:booker/services/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booker/base/loading_state.dart';
import 'package:intl/intl.dart';
import "package:range/range.dart";
import 'package:booker/base/dialog_shower.dart' as DialogShower;


class Booking extends StatefulWidget {

  final ActivityData activityData;
  Booking(this.activityData);

  @override
  _BookingState createState() => new _BookingState(activityData);
}

class _BookingState extends LoadingBaseState<Booking> {


  final ActivityData activityData;
  final formatter = new DateFormat("dd MMM yyyy");
  final BookingModel bookingModel = new BookingModel();
  List<BookingItem> _table;
  int _chosenLatch = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email;

  @override
  Widget content() {
    return new Stack(
      children: <Widget>[
        mainContent
      ],
    );
  }

  Container get mainContent {
    return new Container(
      margin: new EdgeInsets.all(16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            activityData.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0
            ),
          ),
          new Padding(padding: const EdgeInsets.only(top: 4.0)),
          new Text(
            "Today: " + formatter.format(new DateTime.now()),
            style: const TextStyle(fontSize: 16.0),
          ),
          new Padding(padding: const EdgeInsets.only(top: 4.0)),
          new Divider(
            height: 2.0,
            color: new Color(0xff64B5F6),
          ),
          onboarding(context),
          new Padding(padding: const EdgeInsets.only(top: 4.0)),
          new Divider(
            height: 2.0,
            color: new Color(0xff64B5F6),
          ),
          _table!=null?new Expanded(
              child: timeTableGridView):new Container(),
          _chosenLatch>0 ? new Align(
            child: new RaisedButton(
              onPressed: _saveChosenItems,
              color: new Color(0xff64B5F6),
              child: new Text("Save",
                style: new TextStyle(
                    color: new Color(0xffffffff)
                ),
              ),
            ),
          ) : new Container(),
          _chosenLatch>0
              ? new Padding(padding: new EdgeInsets.only(bottom: 4.0,top: 4.0))
              : new Container(),
        ],
      ),
    );
  }

  ListView get timeList{
    var list = range(8,21).toList();
    return new ListView.builder(
        itemBuilder:(BuildContext context, int index) => new Container(
          child: new Container(
            margin: new EdgeInsets.only(top: 2.1,bottom: 2.1),
            height: 20.0,
            width: 30.0,
            alignment: Alignment.center,
            child: new Text(list[index].toString()+":00"),
          ),
        ),
        itemCount: list.length,
    );
  }

  GridView get timeTableGridView {
    return new GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 2.75,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
              children: _getTable(),
            );
  }

  Widget onboarding(BuildContext context){
    return new Row(
      children: <Widget>[
        onboardingItem(context,Colors.orangeAccent,"Yours"),
        new Padding(padding: new EdgeInsets.only(right: 8.0)),
        onboardingItem(context, Colors.greenAccent, "Booked"),
        new Padding(padding: new EdgeInsets.only(right: 8.0)),
        onboardingItem(context, Colors.blueAccent, "Free"),
        new Padding(padding: new EdgeInsets.only(right: 8.0)),
        onboardingItem(context, Colors.pinkAccent, "Choosen"),
      ],
    );
  }

  Widget onboardingItem(BuildContext context, Color c, String s){
    return new Expanded(
      child: new Column(
        children: <Widget>[
          new Padding(padding: new EdgeInsets.all(4.0)),
          onborardingItem(c),
          new Text(s)
        ],
      ),
    );
  }

  Widget onborardingItem(Color c) {
    return new Container(
          height: 30.0,
          decoration: new BoxDecoration(
              color: c,
              borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
              border: new Border.all(
                color: Colors.grey
              )
          ),
        );
  }

  Widget bookItem(int index) {
    return new GestureDetector(
      child: new Container(
        height: 30.0,
        alignment: Alignment.center,
        child: new Text(
            _getItemText(_table[index]),
            style: new TextStyle(
              fontSize: 9.0,
              color: Colors.white
            )),
        decoration: new BoxDecoration(
            color: getColor(_table[index]),
            borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
            border: new Border.all(
                color: Colors.grey
            )
        ),
      ),
      onTap: (){
        _handleBookItemClick(index);
      },
    );
  }

  _handleBookItemClick(int index){
    if(_table[index].checked){
      setState((){
        _chosenLatch--;
        _table[index].checked = false;
      });
    }
    else if(_table[index].user == null){
      setState((){
        _chosenLatch++;
        _table[index].checked = true;
      });
    }
    else if(_table[index].user == _email){
      showAlreadyYoursPopup(_table[index]);
    }
    else{
      showBookedPopup(_table[index]);
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    hasUser = true;
    title = "Book for "+ activityData.name;
    _auth.currentUser().then((user){
      setState(()=>_email = user.email);
      bookingModel.addChangesListener(activityData.id,(snapshot){
        updateTable();
      });
    });
  }

  void updateTable() {
    bookingModel.getTable(activityData.id).then((table){
      setState((){
        this._table = table;
        isLoading = false;
      });
    });
  }

  _BookingState(this.activityData);

  List<Widget>_getTable() {
    List<Widget> items = new List();
    for(int i =0; i< _table.length; i++){
      items.add(new GridTile(child: bookItem(i)));
    }
    return items;
  }

  Color getColor(BookingItem bookingItem){
    if(bookingItem.checked){
      return Colors.pinkAccent;
    }
    else if(bookingItem.user == null){
      return Colors.blueAccent;
    }
    else if(bookingItem.user == _email){
      return Colors.orangeAccent;
    }
    else{
      return Colors.greenAccent;
    }
  }

  void showAlreadyYoursPopup(BookingItem item) {
    var dialog = DialogShower.buildDialog(
        message:  "Release previously booked time?",
        confirm: "YES",
        confirmFn: () {
          setState(()=>isLoading = true);
          bookingModel.deleteOwnBookingItem(activityData.id, item);
          Navigator.pop(context);
        },
        cancel: "NO",
        cancelFn: ()=> Navigator.pop(context)

    );
    showDialog(context: context, child: dialog);
  }

  void showBookedPopup(BookingItem item) {
    var dialog = DialogShower.buildDialog(
        message:  "Time booked by user: "+item.user,
        confirm: "OK",
        confirmFn: ()=>Navigator.pop(context)
    );
    showDialog(context: context, child: dialog);
  }

  void _saveChosenItems() {
    List<BookingItem> chosen = _table.where((item){
      return item.checked;
    }).toList();
    List<BookingItem> prevBooked = _table.where((item){
      return item.user == _email;
    }).toList();
    if(chosen.length>4){
      var dialog = DialogShower.buildDialog(message: "Booking more then hour? Leave a chance to other people.",
      confirm: "OK",confirmFn: ()=>Navigator.pop(context));
      showDialog(context: context, child: dialog);
      return;
    }
    else if((prevBooked.length+chosen.length)>6){
      var dialog = DialogShower.buildDialog(message: "You've already booked "+(prevBooked.length*15).toString()+" minutes before. There is only "+((6-prevBooked.length)*15).toString()+" minutes available.",
          confirm: "OK",confirmFn: ()=>Navigator.pop(context));
      showDialog(context: context, child: dialog);
      return;
    }else if(!_checkChosenItemsCorrectlySpreaded(chosen)){
      var dialog = DialogShower.buildDialog(message: "It seems you're trying to book time in several hour lines. Cheating is bad ;)",
          confirm: "OK",confirmFn: ()=>Navigator.pop(context));
      showDialog(context: context, child: dialog);
      return;
    }
    setState(()=>isLoading = true);
    bookingModel.saveChosenBookingItems(activityData.id, chosen, _email);
  }

  bool _checkChosenItemsCorrectlySpreaded(List<BookingItem> items){
    BookingItem firstItem = items.first;
    bool correctly = true;
    items.forEach((item){
      if((firstItem.hourStart - item.hourStart)>1 || (firstItem.hourStart - item.hourStart)<-1){
        correctly = false;
      }
    });
    return correctly;
  }

  String _getItemText(BookingItem table) {
    String minuteStart = table.minuteStart>9?table.minuteStart.toString():"0"+table.minuteStart.toString();
    String minuteEnd = table.minuteEnd>9?table.minuteEnd.toString():"0"+table.minuteEnd.toString();
    String result = table.hourStart.toString()+":"+minuteStart+"-"+table.hourEnd.toString()+':'+minuteEnd;
    return result;
  }
}


