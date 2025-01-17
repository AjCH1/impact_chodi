import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chodi_app/models/event.dart';
import 'package:flutter_chodi_app/models/favorite.dart';
import 'package:flutter_chodi_app/screens/calendar/search_event_page.dart';
import 'package:flutter_chodi_app/screens/foryou/search_page.dart';
import 'package:r_calendar/r_calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/nonprofit_organization.dart';
import '../../services/firebase_authentication_service.dart';
import '../foryou/event_detail_page.dart';
import '../impact/impact_screen.dart';
import 'event_detail_page2.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  FirebaseService fbservice = FirebaseService();
  RCalendarController rcontroller = RCalendarController.single(
      selectedDate: DateTime.now(), isAutoSelect: true);
  int typeIndex = 0;
  bool refresh = false;

  late Stream<QuerySnapshot> allNGOs;

  late Stream<QuerySnapshot> likedEvents = FirebaseFirestore.instance
      .collection("EndUsers")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("Favorites")
      .where("isOrg", isEqualTo: false)
      .snapshots();

  late Stream userData;

  String? email = FirebaseAuth.instance.currentUser?.email;

  List<Event> eventList = [];
  List<Favorite> favoriteList = [];
  List<Event> favoritedEventList = [];
  List<Event> registeredEventList = [];

  //builds eventList
  //intended to be run during init
  //Takes a list of all NGOs as an input. While that's technically unneseccary since NGOList is a
  //global constant, it isn't intended for it to always be one, so I've given this inputs in the hopes
  //a smarter person can circumvent the need to have a global constant like that.
  buildEventList(List<NonProfitOrg> orgList) {
    //print(NGOList);
  }

  @override
  void initState() {
    super.initState();
    rcontroller.addListener(() {
      setState(() {
        rcontroller = RCalendarController.single(
            selectedDate:
                rcontroller.selectedDate); //change selected date on Agenda
      });
    });
    userData = FirebaseFirestore.instance
        .collection("EndUsers")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();

    //buildEventList(NGOList) ;
  }

/*  //Stream<QuerySnapshot> NGOS

  }*/

  _clearLists() {
    eventList.clear();
    registeredEventList.clear();
    favoritedEventList.clear();
  }

  showDetailDialog(int index) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              height: 400,
              color: Colors.grey.shade100,
              margin: const EdgeInsets.only(top: 60, bottom: 60),
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.keyboard_arrow_down, size: 30)),
                  const SizedBox(height: 10),
                  Text(registeredEventList[index].orgName),
                  const SizedBox(height: 15),
                  Text(registeredEventList[index].name,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 15),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/qrcode.png',
                        width: 110), //QR CODE FUNCTIONALITY
                  ),
                  const SizedBox(height: 15),
                  Text(registeredEventList[index].eventType),
                  const SizedBox(height: 10),
                  const Text(
                    'Thi Nguyen',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 15),
                  const Text('Ticket/Seating'),
                  const SizedBox(height: 10),
                  const Text(
                    'General',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        '${DateFormat('MMMM dd, yyyy').format(registeredEventList[index].startTime.toDate().toLocal())} - ${DateFormat('MMMM dd, yyyy').format(registeredEventList[index].endTime.toDate().toLocal())}'),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Time',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        '${DateFormat('EEEE,').add_jm().format(registeredEventList[index].startTime.toDate().toLocal())} - ${DateFormat('EEEE,').add_jm().format(registeredEventList[index].endTime.toDate().toLocal())}'),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: registeredEventList[index].city == ''
                        ? Text(registeredEventList[index].city)
                        : const Text("No address specified"),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        '${registeredEventList[index].city}, ${registeredEventList[index].state} ${registeredEventList[index].zip} ${registeredEventList[index].country}'),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Map'),
                  ),
                  const SizedBox(height: 15),
                ],
              )));
        });
  }

  showDateDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Material(
              color: Colors.transparent,
              child: Container(
                  margin: const EdgeInsets.only(top: 100, bottom: 10),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child:
                              const Icon(Icons.keyboard_arrow_down, size: 30)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.transparent,
                          ),
                          Text('Agenda', style: TextStyle(fontSize: 28)),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        alignment: Alignment.center,
                        child: RCalendarWidget(
                          controller: rcontroller,
                          customWidget: DefaultRCalendarCustomWidget(),
                          firstDate: DateTime(2022, 1, 1),
                          lastDate: DateTime(DateTime.now().year + 1, 1, 1),
                        ),
                      ),
                    ],
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection("Events (User)").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Container();
          } else {
            _clearLists();
            //add each of these events to the eventList
            for (var i in snapshot.data!.docs) {
              eventList.add(Event.fromFirestore(i));
            }
          }

          return StreamBuilder(
              stream: likedEvents,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Container();
                } else {
                  favoriteList.clear();

                  //make a list of all the favorites
                  for (var i in snapshot.data!.docs) {
                    favoriteList.add(Favorite.fromFirestore(i));
                  }

                  //iterate through the list of all favorites, and find all of the favorites which
                  //are events, rather than orgs. Add those to the favorited events list
                  for (int i = 0; i < favoriteList.length; i++) {
                    if (!favoriteList[i].isOrg) {
                      for (int i = 0; i < eventList.length; i++) {
                        if (eventList[i].eventID == favoriteList[i].eventCode) {
                          favoritedEventList.add(eventList[i]);
                        }
                      }
                    }
                  }

                  //iterate through the list of all events, checking for events which have the user on their
                  //attendee list. Add those events to the registeredEventList
                  for (int i = 0; i < eventList.length; i++) {
                    for (int j = 0; j < eventList[i].attendees.length; j++) {
                      if (eventList[i].attendees.containsValue(email)) {
                        if (rcontroller.selectedDate!
                            .isBefore(eventList[i].endTime.toDate())) {
                          registeredEventList.add(eventList[i]);
                        }

                        /*
                        bool after = rcontroller.selectedDate!
                            .isAfter(eventList[i].startTime.toDate());
                        bool before = rcontroller.selectedDate!
                            .isBefore(eventList[i].endTime.toDate());
                        log(rcontroller.selectedDate.toString());
                        log(eventList[i].startTime.toDate().toString());
                        log(after.toString());
                        log(before.toString());
                        */

                        //break to prevent duplicate attendee events (according to number of attendees)
                        // from showing up

                        break;
                      }
                    }
                  }

                  //print(registeredEventList[0].imageURL.toString());
                }

                return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('C',
                            style:
                                TextStyle(fontSize: 25, color: Colors.yellow)),
                        Text('H',
                            style:
                                TextStyle(fontSize: 25, color: Colors.orange)),
                        Text('O',
                            style: TextStyle(fontSize: 25, color: Colors.red)),
                        Text('D',
                            style: TextStyle(fontSize: 25, color: Colors.blue)),
                        Text('I',
                            style: TextStyle(fontSize: 25, color: Colors.green))
                      ],
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.grey.shade400,
                    elevation: 0,
                    actions: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return search_event_page();
                            }));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.search),
                          ))
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(15),
                          child: const Text(
                            'Events',
                            style: TextStyle(color: Colors.grey, fontSize: 30),
                          )),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  typeIndex = 0;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: typeIndex == 0
                                        ? Colors.grey
                                        : Colors.grey.shade300,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: const Text('RSVP'),
                              )),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  typeIndex = 1;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: typeIndex == 1
                                        ? Colors.grey
                                        : Colors.grey.shade300,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: const Text('Likes'),
                              )),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  typeIndex = 2;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: typeIndex == 2
                                        ? Colors.grey
                                        : Colors.grey.shade300,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: const Text('Explore'),
                              ))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: buildMain())
                    ],
                  ),
                );
              });
        });
  }

  buildMain() {
    switch (typeIndex) {
      case 0:
        return buildRsvp();
      case 1:
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoritedEventList.length,
                  itemBuilder: (context, index) {
                    return buildFavoriteListWidget(index, favoritedEventList);
                  }),
            ],
          ),
        );

      case 2:
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: eventList.length == 1
                          ? Text('Displaying ' +
                              eventList.length.toString() +
                              ' event')
                          : Text('Displaying ' +
                              eventList.length.toString() +
                              ' events')),
                  const SizedBox(height: 10),
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildListWidget(index, eventList);
                  })
            ],
          ),
        );

      default:
    }
  }

  buildFavoriteListWidget(int index, List eventList) {
    return favoritedEventList.isNotEmpty
        ? StreamBuilder(
            stream: userData, //to check if registered
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container();
              } else {
                bool _isBookmark = false;
                bool _isFavoriteLikes = true; //by default

                //set default state for Bookmark
                try {
                  var _isRegistered = snapshot.data.data()["registeredFor"]
                      [eventList[index].eventID];

                  if (_isRegistered != null) {
                    _isBookmark = true;
                  }
                } catch (e) {
                  _isBookmark = false;
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return event_detail_page(
                          ngoEvent: eventList[index],
                          ngoName: eventList[index].orgName,
                          ngoEIN: eventList[index].ein,
                        );
                      }));
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                            bottom: 30, left: 30, right: 30, top: 10),
                        padding: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                //Image.asset('assets/images/fy.png', width: 120),

                                CachedNetworkImage(
                                    imageUrl: eventList[index].imageURL,
                                    width: 120),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //ideally all of the [0]'s below would become [i] or some other way to iterate through the whole list
                                    Text(eventList[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Text(eventList[index].orgName),
                                    const SizedBox(height: 5),
                                    Text(eventList[index].locationDescription),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Text(eventList[index].description)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      //Check in Firebase
                                      verifyRegistration(
                                          _isBookmark,
                                          eventList[index].totalSpace,
                                          eventList[index].attendees.length,
                                          eventList[index]);
                                    },
                                    child: _isBookmark
                                        ? const Icon(Icons.bookmark,
                                            color: Colors.yellow)
                                        : const Icon(Icons.bookmark_border)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        //Preferably remove it dynamically? The event cannot be removed right away
                                        //when _isFavoriteLikes is clicked
                                        _isFavoriteLikes = !_isFavoriteLikes;

                                        if (_isFavoriteLikes) {
                                          //add to firebase
                                          fbservice.addUserFavoriteEvent(
                                              eventList[index].ein,
                                              eventList[index].eventID);

                                          //add to EndUsers subcollection
                                          fbservice
                                              .addUserFavoriteEventSubcollection(
                                                  eventList[index].ein,
                                                  eventList[index].eventID);
                                        } else {
                                          //remove from firebase
                                          fbservice.removeUserFavoriteEvent(
                                              eventList[index].eventID);

                                          //add to EndUsesr subcollection
                                          fbservice
                                              .removeUserFavoriteEventSubcollection(
                                                  eventList[index].eventID);
                                        }
                                      });
                                    },
                                    child: _isFavoriteLikes
                                        ? const Icon(Icons.favorite,
                                            color: Colors.red)
                                        : const Icon(Icons.favorite_border)),
                                const SizedBox(width: 10),
                              ],
                            )
                          ],
                        )));
              }
            })
        : const Text("");
  }

  buildListWidget(int index, List eventList) {
    return eventList.isNotEmpty
        ? StreamBuilder(
            stream: userData, //to check if registered
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container();
              } else {
                bool _isBookmark = false;
                bool _isFavoriteLikes = true; //by default

                //set default state for Bookmark
                try {
                  var _isRegistered = snapshot.data.data()["registeredFor"]
                      [eventList[index].eventID];

                  if (_isRegistered != null) {
                    _isBookmark = true;
                  }
                } catch (e) {
                  _isBookmark = false;
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return event_detail_page(
                          ngoEvent: eventList[index],
                          ngoName: eventList[index].orgName,
                          ngoEIN: eventList[index].ein,
                        );
                      }));
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                            bottom: 30, left: 30, right: 30, top: 10),
                        padding: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                //Image.asset('assets/images/fy.png', width: 120),

                                CachedNetworkImage(
                                    imageUrl: eventList[index].imageURL,
                                    width: 120),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //ideally all of the [0]'s below would become [i] or some other way to iterate through the whole list
                                    Text(eventList[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Text(eventList[index].orgName),
                                    const SizedBox(height: 5),
                                    Text(eventList[index].locationDescription),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Text(eventList[index].description)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      //Check in Firebase
                                      verifyRegistration(
                                          _isBookmark,
                                          eventList[index].totalSpace,
                                          eventList[index].attendees.length,
                                          eventList[index]);
                                    },
                                    child: _isBookmark
                                        ? const Icon(Icons.bookmark,
                                            color: Colors.yellow)
                                        : const Icon(Icons.bookmark_border)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        //Preferably remove it dynamically? The event cannot be removed right away
                                        //when _isFavoriteLikes is clicked
                                        _isFavoriteLikes = !_isFavoriteLikes;

                                        if (_isFavoriteLikes) {
                                          //add to firebase
                                          fbservice.addUserFavoriteEvent(
                                              eventList[index].ein,
                                              eventList[index].eventID);

                                          //add to EndUsers subcollection
                                          fbservice
                                              .addUserFavoriteEventSubcollection(
                                                  eventList[index].ein,
                                                  eventList[index].eventID);
                                        } else {
                                          //remove from firebase
                                          fbservice.removeUserFavoriteEvent(
                                              eventList[index].eventID);

                                          //add to EndUsesr subcollection
                                          fbservice
                                              .removeUserFavoriteEventSubcollection(
                                                  eventList[index].eventID);
                                        }
                                      });
                                    },
                                    child: _isFavoriteLikes
                                        ? const Icon(Icons.favorite,
                                            color: Colors.red)
                                        : const Icon(Icons.favorite_border)),
                                const SizedBox(width: 10),
                              ],
                            )
                          ],
                        )));
              }
            })
        : const Text("");
  }

/*
  buildExplore() {
    bool _isOwnBookmark = false;
    bool _isFavoriteExplore = false;

    //check in Firebase if it has been favorited
    if (_isFavoriteExplore == false) {
      _isFavoriteExplore = true;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return event_detail_page2();
        }));
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin:
              const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 10),
          padding: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/images/fy.png', width: 120),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventList[0].name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(eventList[0].orgName),
                      const SizedBox(height: 5),
                      Text(eventList[0].locationDescription),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(eventList[0].description)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 20),
                  const Text('1234 mi'),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                      onTap: () {
                        //showTipDialog(_isBookmark);

                        log(_isOwnBookmark.toString());
                        setState(() {
                          _isOwnBookmark = !_isOwnBookmark;
                        });
                      },
                      child: _isOwnBookmark
                          ? const Icon(Icons.bookmark, color: Colors.yellow)
                          : const Icon(Icons.bookmark_border)),
                  const SizedBox(width: 10),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFavoriteExplore = !_isFavoriteExplore;
                        });
                      },
                      child: _isFavoriteExplore
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(Icons.favorite_border)),
                  const SizedBox(width: 10),
                ],
              )
            ],
          )),
    );
  }
*/
  buildRsvp() {
    return Column(
      children: [
        GestureDetector(
            onTap: () => showDateDialog(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 45,
              color: Colors.orange.shade200,
              alignment: Alignment.center,
              child: const Text('Agenda',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            )),
        Container(
            padding: const EdgeInsets.all(15),
            child: Text(
              'Displaying ' +
                  registeredEventList.length.toString() +
                  ' registered events on ' +
                  DateFormat('MMMM dd')
                      .format(rcontroller.selectedDate!.toLocal()),
              style: const TextStyle(color: Colors.grey),
            )),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //横轴元素个数
                  crossAxisCount: 2,
                  //纵轴间距
                  mainAxisSpacing: 20.0,
                  //横轴间距
                  crossAxisSpacing: 20.0,
                  //子组件宽高长度比例
                  childAspectRatio: 0.8),
              itemBuilder: (context, index) {
                return buildGridWidget(index);
              },
              itemCount: registeredEventList.length),
        ))
      ],
    );
  }

  //may want to turn into a string that takes in a List<Event> (ie. registeredEventsList)
  //and builds items for every item on the list
  //for now I'll just update to take from first index in the list
  buildGridWidget(int index) {
    return GestureDetector(
        onTap: () => showDetailDialog(index),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(registeredEventList[index].name,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(DateFormat('MMMM dd yyyy,').add_jm().format(
                  registeredEventList[index].startTime.toDate().toLocal())),
              const SizedBox(height: 8),
              Text(
                  "${registeredEventList[index].city}, ${registeredEventList[index].state}\n"),
              const SizedBox(height: 15),
              Container(
                  alignment: Alignment.center,
                  child: CachedNetworkImage(
                      imageUrl: registeredEventList[index].imageURL,
                      width: 100)),
            ],
          ),
        ));
  }

  /*
  showTipDialog(bool isBookmark) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration'),
            content: const Text(
                'There are 50 spaces available. Would you like register?'),
            actions: [
              GestureDetector(
                onTap: () => Navigator.pop(context, 1),
                child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(3),
                    child: const Text('Yes',
                        style: TextStyle(color: Colors.blue))),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                    padding: EdgeInsets.all(3),
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.blue))),
              )
            ],
          );
        });
  }
*/

  //check Registration
  verifyRegistration(
      var _isBookmark, var totalSpace, var attendeeSpace, Event ngoEvent) {
    _isBookmark == true // Check if user has already registered for the event
        ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Registration'),
                content: const Text(
                    'You are already registered for the event. Would you like to unregister?'),
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, 1),
                    child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.all(3),
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.blue))),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.blue))),
                  )
                ],
              );
            }).then((value) {
            if (value == 1) {
              //remove from firebase

              fbservice.unregisterForEvent(
                ngoEvent.eventID,
                ngoEvent.ein,
              );
              setState(() {
                _isBookmark = false;
              });
            }
          })
        : totalSpace >
                attendeeSpace //User is not registered and space is available
            ? showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Registration'),
                    content: ngoEvent.returnAvailableSpace() > 1
                        ? Text(
                            'There are ${ngoEvent.returnAvailableSpace()} spaces available.\nWould you like to register?')
                        : Text(
                            'There is ${ngoEvent.returnAvailableSpace()} space available.\nWould you like to register?'),
                    actions: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, 1),
                        child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(3),
                            child: const Text('Yes',
                                style: TextStyle(color: Colors.blue))),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.blue))),
                      )
                    ],
                  );
                }).then((value) {
                if (value == 1) {
                  //add to firebase

                  fbservice.registerForEvent(
                    ngoEvent.eventID,
                    ngoEvent.ein,
                  );
                  setState(() {
                    _isBookmark = true;
                  });
                }
              })
            : showDialog(
                //no space is available
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text('Registration'),
                    content:
                        Text('Sorry! There are currently no spaces available.'),
                  );
                });
  }
}
