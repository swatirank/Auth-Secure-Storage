import 'dart:convert';

import 'package:auth_secure_storage/states/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  AuthCubit() : super(AuthInitial());

  Future<void> autoLogin() async {
    try {
      emit(AuthLoading());

      String? token = await _storage.read(
        key: 'token',
      ); // auth token used for accessing secure endpoints
      String? loginTimeStr = await _storage.read(
        key: 'loginTime',
      ); // the time when user logged in

      if (token != null && loginTimeStr != null) {
        DateTime loginTime = DateTime.parse(
          loginTimeStr, // converting the logintimestr into datetime object
        ); //the time when user logged in
        DateTime now = DateTime.now(); // current time

        Duration difference = now.difference(
          loginTime,
        ); // calculating th etime gap between user logged in and current time
        // ex user log in : 5.00 PM current time : 5:01PM then the difference is 1 min

        if (difference.inMinutes > 2) {
          // if the time difference is greater than 2 minutes then we assume that token was expired
          await _storage.delete(
            key: 'token',
          ); // delete the token from local storage
          await _storage.delete(
            key: 'loginTime',
          ); // delete the logintime from local storage
          emit(AuthUnauthenticated());
          return;
        }
        emit(AuthAuthentication());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error loading token'));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final res = await http.post(
        Uri.parse(
          'https://reqres.in/api/login',
        ), // email: eve.holt@reqres.in , password: cityslicka
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        String token =
            data['token']; // takes the token returned from the API response
        await _storage.write(
          key: 'token',
          value: token,
        ); // this securely stores the token in local storage
        await _storage.write(
          key: 'loginTime',
          value:
              DateTime.now()
                  .toIso8601String(), // this saves the exact time when user logged in
        );
        emit(AuthAuthentication());
      } else {
        emit(AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError('Error logging in'));
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'loginTime');
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error logging out'));
    }
  }
}
