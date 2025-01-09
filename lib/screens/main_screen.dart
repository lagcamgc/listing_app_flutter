import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_fa_icons/dynamic_fa_icons.dart';

import '../url.dart';
import '../colors.dart';
import '../models/type.dart';
import '../models/item_for_listing.dart';

bool typesRetrieved = true;
// selected type listing
int selectedTypeIconIndex = -1;
bool showPrice = true;
// entities to be showed, its filled depending of selected type
List<ItemForListing> listOfEntities = [];
List<ItemForListing> listOfEntitiesForced = [];
// flag for dialog
bool dialogBeingShowed = false;



class MainScreen extends StatefulWidget {
  MainScreen({Key? key, required this.menuCallback}) : super(key: key);

  VoidCallback? menuCallback;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Type>> futureType;

  @override
  void initState() {
    super.initState();
  }

  // fetch the list of categories, those are dynamic
  Future fetchTypesList() async {
    try {
      List<Type> listOfTypes = [];

      final response = await http.get(Uri.parse(Url.API_URL + '/getTypes'));

      if (response.statusCode == 200) {
        Map decoded = jsonDecode(response.body);
        for (var row in decoded['data']) {
          listOfTypes.add(Type(
              id: row['id'],
              name: row['name'],
              icon: row['icon'],
              hasPrice: row['has_price'],
              hasPhones: row['has_phones'],
              hasAddresses: row['has_addresses'],
              hasSocialNetworks: row['has_social_networks']));
        }

        // if it is the first time loading select first tile by default and load
        if (selectedTypeIconIndex == -1) {
          selectedTypeIconIndex = listOfTypes[0].id;
          showPrice = listOfTypes[0].hasPrice == 1 ? true : false;
          fetchEntitiesByType();
        }
        typesRetrieved = true;
        return listOfTypes;
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      print("e");
      print(e);
      typesRetrieved = false;
      if (!dialogBeingShowed)
        _showMyDialog("Can't retrieve correct information from the server");
    }
  }

  Future<List<ItemForListing>> fetchEntitiesByType() async {
    try {
      // needs to be filled after habing the list of types
      if (selectedTypeIconIndex != -1) {
        final response = await http.get(Uri.parse(Url.API_URL +
            '/getEntitiesByType?idType=' +
            (selectedTypeIconIndex).toString()));

        if (response.statusCode == 200) {
          listOfEntities.clear();
          Map decoded = jsonDecode(response.body);
          for (var row in decoded['data']) {
            listOfEntities.add(ItemForListing(
                entityId: row['entity_id'],
                title: row['title'],
                description: row['description'],
                showPrice: row['show_price'],
                price: row['price'],
                pictureId: row['picture_id'],
                imageUrl: row['url']));
          }
          setState(() {
            listOfEntitiesForced = listOfEntities;
          });
          typesRetrieved = true;
          return listOfEntities;
        } else {
          throw Exception('Failed to load listing');
        }
      } else {
        return listOfEntities;
      }
    } catch (e) {
      print(e);
      typesRetrieved = false;
      if (!dialogBeingShowed)
        _showMyDialog("Can't retrieve correct information from the server");
      return listOfEntities;
    }
  }

  Future<void> _showMyDialog(String textToShow) async {
    dialogBeingShowed = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // force tap on the button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textToShow),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                dialogBeingShowed = false;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // list of tiles for the types
  Widget typeWidget() {
    return FutureBuilder(
      future: fetchTypesList(),
      builder: (context, AsyncSnapshot typeSnap) {
        if (typeSnap.connectionState == ConnectionState.none &&
                typeSnap.hasData == null ||
            typeSnap.data?.length == null) {
          return Container();
        }
        return ListView.builder(
          padding: EdgeInsets.only(left: 10.0),
          scrollDirection: Axis.horizontal,
          itemCount: typeSnap.data.length,
          itemBuilder: (context, index) {
            Type type = typeSnap.data[index];
            return Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedTypeIconIndex = type.id;
                        showPrice = type.hasPrice == 1 ? true : false;
                        fetchEntitiesByType();
                      });
                    },
                    child: Material(
                        color: selectedTypeIconIndex == type.id
                            ? AppColors.primaryColor
                            : AppColors.backgroundColor,
                        elevation: 8.0,
                        borderRadius: BorderRadius.circular(20.0),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: IconButton(
                            icon: FaIcon(
                                DynamicFaIcons.getIconFromName(type.icon)),
                            color: selectedTypeIconIndex == type.id
                                ? Colors.white
                                : AppColors.primaryColor,
                            onPressed: () {
                              setState(() {
                                selectedTypeIconIndex = type.id;
                                showPrice = type.hasPrice == 1 ? true : false;
                                fetchEntitiesByType();
                              });
                            },
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    type.name,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  watchRouteChange() {
    // TODO september
    // if (GoRouterState.of(context).fullPath.contains("/menu")) {
      // fetchEntitiesByType();
      // GoRouterState.of(context).removeListener(watchRouteChange); // remove listener
    // }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: AppColors.backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          children: <Widget>[
            // header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                      child: Icon(FontAwesomeIcons.bars),
                      onTap: widget.menuCallback?.call),
                  if (FirebaseAuth.instance.currentUser != null && typesRetrieved)
                    Column(
                      children: [
                        // create new entity
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.plus),
                          color: AppColors.primaryColor,
                          onPressed: () async {
                            // go the creation screen
                            context.push('/insert/' + 0.toString());
                            // GoRouterState.of(context).addListener(watchRouteChange);
                            fetchEntitiesByType();
                          },
                        ),
                        Text("Create publication")
                      ],
                    ),
                  CircleAvatar(
                      radius: 20.0,
                      child: FirebaseAuth.instance.currentUser != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(FirebaseAuth.instance
                                  .currentUser!.providerData[0].photoURL
                                  .toString()))
                          : Icon(FontAwesomeIcons.user, color: Colors.white))
                ],
              ),
            ),

            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: AppColors.whiteTransparent20Color),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            height: 120.0,
                            child: typeWidget(),
                          ),
                        ),
                        if (listOfEntitiesForced.length > 0)
                          Expanded(
                              child: ListView.builder(
                                  itemCount: listOfEntities.length,
                                  itemBuilder: (context, index) {
                                    ItemForListing item = listOfEntities[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        // Go to the detail
                                        context.push('/detail/' +
                                            listOfEntities[index]
                                                .entityId
                                                .toString());
                                        fetchEntitiesByType();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 28.0,
                                            right: 20.0,
                                            left: 10),
                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            Material(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              elevation: 4.0,
                                              color:AppColors.cardsMainScreen,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: deviceWidth * 0.43,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  // Text(
                                                                  item.title,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20.0,
                                                                      color: AppColors.primaryColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10.0,
                                                          ),
                                                          if (item.showPrice == 1 && showPrice)
                                                          Text(
                                                            '\$ ${item.price}',
                                                            style: TextStyle(
                                                              fontSize: 22.0,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Stack(children: [
                                              Container(
                                                height: 150.0,
                                                width: deviceWidth * 0.4,
                                                margin: const EdgeInsets.only(
                                                    left: 0),
                                                child: FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: Image.network(
                                                          item.imageUrl)),
                                                ),
                                              ),
                                            ])
                                          ],
                                        ),
                                      ),
                                    );
                                  }))
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
