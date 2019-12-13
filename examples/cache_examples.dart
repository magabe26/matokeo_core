/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:matokeo_core/matokeo_core.dart'
    show  CachedResultData;


void main() async{
  var data = CachedResultData(
      id:1,
      name: 'result',
      year: 2007,
      url: 'https/qwerty.thm',
      xml: 'poiuytrhgfd');

  print(data);

  print(data == CachedResultData(
      id:1,
      name: 'result',
      year: 2007,
      url: 'https/qwerty.thm',
      xml: 'poiuytrhgfd'));

  print(data.copyWith(id: 2));

  print(data == data.copyWith(name: 'newn'));
}