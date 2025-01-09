import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_fa_icons/dynamic_fa_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../url.dart';
import '../colors.dart';

import '../models/item.dart';
import '../models/picture.dart';
import '../models/address.dart';
import '../models/type.dart';
import '../models/phone.dart';
import '../models/social_network.dart';
// flag for dialog
bool dialogBeingShowed = false;
late String currentEntityId;
List images = [];
List<Picture> previousImages = [];
bool previousImagesRetrieved = false;
late String idRetrievedPreviously = "";
List<Type> typesList = [];
bool isTypesFetched = false;
List<SocialNetwork> socialNetworksList = [];
bool isSocialNetworksFetched = false;

Item initialItem = Item(
    entityId: 0,
    fkTypeId: 0,
    ownerId: "",
    title: "",
    description: "",
    showPrice: 1,
    price: "",
    showPhones: 1,
    showAddresses: 1,
    showSocialNetworks: 1,
    pictures: [],
    addresses: [Address(addressId: 0, description: "")],
    phones: [Phone(phoneId: 0, number: "")],
    socialNetworks: []);

class InsertAndEditScreen extends StatefulWidget {
  String id;

  // InsertAndEditScreen({Key? key, required this.animal}) : super(key: key);
  InsertAndEditScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<InsertAndEditScreen> createState() => _InsertAndEditScreen();
}

class _InsertAndEditScreen extends State<InsertAndEditScreen> {
  String dropdownValue = "1";
  final _formKey = GlobalKey<FormBuilderState>();
  late XFile image;

  @override
  void initState() {
    // reset at init, if it is an edit it will be overwritten later
    currentEntityId = widget.id;
    isTypesFetched = false;
    isSocialNetworksFetched = false;
    idRetrievedPreviously = "";
    images = [];
    initialItem = Item(
        entityId: 0,
        fkTypeId: 0,
        ownerId: "",
        title: "",
        description: "",
        showPrice: 1,
        price: "",
        showPhones: 1,
        showAddresses: 1,
        showSocialNetworks: 1,
        pictures: [],
        addresses: [Address(addressId: 0, description: "")],
        phones: [Phone(phoneId: 0, number: "")],
        socialNetworks: []);

    super.initState();
  }

  Future fetchSocialNetworks() async {
    try {
      if (isSocialNetworksFetched == false) {
        late List<SocialNetwork> futureSocialNetworkTemp = [];
        final response =
            await http.get(Uri.parse(Url.API_URL + '/getSocialNetworks'));

        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          Map decoded = jsonDecode(response.body);
          for (var row in decoded['data']) {
            futureSocialNetworkTemp.add(SocialNetwork(
                socialNetworkId: row['id'],
                entitiesSocialNetworksId: 0,
                url: "",
                icon: row['icon'],
                name: row['name']));
          }
          socialNetworksList = futureSocialNetworkTemp;
          isSocialNetworksFetched = true;
          if (initialItem.socialNetworks.length == 0)
            initialItem.socialNetworks = socialNetworksList;
          return futureSocialNetworkTemp;
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception(
              "Can't retrieve correct information from the server fetchSocialNetworks");
        }
      } else {
        return socialNetworksList;
      }
    } catch (e) {
      print(e);
      if (!dialogBeingShowed)
        _showMyDialog(
            "Can't retrieve correct information from the server", true);
    }
  }

  Future fetchTypesList() async {
    try {
      if (isTypesFetched == false) {
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
          if (listOfTypes.length > 0 && initialItem.fkTypeId == 0) {
              initialItem.fkTypeId = listOfTypes[0].id;
          } else if (listOfTypes.length == 0) {
            throw Exception(
              "There is not types loaded in the database");
          }
          typesList = listOfTypes;
          isTypesFetched = true;
          return listOfTypes;
        } else {
          throw Exception(
              "Can't retrieve correct information from the server fetchTypesList");
        }
      } else {
        return typesList;
      }
    } catch (e) {
      print(e);
      if (!dialogBeingShowed)
        _showMyDialog(
            "Can't retrieve correct information from the server", true);
    }
  }

  Future fetchEntityById() async {
    try {
      // if it is edition
      if (currentEntityId != "0" && idRetrievedPreviously != currentEntityId) {
          idRetrievedPreviously = currentEntityId;
          final response = await http.get(
              Uri.parse(Url.API_URL + '/getEntityById?id=' + currentEntityId));
          if (response.statusCode == 200) {
            Map decoded = jsonDecode(response.body);
            List<Address> tempAddresses = [];
            List<Phone> tempPhones = [];
            List<SocialNetwork> tempSocialNetworks = [];
            List<Picture> tempPictures = [];
            for (var row in decoded['data']['addresses']) {
              tempAddresses.add(Address(
                  addressId: row['address_id'],
                  description: row['description']));
            }
            for (var row in decoded['data']['phones']) {
              tempPhones
                  .add(Phone(phoneId: row['phone_id'], number: row['number']));
            }
            for (var row in decoded['data']['social_networks']) {
              tempSocialNetworks.add(SocialNetwork(
                  socialNetworkId: row['social_network_id'],
                  entitiesSocialNetworksId: row['entities_social_networks_id'],
                  url: row['url'],
                  icon: row['icon'],
                  name: row['name']));
            }
            for (var row in decoded['data']['pictures']) {
              tempPictures
                  .add(Picture(pictureId: row['picture_id'], url: row['url']));
            }
            initialItem = Item(
                entityId: int.parse(currentEntityId),
                fkTypeId: decoded['data']['fktypes'],
                ownerId: "",
                title: decoded['data']['title'],
                description: decoded['data']['description'],
                showPrice: decoded['data']['show_price'],
                price: decoded['data']['price'],
                showPhones: decoded['data']['show_phones'],
                showAddresses: decoded['data']['show_addresses'],
                showSocialNetworks: decoded['data']['show_social_networks'],
                pictures: tempPictures,
                addresses: tempAddresses,
                phones: tempPhones,
                socialNetworks: tempSocialNetworks);
            return initialItem;
          } else {
            throw Exception(
                "Can't retrieve correct information from the server fetchEntityById");
          }
      } else {
        // just being called by re rendering
        return initialItem;
      }
    } catch (e) {
      if (!dialogBeingShowed)
        _showMyDialog(
            "Can't retrieve correct information from the server fetchEntityById",
            true);
    }
  }

  Future createEntry(List listOfFiles) async {
    try {
      late http.MultipartRequest request;
      var token;
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var tokenResult = await user.getIdTokenResult();
        token = tokenResult.token;
      }
      if (currentEntityId == "0")
        request = new http.MultipartRequest(
            "POST", Uri.parse(Url.API_URL + '/insertEntity'));
      else
        request = new http.MultipartRequest(
            "POST", Uri.parse(Url.API_URL + '/editEntity'));

      Map<String, String> headers = {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: token
      };
      for (var element in listOfFiles) {
        late var bytes;
          bytes = element;
        request.files
            .add(new http.MultipartFile.fromBytes('file', bytes));
      }

      request.headers.addAll(headers);
      request.fields['jsonData'] = jsonEncode(initialItem).toString();

      var baseRequest = await request.send();
      var response = await http.Response.fromStream(baseRequest);
      if (response.statusCode == 200) {
        Map decoded = jsonDecode(response.body);
        String result = decoded['data'].toString();
        return result;
      } else {
        throw Exception('Error creating entry');
      }
    } catch (e) {
      print(e);
      if (!dialogBeingShowed) _showMyDialog("Error creating entry", true);
    }
  }

  Future<void> _showMyDialog(String textToShow, bool isError) async {
    dialogBeingShowed = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // forces user to tap ok to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textToShow),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                dialogBeingShowed = false;
                Navigator.of(context).pop();
                if (!isError) {
                  if (currentEntityId == "0") {
                    context.push('/menu');
                  } else {
                    context.push('/detail/' + currentEntityId);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 42.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // go back arrow row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      // Navigator.pop(context);
                      if (currentEntityId == "0") {
                        context.push('/menu');
                      } else {
                        context.push('/detail/' + currentEntityId);
                      }
                    },
                    child: Icon(FontAwesomeIcons.arrowLeft,
                        color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // whole content row, retrieves info if it is edition
              FutureBuilder(
                  future: fetchEntityById(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.none &&
                            snapshot.hasData == null ||
                        snapshot.data == null) {
                      return Container();
                    }
                    return FormBuilder(
                        key: _formKey,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: AppColors.cardsMainScreen),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 16.0),
                                child: Column(children: [
                                  // add images buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton.icon(
                                          onPressed: () async {
                                            final ImagePicker _picker =
                                                ImagePicker();
                                            final img = await _picker.pickImage(
                                                source: ImageSource.gallery);
                                            final bytes = await img!.readAsBytes();
                                            setState(() {
                                              images.add(bytes);
                                            });
                                          },
                                          label: const Text('Add Image'),
                                          icon: const Icon(Icons.image),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryColor,
                                          )),
                                      if (!kIsWeb)
                                        ElevatedButton.icon(
                                        onPressed: () async {
                                          final ImagePicker _picker =
                                              ImagePicker();
                                          final img = await _picker.pickImage(
                                              source: ImageSource.camera);
                                          final bytes = await img!.readAsBytes();
                                          setState(() {
                                            images.add(bytes);
                                          });
                                        },
                                        label: const Text('Add Photo'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryColor,
                                        ),
                                        icon: const Icon(
                                            Icons.camera_alt_outlined),
                                      ),
                                    ],
                                  ),
                                  // images gallery
                                  if (images.length > 0 ||
                                      initialItem.pictures.length >
                                          0) // modify this
                                    GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                      ),
                                      itemCount: (images.length +
                                              initialItem.pictures.length)
                                          .toInt(),
                                      itemBuilder: (context, index) =>
                                          Stack(children: [
                                        Container(
                                          height: screenHeight * 0.20,
                                          child: index <
                                                  initialItem.pictures.length
                                              ? // modify this
                                              Image.network(
                                                  initialItem
                                                      .pictures[index].url,
                                                  height: 250,
                                                  width: 150)
                                              : Image.memory(images[(index -
                                                              initialItem
                                                                  .pictures
                                                                  .length)
                                                          .toInt()]
                                                       ??
                                                  'assets/empty_logo.png'),
                      // Image.file(File(images[(index -
                      //     initialItem
                      //         .pictures
                      //         .length)
                      //     .toInt()]
                      //     ?.path ??
                      //     'assets/logo.png')),


                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          //child: Icon(Icons.close),
                                          child: IconButton(
                                            icon: const Icon(Icons.close),
                                            tooltip: 'Remove',
                                            onPressed: () {
                                              setState(() {
                                                if (index <
                                                    initialItem
                                                        .pictures.length) {
                                                  initialItem.pictures
                                                      .removeAt(index);
                                                } else {
                                                  images.removeAt(index -
                                                      initialItem
                                                          .pictures.length);
                                                }
                                              });
                                            },
                                          ),
                                        )
                                      ]),
                                    ),
                                  const SizedBox(height: 10),
                                  // title input
                                  FormBuilderTextField(
                                    initialValue: initialItem.title,
                                    name: 'title',
                                    style: TextStyle(color: Colors.black),
                                    cursorColor: AppColors.primaryColor,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.maxLength(127),
                                      FormBuilderValidators.minLength(5)
                                    ]),
                                    decoration: const InputDecoration(
                                      labelText: 'Enter title',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryColor
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(20.0)),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(20.0)),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      initialItem.title = val!;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  // description input
                                  FormBuilderTextField(
                                    initialValue: initialItem.description,
                                    name: 'description',
                                    style: TextStyle(color: Colors.black),
                                    cursorColor: AppColors.primaryColor,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.maxLength(1023),
                                      FormBuilderValidators.minLength(5)
                                    ]),
                                    decoration: const InputDecoration(
                                      labelText: 'Enter description',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(20.0)),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(20.0)),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      initialItem.description = val!;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  // types future request, they come from backend and depending on that the entity has some attributes or not
                                  FutureBuilder(
                                    future: fetchTypesList(),
                                    builder: (context, AsyncSnapshot typeSnap) {
                                      if (typeSnap.connectionState ==
                                                  ConnectionState.none &&
                                              typeSnap.hasData == null ||
                                          typeSnap.data?.length == null) {
                                        return Container();
                                      } else {
                                        return Container(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // types drowdown
                                                FormBuilderDropdown<String>(
                                                  initialValue: initialItem
                                                      .fkTypeId
                                                      .toString(),
                                                  name: 'type',
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  validator:
                                                      FormBuilderValidators
                                                          .compose([
                                                    FormBuilderValidators
                                                        .required(),
                                                  ]),
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Select type',
                                                    labelStyle: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: AppColors.primaryColor),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              const Radius
                                                                      .circular(
                                                                  20.0)),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              const Radius
                                                                      .circular(
                                                                  20.0)),
                                                    ),
                                                  ),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      if (newValue != null) {
                                                        initialItem.fkTypeId =
                                                            int.parse(newValue);
                                                        // find index inside array
                                                        final index = typesList.indexWhere((type) => type.id.toString() == newValue);
                                                        dropdownValue = (index + 1).toString();
                                                      }
                                                    });
                                                  },
                                                  items: typesList.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (Type value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value:
                                                          value.id.toString(),
                                                      child: Text(value.name),
                                                    );
                                                  }).toList(),
                                                ),
                                                const SizedBox(height: 10),
                                                // price input
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasPrice !=
                                                    0)
                                                  FormBuilderTextField(
                                                    initialValue:
                                                        initialItem.price,
                                                    name: 'price',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    cursorColor:
                                                        AppColors.primaryColor,
                                                    validator:
                                                        FormBuilderValidators
                                                            .compose([
                                                      FormBuilderValidators
                                                          .required(),
                                                      FormBuilderValidators
                                                          .numeric(),
                                                      FormBuilderValidators
                                                          .maxLength(44),
                                                      FormBuilderValidators
                                                          .minLength(1)
                                                    ]),
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Enter price',
                                                      labelStyle: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      focusedBorder:
                                                          const OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: AppColors.primaryColor),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(const Radius
                                                                    .circular(
                                                                20.0)),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(const Radius
                                                                    .circular(
                                                                20.0)),
                                                      ),
                                                    ),
                                                    onChanged: (val) {
                                                      initialItem.price = val!;
                                                    },
                                                  ),
                                                const SizedBox(height: 10),
                                                // phones title and button to add
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasPhones !=
                                                    0)
                                                  Row(
                                                    children: [
                                                      Text('Phones'),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add_rounded,
                                                            color: AppColors.primaryColor),
                                                        tooltip: 'Add',
                                                        onPressed: () {
                                                          setState(() {
                                                            initialItem.phones
                                                                .add(Phone(
                                                                    phoneId: 0,
                                                                    number:
                                                                        ""));
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                // phone list of inputs
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasPhones !=
                                                    0)
                                                  SingleChildScrollView(
                                                    child: ListView.separated(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount: initialItem
                                                            .phones.length,
                                                        separatorBuilder: (_,
                                                                __) =>
                                                            const SizedBox(
                                                                height: 5),
                                                        itemBuilder:
                                                            (context, index) {
                                                          return FormBuilderTextField(
                                                            initialValue:
                                                                initialItem
                                                                    .phones[
                                                                        index]
                                                                    .number,
                                                            name: "phone" +
                                                                index
                                                                    .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                            cursorColor: AppColors.primaryColor,
                                                            validator:
                                                                FormBuilderValidators
                                                                    .compose([
                                                              FormBuilderValidators
                                                                  .required(),
                                                              FormBuilderValidators
                                                                  .integer(),
                                                              FormBuilderValidators
                                                                  .maxLength(
                                                                      19),
                                                              FormBuilderValidators
                                                                  .minLength(7)
                                                            ]),
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Enter phone',
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: AppColors.primaryColor),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(const Radius
                                                                            .circular(
                                                                        20.0)),
                                                              ),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(const Radius
                                                                            .circular(
                                                                        20.0)),
                                                              ),
                                                            ),
                                                            onChanged: (val) {
                                                              initialItem
                                                                  .phones[index]
                                                                  .number = val!;
                                                            },
                                                          );
                                                        }),
                                                  ),
                                                const SizedBox(height: 10),
                                                // addresses title and button
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasAddresses !=
                                                    0)
                                                  Row(
                                                    children: [
                                                      Text('Addresses'),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add_rounded,
                                                            color: AppColors.primaryColor),
                                                        tooltip: 'Add',
                                                        onPressed: () {
                                                          setState(() {
                                                            initialItem
                                                                .addresses
                                                                .add(Address(
                                                                    addressId:
                                                                        0,
                                                                    description:
                                                                        ""));
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                // addreses list of inputs
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasAddresses !=
                                                    0)
                                                  SingleChildScrollView(
                                                      child: ListView.separated(
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemCount: initialItem
                                                              .addresses.length,
                                                          separatorBuilder: (_,
                                                                  __) =>
                                                              const SizedBox(
                                                                  height: 5),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return FormBuilderTextField(
                                                              initialValue:
                                                                  initialItem
                                                                      .addresses[
                                                                          index]
                                                                      .description,
                                                              name: "address" +
                                                                  index
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                              cursorColor: AppColors.primaryColor,
                                                              validator:
                                                                  FormBuilderValidators
                                                                      .compose([
                                                                FormBuilderValidators
                                                                    .required(),
                                                                FormBuilderValidators
                                                                    .maxLength(
                                                                        511),
                                                                FormBuilderValidators
                                                                    .minLength(
                                                                        10)
                                                              ]),
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Enter address',
                                                                labelStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                focusedBorder:
                                                                    const OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                          color:
                                                                              AppColors.primaryColor),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(const Radius
                                                                              .circular(
                                                                          20.0)),
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(const Radius
                                                                              .circular(
                                                                          20.0)),
                                                                ),
                                                              ),
                                                              onChanged: (val) {
                                                                initialItem
                                                                    .addresses[
                                                                        index]
                                                                    .description = val!;
                                                              },
                                                            );
                                                          })),
                                                const SizedBox(height: 20),
                                                // social networks title
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasSocialNetworks !=
                                                    0)
                                                  Row(
                                                    children: [
                                                      Text('Social Networks'),
                                                    ],
                                                  ),
                                                const SizedBox(width: 10),
                                                // social networks future, those come from backend
                                                if (typesList[int.parse(
                                                                dropdownValue) -
                                                            1]
                                                        .hasSocialNetworks !=
                                                    0)
                                                  FutureBuilder(
                                                    future:
                                                        fetchSocialNetworks(),
                                                    builder: (context,
                                                        AsyncSnapshot
                                                            socialSnap) {
                                                      if (socialSnap.connectionState ==
                                                                  ConnectionState
                                                                      .none &&
                                                              socialSnap
                                                                      .hasData ==
                                                                  null ||
                                                          socialSnap.data
                                                                  ?.length ==
                                                              null) {
                                                        return Container();
                                                      }
                                                      return SingleChildScrollView(
                                                          child: ListView
                                                              .separated(
                                                                  shrinkWrap:
                                                                      true,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemCount:
                                                                      socialNetworksList
                                                                          .length,
                                                                  separatorBuilder: (_,
                                                                          __) =>
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Row(
                                                                        children: [
                                                                          FaIcon(
                                                                              DynamicFaIcons.getIconFromName(socialNetworksList[index].icon),
                                                                              color: AppColors.primaryColor),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Flexible(
                                                                            child:
                                                                                FormBuilderTextField(
                                                                              initialValue: snapshot.data.socialNetworks?.firstWhere((i) => i?.socialNetworkId == socialSnap.data[index]?.socialNetworkId, orElse: () => SocialNetwork(socialNetworkId: socialSnap.data[index]?.socialNetworkId, entitiesSocialNetworksId: 0, url: "", icon: "", name: "name")).url,
                                                                              name: "socialNetwork" + index.toString(),
                                                                              style: TextStyle(color: Colors.black),
                                                                              cursorColor: AppColors.primaryColor,
                                                                              validator: FormBuilderValidators.compose([
                                                                                FormBuilderValidators.maxLength(2050),
                                                                                FormBuilderValidators.url()
                                                                              ]),
                                                                              decoration: InputDecoration(
                                                                                labelText: socialSnap.data[index].name,
                                                                                labelStyle: TextStyle(
                                                                                  color: Colors.black,
                                                                                ),
                                                                                focusedBorder: const OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: AppColors.primaryColor),
                                                                                  borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
                                                                                ),
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
                                                                                ),
                                                                              ),
                                                                              onChanged: (val) {
                                                                                final indexForElement = initialItem.socialNetworks.indexWhere((i) => i.socialNetworkId == socialSnap.data[index].socialNetworkId);
                                                                                if (indexForElement != -1)
                                                                                  initialItem.socialNetworks[indexForElement].url = val!;
                                                                                else
                                                                                  initialItem.socialNetworks.add(SocialNetwork(socialNetworkId: socialSnap.data[index]?.socialNetworkId, entitiesSocialNetworksId: 0, url: val!, icon: "", name: "name"));
                                                                              },
                                                                            ),
                                                                          )
                                                                        ]);
                                                                  }));
                                                    },
                                                  )
                                              ]),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.check),
                                    color: AppColors.primaryColor,
                                    onPressed: () async {
                                      if (images.length == 0 && initialItem.pictures.length == 0) {
                                        if (!dialogBeingShowed)
                                          _showMyDialog(
                                              "At least one image is required",
                                              true);
                                      }
                                      if (_formKey.currentState!.validate() &&
                                          (images.length > 0 || initialItem.pictures.length > 0)) {
                                        var response =
                                            await createEntry(images);
                                        if (response != null) {
                                          // inside of this there is a redirection
                                          _showMyDialog("Success", false);
                                        }
                                      }
                                    },
                                  ),
                                ]))));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
