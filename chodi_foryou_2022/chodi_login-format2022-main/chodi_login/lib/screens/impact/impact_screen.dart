import 'package:flutter/material.dart';
import 'package:flutter_chodi_app/models/activity.dart';
import 'package:flutter_chodi_app/screens/impact/organization_screen.dart';
import 'package:flutter_chodi_app/screens/impact/performance/performance_screen.dart';
import 'package:flutter_chodi_app/screens/impact/recent_activity_screen.dart';
import 'package:flutter_chodi_app/services/firebase_authentication_service.dart';
import 'package:flutter_chodi_app/services/firebase_storage_service.dart';
import 'package:flutter_chodi_app/services/google_authentication_service/log_out_button.dart';
import 'package:flutter_chodi_app/viewmodel/main_view_model.dart';
import 'package:flutter_chodi_app/widget/organization_widget.dart';
import 'package:flutter_chodi_app/widget/profile_avatar.dart';
import 'package:flutter_chodi_app/widget/recent_activity_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widget/clock/analog_clock.dart';

FirebaseService fbservice = FirebaseService();
Storage storage = Storage();
late Future recentHistoryData;
late Future supportedOrganizationsData;
late Future organizationImageURLs;

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({Key? key}) : super(key: key);

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

/*RecentAmount imposes a cap on the amount of data that can be read at once (so that we don't
read all the data*/
Future<List<dynamic>> _getRecentHistoryDataImpact(recentAmount,
    [dataField]) async {
  List<dynamic> dataList = []; //contain entire dataset for the collection
  List<dynamic> recentHistoryDataList =
      []; //contain information for recentActivityWidget
  int totalDonations = 0;
  int totalHours = 0;
  int totalParticipatedEvents = 0;

  if (dataField == 'assetURL') {
  } else {
    await fbservice.getUserRecentHistoryData().then((res) => {
          totalParticipatedEvents = res.length,
          dataList = res,
          for (var i = 0; i < res.length; i++)
            {
              if (res[i]['action'] == 'donation')
                {totalDonations += int.parse(res[i]['donated'])}
              else if (res[i]['action'] == 'volunteer')
                {
                  {totalHours += int.parse(res[i]['donated'])}
                }
            }
        });
  }

  //Cap on getting activity
  for (int i = 0; i < dataList.length; i++) {
    if (i < recentAmount) {
      await storage.downloadURL(dataList[i]['assetURL']).then((res) => {
            recentHistoryDataList.add(
              [dataList[i]['organizationName'], res],
              //["World Concern", assetURL]
            )
          });
    }
  }

  return [
    dataList,
    totalDonations,
    totalHours,
    totalParticipatedEvents,
    recentHistoryDataList
  ];
}

//support function for other functions
Future<List<dynamic>> _getSupportedOrganizations([dataField]) async {
  List<dynamic> listURL = [];

  await fbservice.getUserSupportedOrganizationsData().then((res) async => {
        if (dataField == 'assetURL')
          {
            for (int i = 0; i < res.length; i++)
              {
                await storage.downloadURL(res[i]['assetURL']).then((res2) => {
                      listURL.add({
                        'organization': [res[i]["organizationName"], res2]
                      })
                      //"organization" : [World Concern, imageDownloadURL]
                    })
              }
          }
      });

  return listURL;
}

//Read data from Firebase Storage to get images
List<Widget> _createOrganizationWidget(BuildContext context,
    [List<dynamic>? organizationImageURL]) {
  var avatars = <Widget>[];

  if (organizationImageURL != null) {
    if (organizationImageURL.isEmpty) {
      avatars.add(const Text(''));
    } else {
      for (var i = 0; i < organizationImageURL.length; i++) {
        if (i < 4) {
          avatars.add(ProfileAvatar(
              assetURL: organizationImageURL[i]['organization'][1]));
        } else {
          break;
        }
      }
    }
  }

  avatars.add(GestureDetector(
    onTap: () {
      Provider.of<MainScreenViewModel>(context, listen: false)
          .setWidget(const OrganizationScreen());
    },
    child: SvgPicture.asset(
      "assets/svg/arrow_right.svg",
      width: 15,
      height: 15,
    ),
  ));

  return avatars;
}

List<Widget> _createRecentActivityWidget(recentAmount,
    [List<dynamic>? recentList, List<dynamic>? recentURLList]) {
  var list = <Widget>[];
  String activityResults = '';
  String date = '';

  //retrieve data and hours/minutes from firebase
  if (recentList != null && recentURLList != null) {
    for (var i = 0; i < recentList.length; i++) {
      if (i < recentAmount) {
        date = DateFormat.yMMMd().format(recentList[i]['date'].toDate());
        if (recentList[i]['action'] == 'volunteer') {
          if (int.parse(recentList[i]['donated']) < 1) {
            activityResults = recentList[i]['donated'] + ' minutes';
          } else {
            activityResults = recentList[i]['donated'] + ' hours';
          }
        } else if (recentList[i]['action'] == 'donation') {
          activityResults = recentList[i]['donated'] + ' dollars';
        }

        if (i == 0) {
          list.add(Padding(
            padding: const EdgeInsets.all(0),
            child: RecentActivityWidget(
                activity: Activity(recentURLList[i][1],
                    recentList[i]['organizationName'], activityResults, date)),
          ));
        } else {
          list.add(Padding(
            padding: const EdgeInsets.only(top: 20),
            child: RecentActivityWidget(
                activity: Activity(recentURLList[i][1],
                    recentList[i]['organizationName'], activityResults, date)),
          ));
        }
      }
    }
  }

  return list;
}

class _ImpactScreenState extends State<ImpactScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  String totalEventsParticipatedIn = '';

  @override
  void initState() {
    super.initState();
    recentHistoryData = _getRecentHistoryDataImpact(10); //START AT 10
    supportedOrganizationsData = _getSupportedOrganizations();
    organizationImageURLs = _getSupportedOrganizations('assetURL');

    controller = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() => {});
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait(
          [
            recentHistoryData,
            supportedOrganizationsData,
            organizationImageURLs,
            //_getTotalParticipatedEvents(),
            //_getOrganizationWidget(context),
          ],
        ),
        builder: ((BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Scaffold(
                body: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          "Hi there",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      AnalogClock(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.black),
                            color: Colors.transparent,
                            shape: BoxShape.circle),
                        width: 100.0,
                        height: 100.0,
                        isLive: true,
                        hourHandColor: Colors.black,
                        minuteHandColor: Colors.black,
                        showSecondHand: true,
                        numberColor: Colors.black87,
                        showNumbers: true,
                        showAllNumbers: true,
                        textScaleFactor: 1.4,
                        showTicks: true,
                        showDigitalClock: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Text(
                          (snapshot.data[0][2] * animation.value)
                              .toInt()
                              .toString(),
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child:
                            logOutWidget(), //log out function logs people from google and firebase //Text("Volunteer hours donated"),
                      ),
                      // '\$${h}',
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "\$${(snapshot.data[0][1] * animation.value).toInt().toString()}",
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text("Volunteer dollars donated"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Text("Organizations You Support"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _createOrganizationWidget(
                                context, snapshot.data[2])),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 22, bottom: 20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Text("Recent Activity"),
                        ),
                      ),

                      Column(
                          children: _createRecentActivityWidget(
                              2, snapshot.data[0][0], snapshot.data[0][4])),

                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GestureDetector(
                          onTap: () {
                            Provider.of<MainScreenViewModel>(this.context,
                                    listen: false)
                                .setWidget(RecentActivityScreen(
                              list: snapshot.data[0][0],
                              URLList: snapshot.data[0][4],
                            ));
                          },
                          child: Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text("More",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF0000FF))),
                              ),
                              SvgPicture.asset(
                                "assets/svg/arrow_right.svg",
                                width: 13,
                                height: 13,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            const Text(
                              "What you’ve done",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Expanded(child: SizedBox()),
                            GestureDetector(
                                onTap: () {
                                  Provider.of<MainScreenViewModel>(this.context,
                                          listen: false)
                                      .setWidget(const PerformanceScreen());
                                },
                                child: const Text(
                                  "See Performance",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF0000FF)),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            const Text("Donated"),
                            const Expanded(child: SizedBox()),
                            Text(
                              "\$${(snapshot.data[0][2] * animation.value).toInt().toString()}",
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          children: [
                            const Text("Participated Event"),
                            const Expanded(child: SizedBox()),
                            Text(snapshot.data[0][3].toString())
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
          }
        }));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
