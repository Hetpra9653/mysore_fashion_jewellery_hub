import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/common/common_methods.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';

import '../../../data/dependencyInjector/dependency_injector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserSession userSession = sl<UserSession>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    isLoggedIn = auth.currentUser != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time, battery icons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: AppColors.black333333Color),
                    ),
                  ],
                ),
              ),

              // Profile header with blue background
              Container(
                width: double.infinity,
                color: AppColors.logoBlueColor,
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // Profile image
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Image.asset(
                          'assets/images/profile_placeholder.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 40.sp, color: AppColors.logoBlueColor);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Name and email
                    isLoggedIn
                        ? Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userSession.user?.name ?? "",
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                userSession.user?.email ?? "",
                                style: TextStyle(fontSize: 14.sp, color: Colors.white),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                userSession.user?.phone ?? "",
                                style: TextStyle(fontSize: 14.sp, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                        : InkWell(
                        onTap: () {
                          showLoginBottomSheet(context);
                        },
                        child: QuickAccessButton(label: 'Login/Sign Up', icon: Icons.login_outlined)),
                    // Edit button
                    if (isLoggedIn)
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
                        padding: EdgeInsets.all(8.w),
                        child: Icon(Icons.edit_outlined, color: Colors.white, size: 20.sp),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // Menu items
              ProfileMenuItem(icon: Icons.shopping_bag_outlined, title: "Orders", subtitle: "Check your order status"),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              ProfileMenuItem(
                icon: Icons.headset_mic_outlined,
                title: "Help Center",
                subtitle: "Help regarding your recent purchase",
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              ProfileMenuItem(
                icon: Icons.favorite_border_outlined,
                title: "Wishlist",
                subtitle: "Your most loved styles",
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              ProfileMenuItem(icon: Icons.settings_outlined, title: "Settings", subtitle: "Manage Notifications"),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              SizedBox(height: 16.h),

              // Footer items
              FooterMenuItem(title: "FAQS"),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              FooterMenuItem(title: "ABOUT US"),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              FooterMenuItem(title: "TERMS OF USE"),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              FooterMenuItem(title: "PRIVACY POLICY"),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickAccessButton({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right, size: 16.sp),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileMenuItem({Key? key, required this.icon, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.black333333Color),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.black333333Color),
                ),
                SizedBox(height: 4.h),
                Text(subtitle, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FooterMenuItem extends StatelessWidget {
  final String title;

  const FooterMenuItem({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.black333333Color),
            ),
          ),
          Icon(Icons.chevron_right, size: 20.sp),
        ],
      ),
    );
  }
}
