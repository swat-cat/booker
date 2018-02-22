import 'package:booker/services/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ActivityData{
  final String name;
  final String id;
  final String imageUrl;

  ActivityData(this.name, this.id, this.imageUrl);
}

class ActivitiesModel{
  CollectionReference get activities => Firestore.instance.collection('offices/vinnytsa/activities');
  DocumentReference get office => Firestore.instance.collection("offices").document("vinnytsa");
  final formatter = new DateFormat("dd MMM yyyy");

  Future<List<ActivityData>> getAllActivities() async{
    QuerySnapshot snapshot = await  activities.getDocuments();
    checkToday();
    List<ActivityData> activityList = snapshot.documents.map((document){
      return new ActivityData(document["name"], document.documentID, document["icon"]);
    }).toList();
    return activityList;
  }

  void checkToday() {
    office.get().then((doc) {
      String today = doc["today"];
      if (today != formatter.format(new DateTime.now())) {
        office.setData({
          "today":formatter.format(new DateTime.now())
        });
        activities.getDocuments().then((activities) {
          activities.documents.forEach((activity) {
            CollectionReference bookPeriodsRef = this.activities.document(
                activity.documentID).getCollection("book_periods");
            bookPeriodsRef.getDocuments().then((bookPeriods) {
              bookPeriods.documents.forEach((period) {
                if (period.documentID != "test") {
                  bookPeriodsRef.document(period.documentID).delete();
                }
              });
              bookPeriodsRef = this.activities.document(activity.documentID).getCollection("book_periods");
              print(bookPeriodsRef.toString());
              for (BookingItem item in BookingTable.getDefaultDayTable()) {
                print(item.minuteEnd.toString());
                bookPeriodsRef.document().setData(
                    {
                      "hour_start": item.hourStart,
                      "hour_end": item.hourEnd,
                      "minute_start": item.minuteStart,
                      "minute_end": item.minuteEnd,
                      "sort_id": item.sortId
                    }
                ).then((Null){
                  print("Success");
                }).catchError((e){
                  print(e);
                });
              }
            });
          });
        });
      }
    });
  }
}