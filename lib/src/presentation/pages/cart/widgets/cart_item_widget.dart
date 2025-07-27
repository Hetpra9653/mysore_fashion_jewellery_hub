import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_defaults.dart';
import '../../../../core/constants/app_text_styles.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final quantity = item.quantity ?? 1;

    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.f7ECDBColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100.w,
              height: 100.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child:
                    product?.images?.first != null
                        ? Image.network(
                          product?.images?.first ?? '',
                          fit: BoxFit.cover,
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 32.sp,
                          ),
                        ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product?.title ?? 'Unknown Product',
                          style: AppTextStyle.poppinsRegular16.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black333333Color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.whiteColor,
                            border: Border.all(
                              color: AppColors.grey6D6D6DColor,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.grey6D6D6DColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product?.description ?? '',
                    style: AppTextStyle.poppins(
                      fontSize: 12.sp,
                      color: AppColors.grey6D6D6DColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (item.selectedColor != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.grey6D6D6DColor,
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Color: ${item.selectedColor}',
                            style: AppTextStyle.poppins(
                              fontSize: 10.sp,
                              color: AppColors.grey6D6D6DColor,
                            ),
                          ),
                        ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey6D6D6DColor),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Qty: $quantity',
                          style: AppTextStyle.poppins(
                            fontSize: 10.sp,
                            color: AppColors.grey6D6D6DColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${AppDefaults.rupeeSymbol}${double.parse(product?.price ?? '0').toStringAsFixed(2).toString() ?? '0'}',
                        style: AppTextStyle.poppinsRegular16.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.black333333Color,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if ((double.parse(product?.price ?? '0') ?? 0) >
                          (double.parse(product?.discountPrice ?? '0') ?? 0))
                        Text(
                          '${AppDefaults.rupeeSymbol}${double.parse(product?.price ?? '0').toStringAsFixed(2).toString() ?? '0'}',
                          style: AppTextStyle.poppinsRegular14.copyWith(
                            color: AppColors.grey6D6D6DColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 8.w),
                      if (product?.discountPrice != null)
                        Text(
                          '-${product!.discountPrice}%',
                          style: AppTextStyle.poppinsRegular14.copyWith(
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
