import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_icons.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_images.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/brands.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/product.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/home/%20widgets/banner_widgets.dart';

import ' widgets/home_screen_shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/common/common_methods.dart';
import '../../../data/dependencyInjector/dependency_injector.dart';
import '../../../data/models/category.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode searchFocusNode = FocusNode();

  final UserSession userSession = sl<UserSession>();

  final ProductBloc productBloc = sl<ProductBloc>();

  List<Product> products = [];
  List<Category> categories = [];
  List<String> carouselImages = [];
  List<Brands> brands = [];
  bool isLoading = true; // Add loading flag

  @override
  void initState() {
    productBloc.add(FetchHomeScreenDataEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'MFJH',
          style: AppTextStyle.poppinsTitleTextStyle.copyWith(
            fontSize: 28.sp,
            color: AppColors.logoBlueColor,
          ),
        ),
        leadingWidth: 40.w,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              AppIcons.hamburgerIcon,
              height: 24.h,
              width: 24.w,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              AppIcons.notificationIcon,
              height: 24.h,
              width: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              AppIcons.wishlistIcon,
              height: 24.h,
              width: 24.w,
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        bloc: productBloc, // Explicitly specify the bloc
        listener: (context, state) {
          if (state is ProductListLoaded) {
            setState(() {
              products = state.products;
              userSession.setProducts(products);
            });
          } else if (state is CategoryListLoaded) {
            setState(() {
              categories = state.categories;
              userSession.setCategories(categories);
              isLoading =
                  false; // Set loading to false when categories are loaded
            });
          } else if (state is ProductError) {
            setState(() {
              isLoading = false; // Also set loading to false on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CategoryError) {
            setState(() {
              isLoading = false; // Also set loading to false on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProductLoading ||
              state is CategoryLoading ||
              state is BrandLoading) {
            setState(() {
              isLoading = true; // Ensure loading is true for loading states
            });
          } else if (state is CarouselImagesLoaded) {
            carouselImages = state.carouselImages;
          } else if (state is BrandListLoaded) {
            brands = state.brands;
          }
        },
        builder: (context, state) {
          // Check the isLoading flag first
          if (isLoading) {
            return const HomeScreenShimmer();
          } else if (products.isNotEmpty && categories.isNotEmpty) {
            // Only show content when both products and categories are loaded
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar
                  SearchBarWidget(searchFocusNode: searchFocusNode),

                  // Banner Section
                  BannerWidget(bannerImages: carouselImages),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background image
                      Positioned.fill(
                        child: SvgPicture.asset(
                          AppImages.bgDesign,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          CategorySection(categories: categories),

                          // Featured Products Grid
                          FeaturedProductsGrid(products: products),
                        ],
                      ),
                    ],
                  ),

                  // Category Section

                  // Recently Viewed Section
                  AllProductsSection(products: products),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'No Data Available',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
        },
      ),
    );
  }
}
// Common Widgets

class SearchBarWidget extends StatefulWidget {
  final FocusNode searchFocusNode;
  const SearchBarWidget({super.key, required this.searchFocusNode});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: const Color(0xFF0A2159),
      child: TextField(
        focusNode: widget.searchFocusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search By Product, Brand & More...',
          hintStyle: AppTextStyle.poppinsNormalTextStyle.copyWith(
            color: AppColors.whiteColor,
          ),
          filled: true,
          fillColor: const Color(0xFF0A2159),
          prefixIcon: Icon(Icons.search, color: Colors.white, size: 20.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
        ),
        style: AppTextStyle.poppinsNormalTextStyle.copyWith(
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final List<Category> categories;

  const CategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0E6).withOpacity(0.6),
      width: double.infinity,
      child: Container(
        height: 110.h, // Fixed height for the category section
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              width: 70.w, // Fixed width for each category item
              margin: EdgeInsets.only(right: 16.w),
              child: CategoryItem(
                categoryImage: categories[index].categoryImage ?? '',
                name: categories[index].name ?? '',
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String categoryImage;
  final String name;

  const CategoryItem({
    super.key,
    required this.categoryImage,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AppImages.categoryRing, fit: BoxFit.cover),
              Padding(
                padding: EdgeInsets.all(2.r),
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: Image.network(
                      key: UniqueKey(),
                      categoryImage,
                      fit: BoxFit.cover,
                      width: 46.w,
                      height: 46.h,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 20.r,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          name,
          style: AppTextStyle.rosarioNormalTextStyle.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black222222Color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class FeaturedProductsGrid extends StatelessWidget {
  final List<Product> products;
  const FeaturedProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Text(
              'Our Exclusive Collection',
              style: AppTextStyle.poppinsTitleTextStyle.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: 6,
            itemBuilder:
                (context, index) => FeaturedProductItem(
                  imageUrl: products[index].images?.first ?? '',
                  name: 'Name',
                ),
          ),
        ],
      ),
    );
  }
}

class FeaturedProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;

  const FeaturedProductItem({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 130.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          name,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class AllProductsSection extends StatefulWidget {
  final List<Product> products;
  const AllProductsSection({super.key, required this.products});

  @override
  State<AllProductsSection> createState() => _AllProductsSectionState();
}

class _AllProductsSectionState extends State<AllProductsSection> {
  final UserSession usersession = sl<UserSession>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Products',
            style: AppTextStyle.poppinsTitleTextStyle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: widget.products.length,
            itemBuilder:
                (context, index) => ProductCard(
                  product: widget.products[index],
                  category: getCategoryNameById(
                    widget.products[index].categoryID,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final String category;

  const ProductCard({super.key, required this.product, required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle product tap
        context.push(
          AppRoutes.productDetails,
          extra: {AppConstants.productId: product.productID},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.w),
        ),
        margin: EdgeInsets.zero,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with fixed height
            Container(
              margin: EdgeInsets.all(3.sp),
              height: 180.h, // Fixed height for image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.images?.first ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content section with constrained height
            Container(
              decoration: BoxDecoration(
                color: Colors.white,

                /// remove bottom border
                border: Border(
                  top: BorderSide(color: Colors.black, width: 1.w),
                ),
              ),

              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        product.discountPrice != null &&
                                product.discountPrice!.isNotEmpty
                            ? '₹${product.discountPrice}'
                            : '₹${product.price}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.discountPrice != null &&
                          product.price != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Text(
                            '₹${product.price}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    category,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
