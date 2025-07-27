import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_icons.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_text_styles.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/fetch_user_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/cart/cart_page.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/home/home_screen.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/lrf/Profile_screen.dart';
import '../../data/dependencyInjector/dependency_injector.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FetchUserUseCase fetchUserUseCase = sl<FetchUserUseCase>();
  final UserSession userSession = sl<UserSession>();
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Method to navigate to home page
  void _navigateToHome() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Getter for pages - moved to a method so it can access instance methods
  List<Widget> get _pages => [
    const HomeScreen(),
    const Center(child: Text('Categories Page')),
    const Center(child: Text('Brands Page')),
    BagScreen(
      onBackPressed: _navigateToHome, // Now this works!
    ),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    getUserInformation();
    super.initState();
  }

  getUserInformation() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      // User is signed in
      final String userId = user.uid;
      fetchUserUseCase.call(userId).then((result) {
        result.fold(
              (error) {
            // Handle error
            if (kDebugMode) {
              print('Error fetching user: $error');
            }
          },
              (user) {
            userSession.setUser(user);
            // User data is available
            if (kDebugMode) {
              print('User data: ${user.toJson()}');
            }
          },
        );
      });
    } else {
      // No user is signed in
      if (kDebugMode) {
        print('No user is signed in.');
      }
    }
  }

  void _onTabTapped(int index) {
    // Animate to the selected page with a slide effect
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children:
        _pages.map((page) => SlidePageTransition(child: page)).toList(),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// Custom Page Transition for Slide Left
class SlidePageTransition extends StatelessWidget {
  final Widget child;

  const SlidePageTransition({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// Custom Route for Slide Left Transition
class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;

  SlideLeftRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bottom Navigation Bar
              Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  onTap: onTap,
                  currentIndex: currentIndex,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  selectedLabelStyle: AppTextStyle.poppinsNormalTextStyle
                      .copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: AppTextStyle.poppinsNormalTextStyle
                      .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w400),
                  enableFeedback: false,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF0A2159),
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(AppIcons.homeIcon, 0),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(AppIcons.categoriesIcon, 1),
                      label: 'Categories',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(AppIcons.brandIcon, 2),
                      label: 'Brands',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(AppIcons.bagIcon, 3),
                      label: 'Cart',
                    ),
                    BottomNavigationBarItem(
                      icon:
                      currentIndex == 4
                          ? const Icon(
                        Icons.person,
                        color: Color(0xFF0A2159),
                      )
                          : const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String iconPath, int index) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? const Color(0xFF0A2159) : Colors.grey;

    return SvgPicture.asset(
      iconPath,
      height: 18.h,
      width: 18.w,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}