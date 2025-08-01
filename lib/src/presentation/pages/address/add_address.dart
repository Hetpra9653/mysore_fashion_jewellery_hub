import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_text_field.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_button.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/button_loading_animated_widget.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/loading_to_dart.dart';

import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../bloc/user/user_event.dart';

class AddAddressScreen extends StatefulWidget {
  final bool? isEdit;
  final AddressModel? existingAddress;

  const AddAddressScreen({
    super.key,
    this.isEdit = false,
    this.existingAddress,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Controllers for all fields
  late final TextEditingController _contactInfoController;
  late final TextEditingController _phoneController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _localityController;
  late final TextEditingController _flatController;
  late final TextEditingController _landmarkController;

  final UserBloc userBloc = sl<UserBloc>();

  int _addressType = 0; // 0: Home, 1: Office, 2: Other
  bool _makeDefault = false;
  final LoadingToDoneTransitionController loadingToDoneTransitionController =
  LoadingToDoneTransitionController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _contactInfoController = TextEditingController();
    _phoneController = TextEditingController();
    _pincodeController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _localityController = TextEditingController();
    _flatController = TextEditingController();
    _landmarkController = TextEditingController();

    // If editing, pre-fill the fields
    if (widget.isEdit == true && widget.existingAddress != null) {
      final addr = widget.existingAddress!;
      _makeDefault = addr.isPrimary ?? false;

      _contactInfoController.text = addr.label ?? ''; // assuming label is like contact info
      _phoneController.text = addr.phoneNumber ?? '';
      _pincodeController.text = addr.postalCode ?? '';
      _cityController.text = addr.city ?? '';
      _stateController.text = addr.state ?? '';

      // Assuming street contains combined flat/locality/landmark info
      // You may need to parse this if stored differently, here we just put it all in locality for now
      _localityController.text = addr.street ?? '';
      _flatController.text = ''; // missing separate field in old data; choose to leave empty
      _landmarkController.text = ''; // optional - none

      // Determine type from label (Home, Office, Other)
      final labelLower = (addr.label ?? '').toLowerCase();
      if (labelLower == 'home') {
        _addressType = 0;
      } else if (labelLower == 'office') {
        _addressType = 1;
      } else {
        _addressType = 2;
      }
    }
  }

  @override
  void dispose() {
    _contactInfoController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _localityController.dispose();
    _flatController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() => _isSubmitting = true);
      loadingToDoneTransitionController.loading();

      final addressID = widget.isEdit == true
          ? widget.existingAddress?.addressID ?? UniqueKey().toString()
          : UniqueKey().toString();

      final streetBuffer = StringBuffer();
      if (_flatController.text.trim().isNotEmpty) {
        streetBuffer.write(_flatController.text.trim());
      }
      if (_localityController.text.trim().isNotEmpty) {
        if (streetBuffer.isNotEmpty) streetBuffer.write(', ');
        streetBuffer.write(_localityController.text.trim());
      }
      if (_landmarkController.text.trim().isNotEmpty) {
        if (streetBuffer.isNotEmpty) streetBuffer.write(', ');
        streetBuffer.write(_landmarkController.text.trim());
      }

      final newAddress = AddressModel(
        addressID: addressID,
        label: _getLabelForType(_addressType),
        phoneNumber: _phoneController.text.trim(),
        street: streetBuffer.toString(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _pincodeController.text.trim(),
        isPrimary: _makeDefault,
      );

      if (widget.isEdit == true) {
        userBloc.add(EditAddressEvent(
          updatedAddress: newAddress,
          makeDefault: _makeDefault,
        ));
      } else {
        userBloc.add(AddAddressEvent(
          newAddress: newAddress,
          makeDefault: _makeDefault,
        ));
      }

      Future.delayed(const Duration(seconds: 1), () {
        loadingToDoneTransitionController.done();
        setState(() => _isSubmitting = false);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (context.mounted) {
            context.pop();
          }
        });
      });
    }
  }

  String _getLabelForType(int type) {
    switch (type) {
      case 0:
        return "Home";
      case 1:
        return "Office";
      case 2:
        return "Other";
      default:
        return "Home";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          widget.isEdit == true ? 'Edit Address' : 'Add Address',
          style: AppTextStyle.poppinsBoldTextStyle.copyWith(fontSize: 17.sp),
        ),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black333333Color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                AppTextField(
                  controller: _contactInfoController,
                  hintText: 'Contact Info',
                  validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Required';
                    }
                    // Simple digit validation
                    if (!RegExp(r'^\d{7,15}$').hasMatch(val.trim())) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 28.h),
                Text(
                  'Address Info',
                  style: AppTextStyle.poppinsBoldTextStyle.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _pincodeController,
                        hintText: 'Pincode',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          if (!RegExp(r'^\d{5,10}$').hasMatch(val.trim())) {
                            return 'Enter valid pincode';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        hintText: 'City',
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _stateController,
                  hintText: 'State',
                  validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _localityController,
                  hintText: 'Locality/Area/Street',
                  validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _flatController,
                  hintText: 'Flat no./Building Name',
                  validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _landmarkController,
                  hintText: 'Landmark (optional)',
                ),
                SizedBox(height: 32.h),
                Text(
                  'Address Type',
                  style: AppTextStyle.poppinsBoldTextStyle.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _AddressRadio(
                      label: "Home",
                      value: 0,
                      groupValue: _addressType,
                      onChanged: (v) => setState(() => _addressType = v ?? 0),
                    ),
                    SizedBox(width: 18.w),
                    _AddressRadio(
                      label: "Office",
                      value: 1,
                      groupValue: _addressType,
                      onChanged: (v) => setState(() => _addressType = v ?? 0),
                    ),
                    SizedBox(width: 18.w),
                    _AddressRadio(
                      label: "Other",
                      value: 2,
                      groupValue: _addressType,
                      onChanged: (v) => setState(() => _addressType = v ?? 0),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Checkbox(
                      value: _makeDefault,
                      onChanged: (v) => setState(() => _makeDefault = v ?? false),
                      activeColor: AppColors.logoBlueColor,
                    ),
                    Text(
                      'Make As Default Address',
                      style: AppTextStyle.poppinsNormalTextStyle16,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ButtonAnimatedLoadingWidget(
                  height: 50.h,
                  controller: loadingToDoneTransitionController,
                  border: true,
                  button: AppButton(
                    buttonText:
                    widget.isEdit == true ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                    onPressed: _isSubmitting ? null : _handleSave,
                  ),
                ),
                SizedBox(height: 28.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper radio for address type
class _AddressRadio extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _AddressRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppColors.logoBlueColor,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: AppTextStyle.poppinsNormalTextStyle16),
      ],
    );
  }
}
