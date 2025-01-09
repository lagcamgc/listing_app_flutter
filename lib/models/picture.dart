class Picture {
    late int pictureId;
    late String url;

    Picture({required this.pictureId, required this.url});

    Map toJson() => {'pictureId': pictureId, 'url': url};
}