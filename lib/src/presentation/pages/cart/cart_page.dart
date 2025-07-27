import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_images.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/cart/widgets/address_bottom_sheet.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/cart/widgets/cart_item_widget.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/cart/widgets/order_detail_widgets.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_button.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_text_field.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/common/common_methods.dart';
import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../bloc/cart/cart_state.dart';

class BagScreen extends StatefulWidget {
  final void Function() onBackPressed;
  const BagScreen({Key? key, required this.onBackPressed}) : super(key: key);

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final TextEditingController discountController = TextEditingController();
  final CartBloc _cartBloc = sl<CartBloc>();

  @override
  void initState() {
    super.initState();
    _cartBloc.add(LoadCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cartBloc,
      child: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CartUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please login to view your cart')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.scaffoldBackground,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.black333333Color),
                onPressed: widget.onBackPressed,
              ),
              centerTitle: true,
              title: Text(
                state is CartLoaded
                    ? 'Cart (${state.cartItems.length} Product)'
                    : 'Cart',
                style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                  color: AppColors.black333333Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: AppColors.black333333Color,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body:
                state is CartLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is CartLoaded
                    ? _buildCartContent(state)
                    : const Center(child: Text('Your cart is empty')),
          );
        },
      ),
    );
  }

  Future<void> applyDiscountCode({
    required BuildContext context,
    required String enteredCode,
    required Function(double discountPercent) onSuccess,
    required Function(String errorMessage) onFailure,
  }) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('coupans').limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        onFailure('No coupons available');
        return;
      }

      final data = querySnapshot.docs.first.data();
      final List<dynamic> discountCoupons = data['discount_coupans'] ?? [];

      final matchingCoupon = discountCoupons.firstWhere(
        (item) =>
            item['code']?.toString().toLowerCase() == enteredCode.toLowerCase(),
        orElse: () => null,
      );

      if (matchingCoupon != null && matchingCoupon['discount'] != null) {
        final discount =
            double.tryParse(matchingCoupon['discount'].toString()) ?? 0.0;
        onSuccess(discount);
      } else {
        onFailure('Invalid or expired coupon code');
      }
    } catch (e) {
      onFailure('Something went wrong. Please try again later.');
    }
  }

  Widget _buildCartContent(CartLoaded state) {
    return SingleChildScrollView(
      child:
          state.cartItems.isEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 4,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Center(
                  heightFactor: 0.5,

                  child: Image.asset(
                    AppImages.emptyCart,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
              : Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (newQty) {
                          if (newQty >
                              (double.tryParse(
                                    item.quantity.toString() ?? '0',
                                  ) ??
                                  0)) {
                            _cartBloc.add(
                              IncreaseQuantityEvent(product: item.product!),
                            );
                          } else {
                            _cartBloc.add(
                              DecreaseQuantityEvent(product: item.product!),
                            );
                          }
                        },
                        onRemove: () {
                          _cartBloc.add(
                            RemoveFromCartEvent(product: item.product!),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            controller: discountController,
                            hintText: 'Apply Discount Code',
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: AppButton(
                            buttonText: 'Apply',
                            onPressed: () {
                              final code = discountController.text.trim();

                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a discount code',
                                    ),
                                  ),
                                );
                                return;
                              }

                              applyDiscountCode(
                                context: context,
                                enteredCode: code,
                                onSuccess: (discount) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Discount Applied: $discount%',
                                      ),
                                    ),
                                  );
                                },
                                onFailure: (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildReturnPolicySection(),
                  SizedBox(height: 20.h),
                  OrderDetailsWidget(
                    bagTotal: state.subTotal,
                    bagSavings: 0.0, // update if discount logic implemented
                    deliveryFee: 99.0,
                    amountPayable: state.subTotal + 99.0,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppButton(
                      buttonText: 'Proceed to Checkout',
                      onPressed: () {
                        showAppBottomSheet(
                          context: context,
                          child: DeliveryAddressBottomSheet(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
    );
  }

  Widget _buildReturnPolicySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RETURN/REFUND POLICY',
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              fontFamily: GoogleFonts.oswald().fontFamily,
              color: AppColors.black333333Color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'In case of return, we ensure quick refund. Full amount will be refunded excluding Convenience Fee',
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              fontSize: 13.sp,
              color: AppColors.black323232Color,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              // Navigate to full policy
            },
            child: Text(
              'Read policy',
              style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                fontSize: 14.sp,
                color: Color(0xff913B10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cartBloc.close();
    super.dispose();
  }
}
