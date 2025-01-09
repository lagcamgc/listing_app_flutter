class Phone {
    late int phoneId;
    late String number;

    Phone({required this.phoneId, required this.number});

    Map toJson() => {'phoneId': phoneId, 'number': number};
}