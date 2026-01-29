import 'package:flutter/material.dart';
import '../models/user_data.dart';

class UserDataProvider extends ChangeNotifier {
  UserData _userData = UserData();
  bool _imagesUploadedSuccessfully = false;

  UserData get userData => _userData;
  bool get imagesUploadedSuccessfully => _imagesUploadedSuccessfully;

  // Personal Information
  void setFirstName(String firstName) {
    _userData.firstName = firstName;
    notifyListeners();
  }

  void setLastName(String lastName) {
    _userData.lastName = lastName;
    notifyListeners();
  }

  void setMobileNumber(String mobileNumber) {
    _userData.mobileNumber = mobileNumber;
    notifyListeners();
  }

  void setLandline(String landline) {
    _userData.landline = landline;
    notifyListeners();
  }

  void setEmail(String email) {
    _userData.email = email;
    notifyListeners();
  }

  // Address Information
  void setApartment(String apartment) {
    _userData.apartment = apartment;
    notifyListeners();
  }

  void setFloor(String floor) {
    _userData.floor = floor;
    notifyListeners();
  }

  void setBuilding(String building) {
    _userData.building = building;
    notifyListeners();
  }

  void setStreetName(String streetName) {
    _userData.streetName = streetName;
    notifyListeners();
  }

  void setArea(String area) {
    _userData.area = area;
    notifyListeners();
  }

  void setCity(String city) {
    _userData.city = city;
    notifyListeners();
  }

  void setLandmark(String landmark) {
    _userData.landmark = landmark;
    notifyListeners();
  }

  // ID Information
  void setFrontIdImagePath(String path) {
    _userData.frontIdImagePath = path;
    notifyListeners();
  }

  void setBackIdImagePath(String path) {
    _userData.backIdImagePath = path;
    notifyListeners();
  }

  void setFrontIdUrl(String url) {
    _userData.frontIdUrl = url;
    notifyListeners();
  }

  void setBackIdUrl(String url) {
    _userData.backIdUrl = url;
    notifyListeners();
  }

  void setImagesUploadedSuccessfully(bool uploaded) {
    _imagesUploadedSuccessfully = uploaded;
    _userData.imagesUploadedToGoogleDrive = uploaded;
    notifyListeners();
  }

  String? get frontIdImagePath => _userData.frontIdImagePath;
  String? get backIdImagePath => _userData.backIdImagePath;
  String? get frontIdUrl => _userData.frontIdUrl;
  String? get backIdUrl => _userData.backIdUrl;

  // Reset all data (for next user registration)
  void resetUserData() {
    _userData = UserData();
    notifyListeners();
  }

  // Get all user data as JSON
  Map<String, dynamic> getUserDataAsJson() {
    return _userData.toJson();
  }
}
