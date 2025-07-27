import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_constants.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_defaults.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_icons.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/common/extensions.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/product/product_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/product_detail/widgets/review_and_ratings_widget.dart';
import 'package:toastification/toastification.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/expandable_text.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  int selectedColorIndex = 0;
  bool isFavorite = false;
  bool isAddingToCart = false;

  Product? product;

  final ProductBloc productBloc = sl<ProductBloc>();
  final CartBloc cartBloc = sl<CartBloc>();

  @override
  void initState() {
    productBloc.add(FetchProductByIdEvent(id: widget.productId));
    // Load cart to get current item count
    cartBloc.add(LoadCartEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
          listener: (context, state) {
            if (state is ProductError) {
              _showToast(
                context: context,
                message: state.message,
                type: ToastificationType.error,
              );
            } else if (state is ProductDetailLoaded) {
              setState(() {
                product = state.product;
              });
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          bloc: cartBloc,
          listener: (context, state) {
            if (state is CartLoading && isAddingToCart) {
              // Show loading state
            } else if (state is CartLoaded) {
              if (isAddingToCart) {
                setState(() {
                  isAddingToCart = false;
                });
                _showToast(
                  context: context,
                  message: 'Added to cart successfully!',
                  type: ToastificationType.success,
                );
              }
            } else if (state is CartFailure) {
              if (isAddingToCart) {
                setState(() {
                  isAddingToCart = false;
                });
                _showToast(
                  context: context,
                  message: state.message,
                  type: ToastificationType.error,
                );
              }
            }
          },
        ),
      ],
      child: BlocBuilder<ProductBloc, ProductState>(
        bloc: productBloc,
        buildWhen:
            (prev, current) =>
                current is ProductDetailLoaded ||
                current is ProductError ||
                current is AddReviewSuccess,
        builder: (BuildContext context, ProductState state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: _buildAppBar(context),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Gallery
                      ProductCarouselSlider(
                        likeCount: 1835,
                        images: product?.images ?? [],
                      ),

                      // Product Title and Price
                      ProductTitleAndPrice(
                        title: product?.title ?? '',
                        subtitle: product?.description ?? '',
                        price: product?.discountPrice ?? '',
                        originalPrice: product?.price ?? '',
                      ),
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),

                      // Color Selection
                      if (product != null &&
                          product?.colorOptions != null &&
                          product!.colorOptions!.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.all(16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelWidget(label: " COLOR"),
                              SizedBox(height: 16.h),
                              ColorSelector(
                                colors: product?.colorOptions ?? [],
                                selectedIndex: selectedColorIndex,
                                onColorSelected: (index) {
                                  setState(() {
                                    selectedColorIndex = index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 12.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ],

                      // Product Details
                      ExpandableSection(
                        title: "PRODUCT DETAIL",
                        children: [
                          ProductDetailItem(detail: product?.title ?? ""),
                          if (product != null &&
                              product?.colorOptions != null &&
                              product!.colorOptions!.isNotEmpty)
                            ProductDetailItem(
                              title: "Color",
                              detail:
                                  (product?.colorOptions ?? [])
                                      .join(',')
                                      .toString()
                                      .capitalize(),
                            ),
                          if (product != null &&
                              product?.sizeOptions != null &&
                              product!.sizeOptions!.isNotEmpty)
                            ProductDetailItem(
                              title: "Size:",
                              detail:
                                  (product?.sizeOptions ?? [])
                                      .join(',')
                                      .toString()
                                      .capitalize(),
                            ),
                        ],
                      ),

                      Container(
                        height: 12.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),

                      RatingsAndReviews(product: product ?? Product()),

                      // Space for bottom bar
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),

                // Bottom Add to Cart Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AddToCartBar(
                    onAddToBag: _handleAddToCart,
                    quantity: quantity,
                    onDecrement: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    onIncrement: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    onAddToFavorite: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    isFavorite: isFavorite,
                    isLoading: isAddingToCart,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actionsPadding: EdgeInsets.only(right: 16.w),
      actions: [
        SvgPicture.asset(AppIcons.searchIcon),
        SizedBox(width: 16.w),
        SvgPicture.asset(AppIcons.wishlistIcon),
        SizedBox(width: 16.w),
        // Cart Icon with Badge
        BlocBuilder<CartBloc, CartState>(
          bloc: cartBloc,
          builder: (context, state) {
            int itemCount = 0;
            if (state is CartLoaded) {
              itemCount = state.cartItems
                  .map((item) => item.quantity ?? 0)
                  .fold(0, (sum, qty) => sum + qty);
            }

            return Stack(
              children: [
                SvgPicture.asset(AppIcons.cartIcon),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : itemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _handleAddToCart() {
    if (product == null) {
      _showToast(
        context: context,
        message: 'Product not available',
        type: ToastificationType.error,
      );
      return;
    }

    // Validate product selection if needed
    if (!_validateProductSelection()) {
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    // Create a copy of the product with selected options
    Product productToAdd = Product(
      productID: product?.productID,
      title: product?.title,
      description: product?.description,
      price: product?.price,
      discountPrice: product?.discountPrice,
      images: product?.images,
      colorOptions: product?.colorOptions,
      sizeOptions: product?.sizeOptions,

      // Add selected color if available
    );

    cartBloc.add(
      AddToCartEvent(
        product: productToAdd,
        quantity: quantity,
        selectedColor:
            product!.colorOptions != null && product!.colorOptions!.isNotEmpty
                ? product!.colorOptions![selectedColorIndex]
                : null,
      ),
    );
  }

  bool _validateProductSelection() {
    // Add validation logic here if needed
    // For example, check if color selection is required
    if (product!.colorOptions != null &&
        product!.colorOptions!.isNotEmpty &&
        selectedColorIndex < 0) {
      _showToast(
        context: context,
        message: 'Please select a color',
        type: ToastificationType.warning,
      );
      return false;
    }

    return true;
  }

  void _showToast({
    required BuildContext context,
    required String message,
    required ToastificationType type,
  }) {
    toastification.show(
      style: ToastificationStyle.minimal,
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: type,
    );
  }
}

// Enhanced AddToCartBar with loading state
class AddToCartBar extends StatelessWidget {
  final int quantity;
  final VoidCallback onAddToBag;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAddToFavorite;
  final bool isFavorite;
  final bool isLoading;

  const AddToCartBar({
    Key? key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToFavorite,
    required this.isFavorite,
    required this.onAddToBag,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ).copyWith(bottom: MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity selector
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  onPressed: isLoading ? null : onDecrement,
                ),
              ),
              Container(
                width: 40.w,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  onPressed: isLoading ? null : onIncrement,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Add to favorites button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 38.w, minHeight: 38.h),
              onPressed: isLoading ? null : onAddToFavorite,
            ),
          ),
          SizedBox(width: 12.w),
          // Add to cart button
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onAddToBag,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLoading
                        ? Colors.grey.shade400
                        : AppColors.buttonBlueColor,
                foregroundColor: AppColors.buttonTextColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              child:
                  isLoading
                      ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.buttonTextColor,
                          ),
                        ),
                      )
                      : Text(
                        "ADD TO BAG",
                        style: AppTextStyle.poppinsButtonTextStyle,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rest of the classes remain the same...
class LabelWidget extends StatelessWidget {
  final String label;
  const LabelWidget({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.poppinsNormalTextStyle.copyWith(
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.oswald().fontFamily,
        fontSize: 16.sp,
      ),
    );
  }
}

class ProductCarouselSlider extends StatefulWidget {
  final List<String> images;
  final int likeCount;

  const ProductCarouselSlider({
    super.key,
    required this.images,
    this.likeCount = 0,
  });

  @override
  State<ProductCarouselSlider> createState() => _ProductCarouselSliderState();
}

class _ProductCarouselSliderState extends State<ProductCarouselSlider> {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  int _currentIndex = 0;
  bool _isLiked = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          CarouselSlider.builder(
            carouselController: carouselController,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
              autoPlay: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                margin: EdgeInsets.zero,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.zero,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(color: Colors.white),
                child: Image.network(widget.images[index]),
              );
            },
          ),

          /// Page Indicator without smooth_page_indicator
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: PageIndicator(
              count: widget.images.length,
              currentIndex: _currentIndex,
              activeColor: AppColors.textBlueColor,
              inactiveColor: Colors.grey,
              dotSize: 8.w,
              spacing: 4.w,
              animationDuration: const Duration(milliseconds: 300),
            ),
          ),

          // Share button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 0.5,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing this product!')),
                  );
                },
              ),
            ),
          ),

          // Like counter
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                    },
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: _isLiked ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_isLiked ? widget.likeCount + 1 : widget.likeCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;

  const PageIndicator({
    Key? key,
    required this.count,
    required this.currentIndex,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _Dot(
            size: dotSize,
            isActive: index == currentIndex,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            animationDuration: animationDuration,
          ),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  const _Dot({
    Key? key,
    required this.size,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: isActive ? size * 2.5 : size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

class ProductTitleAndPrice extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String originalPrice;

  const ProductTitleAndPrice({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              fontFamily: GoogleFonts.oswald().fontFamily,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              price.isNotEmpty
                  ? Text(
                    '${AppConstants.rupeeSymbol} $price',
                    style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Text(
                    '${AppConstants.rupeeSymbol} $originalPrice',
                    style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              SizedBox(width: 8.w),
              if (price.isNotEmpty && originalPrice.isNotEmpty)
                Text(
                  '${AppConstants.rupeeSymbol} $originalPrice',
                  style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "Price inclusive of all taxes.",
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Product Description :',
            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),
          ExpandableText(
            text: subtitle,
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              color: AppColors.grey6D6D6DColor,
              fontSize: 14.sp,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  final List<String> colors;
  final int selectedIndex;
  final Function(int) onColorSelected;

  const ColorSelector({
    Key? key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        colors.length,
        (index) => GestureDetector(
          onTap: () => onColorSelected(index),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: selectedIndex == index ? Color(0xfffde4cf) : Colors.white,
              border: Border.all(
                width: 1,
                color:
                    selectedIndex == index
                        ? AppColors.whiteColor
                        : AppColors.grey6D6D6DColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              colors[index].capitalize(),
              style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const ExpandableSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LabelWidget(label: widget.title),
                Row(
                  children: [
                    if (widget.title == "PRODUCT DETAIL" && !isExpanded)
                      Text(
                        "+ More",
                        style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                          color: AppColors.textBlueColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    SizedBox(width: 4.w),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Expandable content
        if (isExpanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}

class ProductDetailItem extends StatelessWidget {
  final String? title;
  final String detail;
  final String? trailingText;

  const ProductDetailItem({
    super.key,
    this.title,
    required this.detail,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              children: [
                ///add circular list unordered list icon
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppColors.black333333Color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  title ?? '',
                  style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          Expanded(
            child: Text(
              ' $detail',
              style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          if (trailingText != null)
            GestureDetector(
              onTap: () {
                // Handle click action
              },
              child: Text(
                trailingText ?? '',
                style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                  color: AppColors.textBlueColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
