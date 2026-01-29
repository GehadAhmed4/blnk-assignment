import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'google_login_screen.dart';
import '../providers/user_data_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apartmentController;
  late TextEditingController _floorController;
  late TextEditingController _buildingController;
  late TextEditingController _streetNameController;
  late TextEditingController _landMarkController;
  String? _selectedArea;
  String? _selectedCity;
  bool _isLoading = false;

  // Sample dropdown options
  final List<String> areas = ['Area 1', 'Area 2', 'Area 3', 'Area 4', 'Area 5'];
  final List<String> cities = ['City 1', 'City 2', 'City 3', 'City 4', 'City 5'];

  @override
  void initState() {
    super.initState();
    _apartmentController = TextEditingController();
    _floorController = TextEditingController();
    _buildingController = TextEditingController();
    _streetNameController = TextEditingController();
    _landMarkController = TextEditingController();
  }

  @override
  void dispose() {
    _apartmentController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _streetNameController.dispose();
    _landMarkController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedArea == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Area and City')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDataProvider = context.read<UserDataProvider>();
      
      // Save address info to provider
      userDataProvider.setApartment(_apartmentController.text);
      userDataProvider.setFloor(_floorController.text);
      userDataProvider.setBuilding(_buildingController.text);
      userDataProvider.setStreetName(_streetNameController.text);
      userDataProvider.setArea(_selectedArea ?? '');
      userDataProvider.setCity(_selectedCity ?? '');
      userDataProvider.setLandmark(_landMarkController.text);

      print('Address Info Saved:');
      print('Apartment: ${_apartmentController.text}');
      print('Floor: ${_floorController.text}');
      print('Building: ${_buildingController.text}');
      print('Street Name: ${_streetNameController.text}');
      print('Area: $_selectedArea');
      print('City: $_selectedCity');
      print('Land Mark: ${_landMarkController.text}');

      // Navigate to GoogleLoginScreen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GoogleLoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 20),
              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(1, false),
                  _buildStepLine(),
                  _buildStepIndicator(2, true),
                  _buildStepLine(),
                  _buildStepIndicator(3, false),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'step 2 (address info)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please provide your address details",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Three column row: Apartment, Floor, Building
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _apartmentController,
                            label: 'Apartment',
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _floorController,
                            label: 'Floor',
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _buildingController,
                            label: 'Building',
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Street Name
                    _buildTextField(
                      controller: _streetNameController,
                      label: 'Street Name',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z\s]"),
                        ),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Street name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Area and City dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Area',
                            value: _selectedArea,
                            items: areas,
                            onChanged: (value) {
                              setState(() => _selectedArea = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'City',
                            value: _selectedCity,
                            items: cities,
                            onChanged: (value) {
                              setState(() => _selectedCity = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Land Mark
                    _buildTextField(
                      controller: _landMarkController,
                      label: 'Land Mark',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z\s]"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 50,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
