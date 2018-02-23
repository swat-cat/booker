import 'package:booker/screens/main/booking.dart';

import '../../base/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:booker/services/activities.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => new _ActivitiesState();
}

class _ActivitiesState extends LoadingBaseState<Activities> {

  ActivitiesModel _activitiesModel = new ActivitiesModel();
  List<ActivityData> activities;

  @override
  void initState() {
    title = "Office Activities";
    isLoading = true;
    hasUser = true;
    _checkNeedClearData();
    _activitiesModel.getAllActivities().then((activities){
      setState((){
        isLoading = false;
        this.activities = activities;
      });
    });
  }

  @override
  Widget content() {
    return new Container(
      margin: const EdgeInsets.all(24.0),
      child: new ListView.builder(
          itemBuilder: (BuildContext context, int index) => new ActivityItem(activities[index]),
          itemCount: activities==null?0:activities.length,
      )
    );
  }

  void _checkNeedClearData() {

  }
}

class ActivityItem extends StatelessWidget {

  ActivityItem(this.activityData);
  final ActivityData activityData;

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Container(
          padding: const EdgeInsets.all(24.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new InkWell(
                onTap: (){
                  Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new Booking(activityData),
                  ));
                },
                child: new Image.network(
                  activityData.imageUrl,
                  fit: BoxFit.fitHeight,
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              new Padding(padding: new EdgeInsets.only(top: 8.0)),
              new Divider(
                height: 2.0,
                color: new Color(0xff64B5F6),
              ),
              new ListTile(
                onTap: (){
                  Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new Booking(activityData),
                  ));
                },
                title: new Text(activityData.name),
              )
            ],
          ),
        )
    );
  }
}
