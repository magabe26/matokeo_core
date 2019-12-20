/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:meta/meta.dart';

class CachedResultData extends Equatable {
  final int id;
  final String name;
  final int year;
  final String url;
  final String xml;

  CachedResultData({
    this.id, //not required because it is auto incremented
    @required this.name,
    @required this.year,
    @required this.url,
    @required this.xml,
  });

  @override
  List<Object> get props => [name, year, url, xml];

  factory CachedResultData.fromJson(Map<String, dynamic> json) {
    return CachedResultData(
        id: json['_id'],
        name: json['name'],
        year: json['year'],
        url: json['url'],
        xml: json['xml']);
  }

  CachedResultData copyWith(
      {int id, String name, int year, String url, String xml}) {
    return CachedResultData(
        id: id ?? this.id,
        name: name ?? this.name,
        year: year ?? this.year,
        url: url ?? this.url,
        xml: xml ?? this.xml);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '_id': id,
      'name': name,
      'year': year,
      'url': url,
      'xml': xml
    };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
