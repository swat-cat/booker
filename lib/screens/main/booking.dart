import 'package:booker/services/activities.dart';
import 'package:booker/services/authentication.dart';
import 'package:booker/services/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booker/base/loading_state.dart';
import 'package:intl/intl.dart';
import "package:range/range.dart";


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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email;

  @override
  Widget content() {
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
          new Expanded(
              child:  new Row(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    flex: 1,
                    child: timeList,
                  ),
                  new Expanded(
                      flex: 6,
                      child: _table!=null? timeTableGridView: new Container())
                ],
              ))
        ],
      ),
    );
  }

  ListView get timeList{
    var list = range(8,21).toList();
    return new ListView.builder(
        itemBuilder:(BuildContext context, int index) => new Container(
          child: new Container(
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
              crossAxisCount: 6,
              childAspectRatio: 2.0,
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
        onboardingItem(context, Colors.blueAccent, "Free")
      ],
    );
  }

  Widget onboardingItem(BuildContext context, Color c, String s){
    return new Expanded(
      child: new Column(
        children: <Widget>[
          new Padding(padding: new EdgeInsets.all(4.0)),
          bookItem(c),
          new Text(s)
        ],
      ),
    );
  }

  Widget bookItem(Color c) {
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

  @override
  void initState() {
    super.initState();
    title = "Book for "+ activityData.name;
    _auth.currentUser().then((user){
      setState(()=>_email = user.email);
      bookingModel.getTable(activityData.id).then((table){
        setState((){
          this._table = table;
        });
      });
    });
  }

  _BookingState(this.activityData);

  List<Widget>_getTable() {
    List<Widget> items = new List();
    _table.forEach((item){
      items.add(new GridTile(child: bookItem(getColor(item))));
    });
    return items;
  }

  Color getColor(BookingItem bookingItem){
    if(bookingItem.user == null){
      return Colors.blueAccent;
    }
    else if(bookingItem.user == _email){
      return Colors.orangeAccent;
    }
    else{
      return Colors.greenAccent;
    }
  }
}

