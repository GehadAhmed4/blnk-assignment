class UserData {
  // Personal Information
  String? firstName;
  String? lastName;
  String? mobileNumber;
  String? landline;
  String? email;

  // Address Information
  String? apartment;
  String? floor;
  String? building;
  String? streetName;
  String? area;
  String? city;
  String? landmark;

  // ID Information
  String? frontIdImagePath;
  String? backIdImagePath;
  String? frontIdUrl;
  String? backIdUrl;
  bool imagesUploadedToGoogleDrive = false;

  UserData({
    // Personal Info
    this.firstName,
    this.lastName,
    this.mobileNumber,
    this.landline,
    this.email,
    // Address Info
    this.apartment,
    this.floor,
    this.building,
    this.streetName,
    this.area,
    this.city,
    this.landmark,
    // ID Info
    this.frontIdImagePath,
    this.backIdImagePath,
    this.frontIdUrl,
    this.backIdUrl,
    this.imagesUploadedToGoogleDrive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      // Personal Info
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'landline': landline,
      'email': email,
      // Address Info
      'apartment': apartment,
      'floor': floor,
      'building': building,
      'streetName': streetName,
      'area': area,
      'city': city,
      'landmark': landmark,
      // ID Info
      'frontIdImagePath': frontIdImagePath,
      'backIdImagePath': backIdImagePath,
      'frontIdUrl': frontIdUrl,
      'backIdUrl': backIdUrl,
      'imagesUploadedToGoogleDrive': imagesUploadedToGoogleDrive,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      landline: json['landline'] as String?,
      email: json['email'] as String?,
      apartment: json['apartment'] as String?,
      floor: json['floor'] as String?,
      building: json['building'] as String?,
      streetName: json['streetName'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      landmark: json['landmark'] as String?,
      frontIdImagePath: json['frontIdImagePath'] as String?,
      backIdImagePath: json['backIdImagePath'] as String?,
      frontIdUrl: json['frontIdUrl'] as String?,
      backIdUrl: json['backIdUrl'] as String?,
      imagesUploadedToGoogleDrive: json['imagesUploadedToGoogleDrive'] as bool? ?? false,
    );
  }

  bool isComplete() {
    return firstName != null &&
        lastName != null &&
        mobileNumber != null &&
        email != null &&
        streetName != null &&
        area != null &&
        city != null &&
        frontIdImagePath != null &&
        backIdImagePath != null;
  }
}
