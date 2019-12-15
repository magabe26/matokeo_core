/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import '../matokeo_core.dart';

abstract class MatokeoBloc<E, S> extends MBloc<E, S> {
  Future<void> load(String xml,{String baseUrl});
}
