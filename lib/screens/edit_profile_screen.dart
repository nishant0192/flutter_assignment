import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _anniversaryController;
  String _selectedGender = 'Male';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = currentUserNotifier.value;
    _nameController = TextEditingController(text: profile.name);
    _mobileController = TextEditingController(text: profile.mobile);
    _emailController = TextEditingController(text: profile.email);
    _dobController = TextEditingController(text: profile.dob);
    _anniversaryController = TextEditingController(text: profile.anniversary);
    _selectedGender = profile.gender;

    _nameController.addListener(_checkForChanges);
    _mobileController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _dobController.addListener(_checkForChanges);
    _anniversaryController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final profile = currentUserNotifier.value;
    final hasChangesNow =
        _nameController.text.trim() != profile.name ||
        _mobileController.text.trim() != profile.mobile ||
        _emailController.text.trim() != profile.email ||
        _dobController.text.trim() != profile.dob ||
        _anniversaryController.text.trim() != profile.anniversary ||
        _selectedGender != profile.gender;

    if (_hasChanges != hasChangesNow) {
      if (mounted) {
        setState(() {
          _hasChanges = hasChangesNow;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _anniversaryController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final newProfile = currentUserNotifier.value.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      dob: _dobController.text.trim(),
      anniversary: _anniversaryController.text.trim(),
      gender: _selectedGender,
    );
    currentUserNotifier.value = newProfile;
    saveUserProfile(newProfile); // Persist changes to cache
    Navigator.pop(context); // Go back after saving
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF008D4C), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF008D4C), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format to a readable string, e.g. YYYY-MM-DD or DD/MM/YYYY
        // Based on whatever formatting was there. Let's use DD-MM-YYYY format
        controller.text =
            "\${picked.day.toString().padLeft(2, '0')}-\${picked.month.toString().padLeft(2, '0')}-\${picked.year}";
      });
      _checkForChanges();
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool hasClearIcon = false,
    bool hasChangeButton = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          suffixIcon: hasChangeButton
              ? TextButton(
                  onPressed: () {},
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(
                      color: Color(0xFF008D4C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : hasClearIcon
              ? IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => controller.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black26),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLetter = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Light greyish blue background
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                      padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            'Name',
                            _nameController,
                            hasClearIcon: true,
                          ),
                          _buildTextField(
                            'Mobile',
                            _mobileController,
                            hasChangeButton: true,
                          ),
                          _buildTextField(
                            'Email',
                            _emailController,
                            hasChangeButton: true,
                          ),
                          _buildTextField(
                            'Date of birth',
                            _dobController,
                            isReadOnly: true,
                            onTap: () => _selectDate(context, _dobController),
                          ),
                          _buildTextField(
                            'Anniversary',
                            _anniversaryController,
                            isReadOnly: true,
                            onTap: () =>
                                _selectDate(context, _anniversaryController),
                          ),
                          _buildDropdownField(
                            'Gender',
                            _selectedGender,
                            ['Male', 'Female', 'Other'],
                            (val) {
                              if (val != null) {
                                setState(() => _selectedGender = val);
                                _checkForChanges();
                              }
                            },
                          ),
                          const SizedBox(height: 80), // Space for bottom button
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initialLetter,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 40,
              ),
              color: const Color(0xFFF4F6FB), // Match scaffold background
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges
                        ? const Color(0xFF008D4C)
                        : const Color(0xFFE2E6EC),
                    disabledBackgroundColor: const Color(0xFFE2E6EC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Update profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _hasChanges ? Colors.white : Colors.black45,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
