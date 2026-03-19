import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Color(0xFF4CAF50),
                  onPrimary: Colors.white,
                  surface: Color(0xFF202126),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Color(0xFF008D4C),
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFF4CAF50) : const Color(0xFF008D4C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey.shade600, 
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
          ),
          suffixIcon: hasChangeButton
              ? TextButton(
                  onPressed: () {},
                  child: Text(
                    'CHANGE',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF008D4C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : hasClearIcon
              ? IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: isDark ? const Color(0xFF202126) : Colors.white,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey.shade600, 
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialLetter = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: AppBar(
        title: Text(
          'Your Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 24),
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
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initialLetter,
                                style: TextStyle(
                                  fontSize: 40,
                                  color: isDark ? Colors.orange.shade300 : Colors.orange,
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
                                  color: isDark ? const Color(0xFF2D2E33) : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: isDark ? Colors.white70 : Colors.black87,
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
              color: AppColors.scaffold(context),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges
                        ? (isDark ? const Color(0xFF4CAF50) : const Color(0xFF008D4C))
                        : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E6EC)),
                    disabledBackgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E6EC),
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
                      color: _hasChanges 
                        ? Colors.white 
                        : (isDark ? Colors.white24 : Colors.black45),
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
