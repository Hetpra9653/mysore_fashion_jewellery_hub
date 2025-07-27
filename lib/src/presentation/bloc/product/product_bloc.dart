import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/get_banner_image_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/review/add_review_usecase.dart';
import 'package:path/path.dart' as path;
import '../../../data/models/product.dart';
import '../../../domain/use_cases/category/get_all_category_usecase.dart';
import '../../../domain/use_cases/product/get_all_product_usecase.dart';
import '../../../domain/use_cases/product/get_product_from_id_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProductsUseCase getAllProducts;
  final GetProductByIdUseCase getProductById;
  final GetAllCategoriesUseCase getAllCategories;
  final GetCategoryByIdUseCase getCategoryById;
  final GetCarouselImagesUseCase getCarouselImages;
  final AddReviewUseCase addReviewUseCase;

  ProductBloc({
    required this.getAllProducts,
    required this.getProductById,
    required this.getAllCategories,
    required this.getCategoryById,
    required this.getCarouselImages,
    required this.addReviewUseCase,
  }) : super(ProductInitial()) {
    on<FetchHomeScreenDataEvent>(_fetchHomeScreenData);
    on<FetchAllProductsEvent>(_fetchAllProducts);
    on<FetchProductByIdEvent>(_fetchProductById);
    on<FetchAllCategoriesEvent>(_fetchAllCategories);
    on<FetchCategoryByIdEvent>(_fetchCategoryById);
    on<AddReviewEvent>(_addReviewEvent);
  }

  Future<void> _fetchHomeScreenData(
    FetchHomeScreenDataEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final productsResult = await getAllProducts.call();
    final categoriesResult = await getAllCategories.call();
    final carouselImagesResult =
        await getCarouselImages.call(); // <-- Fetch carousel images separately

    productsResult.fold((error) => emit(ProductError(message: error)), (
      products,
    ) {
      emit(ProductListLoaded(products: products));
    });

    categoriesResult.fold((error) => emit(CategoryError(message: error)), (
      categories,
    ) {
      emit(CategoryListLoaded(categories: categories));
    });

    emit(
      CarouselImagesLoaded(carouselImages: carouselImagesResult),
    ); // <-- Emit carousel images loaded
  }

  Future<void> _fetchAllProducts(
    FetchAllProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getAllProducts.call();
    result.fold(
      (error) => emit(ProductError(message: error)),
      (products) => emit(ProductListLoaded(products: products)),
    );
  }

  Future<void> _fetchProductById(
    FetchProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProductById.call(event.id);
    result.fold(
      (error) => emit(ProductError(message: error)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  Future<void> _fetchAllCategories(
    FetchAllCategoriesEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(CategoryLoading());
    final result = await getAllCategories.call();
    result.fold(
      (error) => emit(CategoryError(message: error)),
      (categories) => emit(CategoryListLoaded(categories: categories)),
    );
  }

  Future<void> _fetchCategoryById(
    FetchCategoryByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(CategoryLoading());
    final result = await getCategoryById.call(event.id);
    result.fold(
      (error) => emit(CategoryError(message: error)),
      (category) => emit(CategoryDetailLoaded(category: category)),
    );
  }

  Future<void> _addReviewEvent(
    AddReviewEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(AddReviewLoading());

    // Check if user is authenticated
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (firebaseAuth.currentUser == null) {
      debugPrint('User is not authenticated');
      return;
    }

    try {
      final String userId = firebaseAuth.currentUser!.uid;
      List<String> downloadUrls = [];

      // Check if review has images and upload them if needed
      if (event.review.images != null && event.review.images!.isNotEmpty) {
        downloadUrls = await uploadImages(
          imagePaths: event.review.images!,
          productId: event.productId,
          userId: userId,
        );
      }
      debugPrint('Download URLs: $downloadUrls');
      // Example usage in your _addReviewEvent method
      final Review updatedReview = event.review.copyWith(
        userID: userId,
        imageUrls: downloadUrls,
        updatedAt: DateTime.now(),
      );

      final response = await addReviewUseCase.call(
        updatedReview,
        event.productId,
      );

      response.fold((error) => emit(ProductError(message: error)), (product) {
        emit(AddReviewSuccess(product: product));
        emit(ProductDetailLoaded(product: product));
      });
    } catch (e) {
      emit(ProductError(message: 'Failed to add review: ${e.toString()}'));
    }
  }

  Future<List<String>> uploadImages({
    required List<String> imagePaths,
    required String productId,
    required String userId,
  }) async {
    if (imagePaths.isEmpty) return [];

    List<String> downloadUrls = [];

    try {
      // Create the folder path: reviews/productId
      String basePath = 'reviews/$productId';

      for (int i = 0; i < imagePaths.length; i++) {
        String imagePath = imagePaths[i];
        File? imageFile;

        // Handle iOS file paths
        if (Platform.isIOS) {
          // Check if path starts with 'file://'
          if (imagePath.startsWith('file://')) {
            imagePath = imagePath.replaceFirst('file://', '');
          }

          // For PHAsset paths (photos:// scheme)
          if (imagePath.startsWith('ph://')) {
            // You may need to use a plugin like flutter_absolute_path to convert PHAsset to file path
            print('iOS PHAsset path detected. Using as is.');
          }
        }

        try {
          imageFile = File(imagePath);
          if (!await imageFile.exists()) {
            print('File does not exist: $imagePath');
            continue;
          }
        } catch (e) {
          print('Error accessing file: $e');
          continue;
        }

        // Create a unique filename
        String fileExtension =
            path.extension(imagePath).isNotEmpty
                ? path.extension(imagePath).toLowerCase()
                : '.jpg';
        String fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i$fileExtension';

        // Create reference to the image in Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child(basePath)
            .child(fileName);

        // Set metadata
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/${fileExtension.replaceAll('.', '')}',
        );

        print('Starting upload for file: $imagePath');

        // Upload the image
        final UploadTask uploadTask = ref.putFile(imageFile, metadata);

        // Monitor upload progress
        uploadTask.snapshotEvents.listen(
          (TaskSnapshot snapshot) {
            double progress =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            print(
              'Upload progress for $fileName: ${progress.toStringAsFixed(2)}%',
            );
          },
          onError: (e) {
            print('Upload error: $e');
          },
        );

        // Wait for completion
        final TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL
        final url = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(url);
        print('Successfully uploaded: $fileName, URL: $url');
      }

      print('All uploads completed. Total: ${downloadUrls.length}');
      return downloadUrls;
    } catch (e) {
      print('Error in uploadImages: $e');
      rethrow;
    }
  }
}
