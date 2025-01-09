import 'picture.dart';
import 'address.dart';
import 'phone.dart';
import 'social_network.dart';
class Item {
    final int entityId;
    int fkTypeId;
    String ownerId;
    String title;
    String description;
    final int showPrice;
    String price;
    final int showPhones;
    final int showAddresses;
    final int showSocialNetworks;
    List<Picture> pictures;
    List<Address> addresses;
    List<Phone> phones;
    List<SocialNetwork> socialNetworks;

    Item(
        {required this.entityId,
            required this.fkTypeId,
            this.ownerId = "",
            required this.title,
            required this.description,
            required this.showPrice,
            required this.price,
            required this.showPhones,
            required this.showAddresses,
            required this.showSocialNetworks,
            required this.pictures,
            required this.addresses,
            required this.phones,
            required this.socialNetworks});
    Map toJson() {
      //
      List<Map>? addresses = this.addresses != null
          ? this.addresses.map((i) => i.toJson()).toList()
          : null;

      List<Map>? phones = this.phones != null
          ? this.phones.map((i) => i.toJson()).toList()
          : null;

      List<Map>? socialNetworks = this.socialNetworks != null
          ? this.socialNetworks.map((i) => i.toJson()).toList()
          : null;

      List<Map>? pictures = this.pictures != null
          ? this.pictures.map((i) => i.toJson()).toList()
          : null;

      return {
        'entityId': entityId,
        'fkTypeId': fkTypeId,
        'title': title,
        'description': description,
        'showPrice': showPrice,
        'price': price,
        'showPhones': showPhones,
        'showAddresses': showAddresses,
        'showSocialNetworks': showSocialNetworks,
        'pictures': pictures,
        'addresses': addresses,
        'phones': phones,
        'socialNetworks': socialNetworks
      };
    }
}