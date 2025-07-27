import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';

class AddAddress extends StatefulWidget {
  final bool isEdit;
  const AddAddress({super.key, required this.isEdit});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit Address' : 'Add Address',
          style: AppTextStyle.poppinsBold17.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}
