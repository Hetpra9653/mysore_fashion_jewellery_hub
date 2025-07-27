import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/dependencyInjector/dependency_injector.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';

import '../../../data/models/category.dart';
import '../../../presentation/pages/lrf/login.dart';

double deviceWidth = 0.0;
double deviceHeight = 0.0;
bool alreadyInUnderMaintenance = false;

void initScreenUtils(BuildContext context) {
  deviceWidth = MediaQuery.of(context).size.width;
  deviceHeight = MediaQuery.of(context).size.height;
}

enum DeviceType {
  web,
  android,
  ios,
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

String getInitials(String name, {bool includeMiddleInitial = false}) {
  if (name.isEmpty) return '';

  final nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();

  // Get initials
  final initials = nameParts.map((part) => part[0].toUpperCase()).take(includeMiddleInitial ? 3 : 2).join('');
  return initials;
}

// Add this to common_methods.dart or where your customCircularProgressIndicator is defined
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

String getCategoryNameById(String? categoryId,) {

  final UserSession userSession = sl<UserSession>();

  if (categoryId == null || categoryId.isEmpty) {
    return 'Unknown Category';
  }
  List<Category> categories = userSession.categories ?? [];
  for (var category in categories) {
    if (category.categoryID == categoryId) {
      return category.name ?? 'Unnamed Category';
    }
  }

  return 'Unknown Category';
}


void showAppBottomSheet({required BuildContext context,required Widget child}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom
      ),
      child: child,
    ),
  );
}

void showLoginBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom
      ),
      child: const LoginBottomSheet(),
    ),
  );
}
