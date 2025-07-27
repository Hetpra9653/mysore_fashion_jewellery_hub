import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_constants.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_button.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_text_field.dart';
import '../../../../data/models/user_model.dart';

class DeliveryAddressBottomSheet extends StatefulWidget {
  const DeliveryAddressBottomSheet({super.key});

  @override
  _DeliveryAddressBottomSheetState createState() =>
      _DeliveryAddressBottomSheetState();
}

class _DeliveryAddressBottomSheetState
    extends State<DeliveryAddressBottomSheet> {
  final TextEditingController _pincodeController = TextEditingController();
  int _selectedAddressIndex = 0;

  final List<AddressModel> _addresses = [
    AddressModel(
      label: 'Home',
      phoneNumber: '9426920533',
      addressID: '1',
      street: 'Building no. 307/4, NRI Colony, Nishatpura Joy agra road',
      city: 'Jaipur',
      state: 'Rajasthan',
      postalCode: '462010',
      isPrimary: true,
    ),
    AddressModel(
      label: 'Office',
      phoneNumber: '9426920533',
      addressID: '2',
      street: 'Building no. 307/4, NRI Colony, Nishatpura Joy',
      city: 'Jaipur',
      state: 'Rajasthan',
      postalCode: '302020',
      isPrimary: false,
    ),
    AddressModel(
      label: 'Other',
      phoneNumber: '9426920533',
      addressID: '3',
      street: 'Building no. 307/4, NRI Colony, Nishatpura Joy',
      city: 'Jaipur',
      state: 'Rajasthan',
      postalCode: '302031',
      isPrimary: false,
    ),
  ];

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleAddressSelection(int index) {
    setState(() {
      _selectedAddressIndex = index;
    });
  }

  void _handleSubmitPincode() {
    // Handle pincode submission
    print('Pincode submitted: ${_pincodeController.text}');
  }

  void _handleUseCurrentLocation() {
    // Handle current location selection
    print('Use current location tapped');
  }

  void _handleAddNewAddress() {
    context.push(AppRoutes.addAddress, extra: {AppConstants.isEdit: false});
  }

  void _handleEditAddress(int index) {
    // Handle edit address
    print('Edit address at index: $index');
  }

  void _handleDeleteAddress(int index) {
    // Handle delete address
    setState(() {
      _addresses.removeAt(index);
      if (_selectedAddressIndex >= _addresses.length) {
        _selectedAddressIndex = _addresses.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground, // Cream background color
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.w, color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Address',
                  style: AppTextStyle.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      shape: BoxShape.circle,
                      border: Border.all(),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade700,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Address List
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Address Cards
                  ...List.generate(_addresses.length, (index) {
                    final address = _addresses[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: _buildAddressCard(address, index),
                    );
                  }),

                  // Show more addresses link
                  if (_addresses.length > 3)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: GestureDetector(
                        onTap: () {
                          // Handle show more addresses
                        },
                        child: Text(
                          '+ ${_addresses.length - 3} more addresses',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // Add New Address Button
                  OutlinedButton(
                    onPressed: (){
                      _handleAddNewAddress();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.whiteColor,
                      side: BorderSide(color: Colors.black),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Add New Address',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'Use pincode to check delivery info',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Pincode Input
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _pincodeController,
                          hintText: 'Enter Pin code',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 1,
                        child: AppButton(
                          buttonText: 'Submit',
                          onPressed: _handleSubmitPincode,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Current Location Button
                  GestureDetector(
                    onTap: _handleUseCurrentLocation,
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Colors.brown.shade700,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Use my current location',
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, int index) {
    final isSelected = _selectedAddressIndex == index;

    return GestureDetector(
      onTap: () => _handleAddressSelection(index),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.logoBlueColor : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio Button
            Container(
              margin: EdgeInsets.only(top: 2.h, right: 12.w),
              child: Radio<int>(
                value: index,
                groupValue: _selectedAddressIndex,
                onChanged: (value) => _handleAddressSelection(value!),
                activeColor: AppColors.logoBlueColor,
              ),
            ),

            // Address Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${address.label ?? 'Address'}, ${address.postalCode ?? ''}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (address.isPrimary == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.home,
                            color: Colors.green.shade700,
                            size: 16.r,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    '${address.street ?? ''}, ${address.city ?? ''}, ${address.state ?? ''}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (isSelected) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.logoBlueColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Delivering Here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                GestureDetector(
                  onTap: () => _handleEditAddress(index),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.sp),
                    height: 30.h,
                    width: 30.w,
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      border: Border.all(color: Colors.grey.shade400),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 14.sp,
                      color: AppColors.black222222Color,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => _handleDeleteAddress(index),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      border: Border.all(color: Colors.grey.shade400),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.grey.shade600,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
