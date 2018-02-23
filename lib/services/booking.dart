
import "package:range/range.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class BookingItem{
  String user;
  final int hourEnd;
  final int hourStart;
  final int minuteStart;
  final int minuteEnd;
  final int sortId;
  final String id;

  BookingItem({this.user,this.hourStart,this.minuteStart,this.hourEnd,this.minuteEnd,this.sortId,this.id});

  bool _checked = false;

  bool get checked => _checked;

  set checked(bool value) {
    _checked = value;
  }


}

class BookingTable{
  static List<BookingItem> getDefaultDayTable(){
    List<BookingItem> list = new List();

    range(8,20).toList().forEach((h){
      range(0,60,15).toList().forEach((m){
        int minuteEnd = m+15;
        if(minuteEnd == 60) minuteEnd = 59;
        list.add(new BookingItem(hourStart: h,minuteStart: m,hourEnd: h,minuteEnd: minuteEnd,sortId: int.parse(h.toString()+minuteEnd.toString())));
      });
    });

    return list;
  }
}

class BookingModel{
  Future<List<BookingItem>> getTable(String activityId) async{
  QuerySnapshot snapshot = await Firestore.instance.collection('offices/vinnytsa/activities').document(activityId).getCollection("book_periods").getDocuments();
  return snapshot.documents.map((document){

      return new BookingItem(user: document["user"],
          hourStart: document["hour_start"],
          hourEnd: document["hour_end"],
          minuteStart: document["minute_start"],
          minuteEnd: document["minute_end"],
          sortId: document ["sort_id"],
          id: document.documentID,
      );
    }).toList();
  }

  Future<Null> saveChosenBookingItems(String activityId, List<BookingItem> items, String email) async{
    CollectionReference reference = Firestore.instance.collection('offices/vinnytsa/activities').document(activityId).getCollection("book_periods");
    List<Future<Null>> futures = new List();
    items.forEach((i){
      futures.add(reference.document(i.id).updateData({
        "user":email
      }));
    });
    var stream = new Stream.fromFutures(futures);
    await for(var value in stream){
    }
  }

  Future<Null> deleteOwnBookingItem(String activityId, BookingItem item)async{
    CollectionReference reference = Firestore.instance.collection('offices/vinnytsa/activities').document(activityId).getCollection("book_periods");
    Null n = await reference.document(item.id).updateData({
      "user":null
    });
    return n;
  }

  void addChangesListener(String activityId,fn){
    CollectionReference reference = Firestore.instance.collection('offices/vinnytsa/activities').document(activityId).getCollection("book_periods");
    reference.where("sort_id",isGreaterThan: 0).snapshots.listen(fn);
  }

}
