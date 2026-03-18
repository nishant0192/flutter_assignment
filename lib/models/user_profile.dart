import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String email;
  final String mobile;
  final String dob;
  final String anniversary;
  final String gender;
  final int savedAmount;

  UserProfile({
    required this.name,
    required this.email,
    this.mobile = '',
    this.dob = '',
    this.anniversary = '',
    this.gender = 'Male',
    this.savedAmount = 0,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? mobile,
    String? dob,
    String? anniversary,
    String? gender,
    int? savedAmount,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      dob: dob ?? this.dob,
      anniversary: anniversary ?? this.anniversary,
      gender: gender ?? this.gender,
      savedAmount: savedAmount ?? this.savedAmount,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Guest User',
      email: json['email'] as String? ?? 'guest@example.com',
      mobile: json['mobile'] as String? ?? '9876543210',
      dob: json['dob'] as String? ?? '01/01/2000',
      anniversary: json['anniversary'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Male',
      savedAmount: json['savedAmount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'dob': dob,
      'anniversary': anniversary,
      'gender': gender,
      'savedAmount': savedAmount,
    };
  }
}

Future<void> saveUserProfile(UserProfile profile) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user_profile', jsonEncode(profile.toJson()));
}

Future<void> loadUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final String? profileStr = prefs.getString('user_profile');
  if (profileStr != null) {
    currentUserNotifier.value = UserProfile.fromJson(jsonDecode(profileStr));
  }
}

// Global state for simplicity across the app
final ValueNotifier<UserProfile> currentUserNotifier =
    ValueNotifier<UserProfile>(
      UserProfile(
        name: 'Guest User',
        email: 'guest@example.com',
        mobile: '9876543210',
        dob: '01/01/2000',
        savedAmount: 0,
      ),
    );
