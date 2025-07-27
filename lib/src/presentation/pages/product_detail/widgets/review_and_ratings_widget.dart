import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/app_text_field.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/widgets/loading_to_dart.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/dependencyInjector/dependency_injector.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/product/product_event.dart';
import '../../../bloc/product/product_state.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/button_loading_animated_widget.dart';

class RatingsAndReviews extends StatefulWidget {
  final Product product;

  const RatingsAndReviews({Key? key, required this.product}) : super(key: key);

  @override
  State<RatingsAndReviews> createState() => _RatingsAndReviewsState();
}

class _RatingsAndReviewsState extends State<RatingsAndReviews> {
  final TextEditingController _reviewController = TextEditingController();
  final List<File> _selectedImages = [];
  double _userRating = 5.0;
  late Product product;

  // Loading animation controller
  final LoadingToDoneTransitionController loadingToDoneTransitionController =
      LoadingToDoneTransitionController();

  final ProductBloc productBloc = sl<ProductBloc>();

  @override
  void initState() {
    product = widget.product;
    super.initState();
  }

  @override
  void didUpdateWidget(RatingsAndReviews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product != oldWidget.product) {
      setState(() {
        product = widget.product;
      });
    }
  }

  void dispose() {
    _reviewController.dispose();
    loadingToDoneTransitionController.dispose();
    super.dispose();
  }

  // Helper method to check file size
  bool checkFileSize({required int fileSize}) {
    const int maxSize = 2 * 1024 * 1024; // 2 MB in bytes
    return fileSize <= maxSize;
  }

  // Helper method to show toast messages
  void showToast(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImages() async {
    final permissionGranted = await _checkPermission();
    if (permissionGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        // Check file size before adding
        final File imageFile = File(pickedImage.path);
        bool isInSize = checkFileSize(fileSize: imageFile.lengthSync());

        if (isInSize) {
          setState(() {
            _selectedImages.add(imageFile);
          });

        }
      }
    } else {
      _requestPermission();
    }
  }

  void _requestPermission() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (sdkInt < 33) {
        PermissionStatus result = await Permission.storage.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          openAppSettings();
        } else if (result.isGranted || result.isLimited) {
          _pickImages();
        }
      } else {
        PermissionStatus result = await Permission.photos.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          openAppSettings();
        } else if (result.isGranted || result.isLimited) {
          _pickImages();
        }
      }
    } else {
      PermissionStatus result = await Permission.photos.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        openAppSettings();
      } else if (result.isGranted || result.isLimited) {
        _pickImages();
      }
    }
  }

  Future<bool> _checkPermission() async {
    bool isStatusSuccess;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (sdkInt < 33) {
        isStatusSuccess =
            (await Permission.storage.request().isGranted ||
                await Permission.storage.request().isLimited);
      } else {
        isStatusSuccess =
            (await Permission.photos.request().isGranted ||
                await Permission.photos.request().isLimited);
      }
    } else {
      isStatusSuccess =
          (await Permission.photos.request().isGranted ||
              await Permission.photos.request().isLimited);
    }
    return isStatusSuccess;
  }

  void _showAddReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => BlocConsumer<ProductBloc, ProductState>(
            bloc: productBloc,
            listener: (context, state) {
              if (state is AddReviewLoading) {
                loadingToDoneTransitionController.loading();
              } else if (state is AddReviewSuccess) {
                loadingToDoneTransitionController.animateToDone();
                showToast(context, "Review added successfully");

                // Update the local product state with the newly added review
                final Review newReview = Review(
                  rating: _userRating,
                  review: _reviewController.text,
                  images: _selectedImages.map((file) => file.path).toList(),
                  createdAt: DateTime.now(),
                );

                setState(() {
                  if (product.reviews == null) {
                    product.reviews?.clear();
                  }
                  product.reviews?.add(newReview);
                });

                // Clear all things and close the modal after a short delay
                Future.delayed(const Duration(milliseconds: 800), () {
                  _reviewController.clear();
                  _selectedImages.clear();
                  Navigator.pop(context);

                  // Refresh the product details to show the updated review
                  if (product.productID != null) {
                    productBloc.add(
                      FetchProductByIdEvent(id: product.productID!),
                    );
                  }
                });
              }
            },
            builder: (context, state) {
              return StatefulBuilder(
                builder: (context, setStateModal) {
                  return DraggableScrollableSheet(
                    minChildSize: 0.3,
                    initialChildSize: 0.6,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) {
                      return Container(
                        color: AppColors.scaffoldBackground,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Text(
                                    'Give a Review',
                                    style: AppTextStyle.poppinsNormalTextStyle
                                        .copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  // Empty container to balance the row
                                  SizedBox(width: 48.w),
                                ],
                              ),
                            ),

                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // Star rating selector
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            5,
                                            (index) => GestureDetector(
                                              onTap: () {
                                                setStateModal(() {
                                                  _userRating = index + 1.0;
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                ),
                                                child: Icon(
                                                  index < _userRating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 40.sp,
                                                  color:
                                                      index < _userRating
                                                          ? Colors.amber
                                                          : Colors.black
                                                              .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 24.h),

                                      // Detail Review label
                                      Text(
                                        'Detail Review',
                                        style: AppTextStyle
                                            .poppinsNormalTextStyle
                                            .copyWith(
                                              fontSize: 16.sp,
                                              color: Colors.black,
                                            ),
                                      ),

                                      SizedBox(height: 8.h),

                                      // Review text field
                                      AppTextField(
                                        controller: _reviewController,
                                        hintText: 'Write your review here',
                                        maxLines: 5,
                                        textInputAction:
                                            TextInputAction.newline,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        keyboardType: TextInputType.multiline,
                                      ),

                                      SizedBox(height: 24.h),

                                      // Selected images and add photo button
                                      Wrap(
                                        spacing: 12.w,
                                        runSpacing: 12.h,
                                        children: [
                                          // Selected images
                                          ..._selectedImages
                                              .map(
                                                (file) => Stack(
                                                  children: [
                                                    Container(
                                                      width: 80.w,
                                                      height: 80.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        image: DecorationImage(
                                                          image: FileImage(
                                                            file,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: -5,
                                                      right: -5,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setStateModal(() {
                                                            _selectedImages
                                                                .remove(file);
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                blurRadius: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 16,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),

                                          // Add photo button
                                          GestureDetector(
                                            onTap: () async {
                                              await _pickImages();
                                              // Refresh the bottom sheet UI
                                              setStateModal(() {});
                                            },
                                            child: Container(
                                              width: 80.w,
                                              height: 80.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    color:
                                                        AppColors.logoBlueColor,
                                                    size: 32.sp,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    'Add Photo',
                                                    style: AppTextStyle
                                                        .poppinsNormalTextStyle
                                                        .copyWith(
                                                          fontSize: 12.sp,
                                                          color:
                                                              AppColors
                                                                  .logoBlueColor,
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
                              ),
                            ),

                            // Submit button

                            // Continue Button with loading animation
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ).copyWith(
                                bottom:
                                    16.h +
                                    MediaQuery.of(context).viewPadding.bottom,
                              ),
                              child: ButtonAnimatedLoadingWidget(
                                height: 50.h,
                                controller: loadingToDoneTransitionController,
                                border: true,
                                button: AppButton(
                                  buttonText: 'Send Review',
                                  onPressed: () {
                                    // Validate input
                                    if (_reviewController.text.trim().isEmpty) {
                                      showToast(
                                        context,
                                        "Please write a review",
                                        isSuccess: false,
                                      );
                                      return;
                                    }

                                    final Review review = Review(
                                      rating: _userRating,
                                      review: _reviewController.text,
                                      images:
                                          _selectedImages
                                              .map((file) => file.path)
                                              .toList(),
                                    );

                                    productBloc.add(
                                      AddReviewEvent(
                                        productId: product.productID ?? '',
                                        review: review,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
    );
  }

  // Helper method to calculate average rating
  double _calculateAverageRating() {
    if (product.reviews == null || product.reviews!.isEmpty) {
      return 0.0;
    }

    double sum = 0;
    for (var review in product.reviews!) {
      sum += review.rating ?? 0;
    }
    return sum / product.reviews!.length;
  }

  // Helper method to count ratings by star value
  Map<int, int> _countRatingsByStars() {
    final Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    if (product.reviews == null) {
      return counts;
    }

    for (var review in product.reviews!) {
      final rating = review.rating?.round() ?? 0;
      if (rating >= 1 && rating <= 5) {
        counts[rating] = (counts[rating] ?? 0) + 1;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final hasReviews = product.reviews != null && product.reviews!.isNotEmpty;
    final averageRating = _calculateAverageRating();
    final ratingCounts = _countRatingsByStars();
    final totalReviews = product.reviews?.length ?? 0;

    return BlocConsumer<ProductBloc, ProductState>(
      bloc: productBloc,
      listener: (context, state) {
        if (state is ProductDetailLoaded) {
          setState(() {
            product = state.product;
          });
        } else if (state is AddReviewSuccess) {
          // Update UI to reflect the new review if needed
          if (product.productID != null) {
            productBloc.add(FetchProductByIdEvent(id: product.productID!));
          }
        }
      },
      buildWhen:
          (prev, current) =>
              current is ProductDetailLoaded || current is AddReviewSuccess,
      builder: (context, state) {
        // Show loading indicator if in loading state
        if (state is AddReviewLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider line
            Container(height: 1, color: Colors.grey.shade300),

            // Rating header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RATING & REVIEWS",
                        style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          _showAddReviewBottomSheet(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          'Add Review',
                          style: AppTextStyle.poppinsButtonTextStyle.copyWith(
                            color: AppColors.black000000Color,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (hasReviews) ...[
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Average rating
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: AppTextStyle.poppinsTitleTextStyle
                                  .copyWith(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < averageRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "$totalReviews verified ${totalReviews == 1 ? 'Buyer' : 'Buyers'}",
                              style: AppTextStyle.poppinsNormalTextStyle
                                  .copyWith(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        // Rating bars
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingBar(
                                5,
                                ratingCounts[5] ?? 0,
                                totalReviews,
                                Colors.green,
                              ),
                              _buildRatingBar(
                                4,
                                ratingCounts[4] ?? 0,
                                totalReviews,
                                Colors.lightGreen,
                              ),
                              _buildRatingBar(
                                3,
                                ratingCounts[3] ?? 0,
                                totalReviews,
                                Colors.amber,
                              ),
                              _buildRatingBar(
                                2,
                                ratingCounts[2] ?? 0,
                                totalReviews,
                                Colors.orange,
                              ),
                              _buildRatingBar(
                                1,
                                ratingCounts[1] ?? 0,
                                totalReviews,
                                Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),

            // No reviews message
            if (!hasReviews)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 20.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No reviews yet",
                        style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Be the first to review this product",
                        style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Reviews
            if (hasReviews)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    product.reviews!.length > 3 ? 3 : product.reviews!.length,
                itemBuilder: (context, index) {
                  return _buildReviewItem(product.reviews![index]);
                },
              ),

            // View all reviews button
            if (hasReviews && product.reviews!.length > 3)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: TextButton(
                    onPressed: () {


                    },
                    child: Text(
                      "View all ${product.reviews!.length} reviews",
                      style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                        color: AppColors.textBlueColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRatingBar(int rating, int count, int total, Color color) {
    // Handle division by zero
    double fraction = total > 0 ? count / total : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            "$rating ★",
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            count.toString(),
            style: AppTextStyle.poppinsNormalTextStyle.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    final rating = review.rating?.round() ?? 0;

    // Calculate time ago
    String timeAgo = "Recently";
    if (review.createdAt != null) {
      final difference = DateTime.now().difference(review.createdAt!);
      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).round();
        timeAgo = "$months ${months == 1 ? 'month' : 'months'} ago";
      } else if (difference.inDays > 0) {
        timeAgo =
            "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
      } else if (difference.inHours > 0) {
        timeAgo =
            "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Container(height: 8.h, color: Colors.grey.shade100),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating stars
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          rating >= 4
                              ? Colors.green
                              : rating >= 3
                              ? Colors.amber
                              : Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          rating.toString(),
                          style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.star, color: Colors.white, size: 12.sp),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    timeAgo,
                    style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                      color: Colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Review text
              Text(
                review.review ?? "No comment provided",
                style: AppTextStyle.poppinsNormalTextStyle,
              ),
              SizedBox(height: 8.h),

              // Review images
              if (review.images != null && review.images!.isNotEmpty)
                SizedBox(
                  height: 70.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () {
                            _showFullImage(context, review.images![index], index);
                          },
                          child: Hero(
                            tag: review.images![index].hashCode,
                            child: Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: NetworkImage(review.images![index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 8.h),
              // Reviewer name - Replace with actual user name fetching logic
              FutureBuilder<String>(
                future: Future.value(
                  "Anonymous User",
                ), // Replace with user data fetching
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Anonymous User",
                    style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
              // Helpful buttons
              Row(
                children: [
                  Text(
                    "Helpful?",
                    style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                      color: Colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "0", // This would be fetched from backend
                          style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.thumb_down_outlined, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "0", // This would be fetched from backend
                          style: AppTextStyle.poppinsNormalTextStyle.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _showFullImage(BuildContext context, String imageUrl, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Hero(
                tag: imageUrl.hashCode,
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
