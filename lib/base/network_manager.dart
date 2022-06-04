import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';

class NetworkManager {
  static NetworkManager _instance;
  static NetworkManager get instance {
    _instance ??= NetworkManager._init();
    return _instance;
  }

  final String _baseUrl = API_URL;

  NetworkManager._init();
  Map<String, String> _postOptionsWithToken(String token) {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "Bearer $token",
    };
  }

  Map<String, String> _postOptions() {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future httpGet({String path, model, String token}) async {
    final response = await get(
      Uri.parse(_baseUrl + path),
      headers: token == null ? this._postOptions() : this._postOptionsWithToken(token),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return responseBody.map((e) => model.fromJson(e)).toList();
      } else if (responseBody is Map) {
        return model.fromJson(responseBody);
      }
      return responseBody;
    } else if (response.statusCode == 400) {
      throw BadRequestError(msg: response.body);
    } else if (response.statusCode == 401) {
      throw AuthorizeError.to();
    } else {
      throw InternalServerError.to();
    }
  }

  Future httpPost({@required String path, model, @required Map data, String token}) async {
    final response = await post(Uri.parse(path.contains("http") ? path : _baseUrl + path),
        headers: token == null ? this._postOptions() : this._postOptionsWithToken(token),
        body: data != null ? jsonEncode(data) : "");
    if (response.statusCode == 200) {
      
      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return responseBody.map((e) => model.fromJson(e)).toList();
      } else if (responseBody is Map) {
        return model.fromJson(responseBody);
      }
      return responseBody;
    } else if (response.statusCode == 400) {
      throw BadRequestError(msg: response.body);
    } else if (response.statusCode == 401) {
      throw AuthorizeError.to();
    } else {
      throw InternalServerError(msg: response.body);
    }
  }

  Future<Response> httpPostRes({@required String path, @required Map data, String token}) async {
    final response = await post(Uri.parse(path.contains("http") ? path : _baseUrl + path),
        headers: token == null ? this._postOptions() : this._postOptionsWithToken(token),
        body: data != null ? jsonEncode(data) : "");
    return response;
  }
}
