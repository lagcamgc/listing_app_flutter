class SocialNetwork {
    late int socialNetworkId;
    late int entitiesSocialNetworksId;
    late String url;
    late String icon;
    late String name;

    SocialNetwork(
        {required this.socialNetworkId,
            required this.entitiesSocialNetworksId,
            required this.url,
            required this.icon,
            required this.name});

    Map toJson() => {
      'socialNetworkId': socialNetworkId,
      'entitiesSocialNetworksId': entitiesSocialNetworksId,
      'url': url,
      'icon': icon,
      'name': name
    };
}