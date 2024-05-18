import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:toefl/remote/dio_toefl.dart';
import 'package:toefl/remote/env.dart';

import '../base_response.dart';

class BookmarkApi {
  Future<bool> updateBookmark(String id) async {
    try {
      final Response rawResponse =
          await DioToefl.instance.patch('${Env.apiUrl}/update-bookmark/$id');

      final response = BaseResponse.fromJson(json.decode(rawResponse.data));
      return response.data['bookmark'] ?? false;
    } catch (e) {
      return false;
    }
  }
}