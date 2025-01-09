import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dynamic_fa_icons/dynamic_fa_icons.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../url.dart';
import '../colors.dart';
import '../models/type.dart';
import '../models/item.dart';

import '../models/picture.dart';
import '../models/address.dart';
import '../models/phone.dart';
import '../models/social_network.dart';

late String currentEntityId;
late List<String> carouselString = [];
late Item globalItem;
String idRetrievedPreviously = "";
List<Type> typesList = [];
Type actualType = const Type(
    id: 0,
    name: "",
    icon: "",
    hasPrice: 0,
    hasPhones: 0,
    hasAddresses: 0,
    hasSocialNetworks: 0);

class DetailScreen extends StatefulWidget {
  String id;
  DetailScreen({Key? key, required this.id}) : super(key: key);
  @override
  State<DetailScreen> createState() => _DetailScreen();
}

class _DetailScreen extends State<DetailScreen> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    currentEntityId = widget.id;
    idRetrievedPreviously = "";
    super.initState();
  }

  Future fetchEntityInfo() async {
    try {
      if (idRetrievedPreviously != currentEntityId) {
        idRetrievedPreviously = currentEntityId;
        carouselString = [];
        late Item itemToShow;
        late List<Picture> pictureList = [];
        late List<Address> addressList = [];
        late List<Phone> phoneList = [];
        late List<SocialNetwork> socialNetworkList = [];
        final response = await http.get(
            Uri.parse(Url.API_URL + '/getEntityById?id=' + currentEntityId));
        if (response.statusCode == 200) {
          Map decoded = jsonDecode(response.body);
          Map decodedData = decoded['data'];
          if (decodedData['show_phones'] == 1) {
            // for each one of them insert in the list
            for (var row in decodedData['phones']) {
              Phone tempPhone =
                  Phone(phoneId: row['phone_id'], number: row['number']);
              phoneList.add(tempPhone);
            }
          }
          if (decodedData['show_addresses'] == 1) {
            // for each one of them insert in the list
            for (var row in decodedData['addresses']) {
              Address tempAddress = Address(
                  addressId: row['address_id'],
                  description: row['description']);
              addressList.add(tempAddress);
            }
          }
          if (decodedData['show_social_networks'] == 1 &&
              decodedData['social_networks'] != null) {
            // for each one of them insert in the list
            for (var row in decodedData['social_networks']) {
              SocialNetwork tempSocialNetwork = SocialNetwork(
                  entitiesSocialNetworksId: row['entities_social_networks_id'],
                  socialNetworkId: row['social_network_id'],
                  url: row['url'],
                  icon: row['icon'],
                  name: row['name']);
              socialNetworkList.add(tempSocialNetwork);
            }
          }
          // for each one of them insert in the list
          for (var row in decodedData['pictures']) {
            Picture tempPicture =
                Picture(pictureId: row['picture_id'], url: row['url']);
            pictureList.add(tempPicture);
            carouselString.add(tempPicture.url);
          }
          itemToShow = Item(
              entityId: decodedData['entity_id'],
              fkTypeId: decodedData['fktypes'],
              ownerId: decodedData['uid'],
              title: decodedData['title'],
              description: decodedData['description'],
              showPrice: decodedData['show_price'],
              price: decodedData['price'],
              showPhones: decodedData['show_phones'],
              showAddresses: decodedData['show_addresses'],
              showSocialNetworks: decodedData['show_social_networks'],
              pictures: pictureList,
              addresses: addressList,
              phones: phoneList,
              socialNetworks: socialNetworkList);
          setState(() {
            globalItem = itemToShow;
          });
          await fetchTypesList();

        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception('Failed to load fetchEntityInfo');
        }
      } else {
        return globalItem;
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchTypesList() async {
    try {
      // if (isTypesFetched == false) {
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
          // get the initial item of the list to make it the default selection
          // if (listOfTypes.length > 0) {
          //   initialItem.fkTypeId = listOfTypes[0].id;
          // } else {
          //   throw Exception(
          //       "There is not types loaded in the database");
          // }
          final tempType = listOfTypes.firstWhere((element) => element.id == globalItem.fkTypeId);
          setState(() {
            actualType = tempType;
          });
          typesList = listOfTypes;
          // isTypesFetched = true;
          return listOfTypes;
        } else {
          throw Exception(
              "Can't retrieve correct information from the server fetchTypesList");
        }
      // } else {
      //   return typesList;
      // }
    } catch (e) {
      print(e);
      // if (!dialogBeingShowed)
      //   _showMyDialog(
      //       "Can't retrieve correct information from the server", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: fetchEntityInfo(),
      builder: (context, AsyncSnapshot typeSnap) {
        if (typeSnap.connectionState == ConnectionState.none &&
                typeSnap.hasData == null ||
            typeSnap.data == null
        ) {
          return Container();
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              // carousel and buttons
              Stack(alignment: Alignment.center, children: [
                Container(
                    height: screenHeight * 0.45,
                    color: AppColors.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 40.0),
                      child: Stack(
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.3,
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                        aspectRatio: 1.5,
                                        autoPlay: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        }),
                                    items: carouselString
                                        .map<Widget>(
                                            (item) => Image.network(item))
                                        .toList(),
                                    carouselController: _controller,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: carouselString
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return GestureDetector(
                                      onTap: () =>
                                          _controller.animateToPage(entry.key),
                                      child: Container(
                                        width: 12.0,
                                        height: 12.0,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 4.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                (Theme.of(context).brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withOpacity(
                                                        entry.key == _current
                                                            ? 0.9
                                                            : 0.4)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.push('/menu');
                                },
                                child: Icon(FontAwesomeIcons.arrowLeft,
                                    color: AppColors.primaryColor),
                              ),
                              InkWell(
                                onTap: () async {
                                  Share.share(Uri.parse(Url.API_URL +
                                      "/detail/" +
                                      currentEntityId.toString()).toString());
                                },
                                child: Icon(FontAwesomeIcons.share,
                                    color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                          // only show if this user is the owner of the post
                          if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser?.uid == globalItem.ownerId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        // updating the state
                                        idRetrievedPreviously = "";
                                      });
                                      context.push('/insert/' +
                                          currentEntityId.toString());
                                    },
                                    child: Icon(FontAwesomeIcons.edit,
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    )),
              ]),
              // first row with title, price and description
              Material(
                color: AppColors.backgroundColor,
                child: Container(
                  color: AppColors.whiteTransparent10Color,
                  width: screenWidth,
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              typeSnap.data.title,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      if (globalItem.showPrice == 1 && actualType.hasPrice == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${typeSnap.data.price} \$',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                typeSnap.data.description,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ])
                    ],
                  ),
                ),
              ),
              // row with contact info
              Divider(
                color: AppColors.backgroundColor,
                height: 1,
              ),
              if (globalItem.showPhones == 1 && actualType?.hasPhones == 1)
              Expanded(
                  child: Container(
                      color: AppColors.whiteTransparent10Color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Contact:"),
                            Expanded(
                                // iterate over social media and check if phone comes in detail to show and call/sms
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: typeSnap.data.phones.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(FontAwesomeIcons.phone,
                                                color: AppColors.primaryColor),
                                            color: Colors.black,
                                            onPressed: () async {
                                              final Uri _phoneUri = Uri(
                                                  scheme: "tel",
                                                  path: "+" +
                                                      typeSnap
                                                          .data
                                                          .phones[index]
                                                          .number);
                                              if (!await launchUrl(_phoneUri)) {
                                                throw 'Could not launch $_phoneUri';
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(FontAwesomeIcons.sms,
                                                color: AppColors.primaryColor),
                                            color: Colors.black,
                                            onPressed: () async {
                                              final Uri smsLaunchUri = Uri(
                                                scheme: 'sms',
                                                path: "+" +
                                                    typeSnap.data.phones[index]
                                                        .number,
                                                queryParameters: <String,
                                                    String>{
                                                  'body': "",
                                                },
                                              );
                                              if (!await launchUrl(
                                                  smsLaunchUri)) {
                                                throw 'Could not launch $smsLaunchUri';
                                              }
                                            },
                                          ),
                                          Text("+" +
                                              typeSnap
                                                  .data.phones[index].number)
                                        ],
                                      );
                                    })),
                          ],
                        ),
                      ))),
              Divider(
                color: AppColors.backgroundColor,
                height: 1,
              ),
              // row with addresses
              if (globalItem.showAddresses == 1 && actualType?.hasAddresses == 1)
              Expanded(
                  child: Container(
                      color: AppColors.whiteTransparent10Color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Addresses:"),
                            Expanded(
                                // iterate over social media and check if phone comes in detail to show and call/sms
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: typeSnap.data.addresses.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                                FontAwesomeIcons.addressBook,
                                                color: AppColors.primaryColor),
                                            color: Colors.black,
                                            onPressed: () async {},
                                          ),
                                          Text("" +
                                              typeSnap.data.addresses[index]
                                                  .description)
                                        ],
                                      );
                                    })),
                          ],
                        ),
                      ))),
              // row with social networks
              Container(
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (globalItem.showSocialNetworks == 1 && actualType?.hasSocialNetworks == 1)
                      Expanded(
                          // iterate over social media and check if phone comes in detail to show and call/sms
                          child: Center(
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: typeSnap.data.socialNetworks.length,
                            itemBuilder: (context, index) {
                              return typeSnap.data.socialNetworks[index].url != "" ? IconButton(
                                icon: FaIcon(DynamicFaIcons.getIconFromName(
                                    typeSnap.data.socialNetworks[index].icon)),
                                color: AppColors.primaryColor,
                                onPressed: () async {
                                  var url =
                                      typeSnap.data.socialNetworks[index].url;
                                  final Uri _url = Uri.parse(url);
                                  if (!await launchUrl(_url)) {
                                    throw 'Could not launch $_url';
                                  }
                                },
                              ) : SizedBox();
                            }),
                      ))
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
