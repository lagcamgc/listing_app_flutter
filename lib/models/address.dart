class Address {
    late int addressId;
    late String description;

    Address({required this.addressId, required this.description});

    Map toJson() => {'addressId': addressId, 'description': description};
}