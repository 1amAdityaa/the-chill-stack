import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' hide User;
import '../models/test_result.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();

  static const String baseUrl = 'https://api.saisports.gov.in';

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Mock login response
    await Future.delayed(const Duration(seconds: 1));
    return {
      'user': {
        'id': '1',
        'name': 'Demo User',
        'email': email,
        'age': 20,
        'gender': 'Male',
        'location': 'Delhi',
        'phoneNumber': '9876543210',
        'dateOfBirth': '2003-01-01T00:00:00.000Z',
      },
      'token': 'mock_jwt_token',
    };
  }

  Future<Map<String, dynamic>> register(User user, String password) async {
    // Mock registration response
    await Future.delayed(const Duration(seconds: 1));
    return {'user': user.toJson(), 'token': 'mock_jwt_token'};
  }

  Future<void> syncTestResult(TestResult result) async {
    // Mock sync to SAI servers
    await Future.delayed(const Duration(seconds: 2));
    // In real implementation, send encrypted data to SAI servers
  }
}
