// To parse this JSON data, do
//
//     final psicologia = psicologiaFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Psicologia {
  Psicologia({
    required this.version,
    required this.userComment,
    required this.homePageUrl,
    required this.feedUrl,
    required this.language,
    required this.title,
    required this.description,
    required this.icon,

  });

  final String version;
  final String userComment;
  final String homePageUrl;
  final String feedUrl;
  final String language;
  final String title;
  final String description;
  final String icon;


  factory Psicologia.fromJson(Map<String, dynamic> json) => Psicologia(
    version: json["version"],
    userComment: json["user_comment"],
    homePageUrl: json["home_page_url"],
    feedUrl: json["feed_url"],
    language: json["language"],
    title: json["title"],
    description: json["description"],
    icon: json["icon"],

  );

  Map<String, dynamic> toJson() => {
    "version": version,
    "user_comment": userComment,
    "home_page_url": homePageUrl,
    "feed_url": feedUrl,
    "language": language,
    "title": title,
    "description": description,
    "icon": icon,

  };
}

