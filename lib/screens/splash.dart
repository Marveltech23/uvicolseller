import 'package:active_ecommerce_seller_app/app_config.dart';
import 'package:active_ecommerce_seller_app/helpers/aiz_route.dart';
import 'package:active_ecommerce_seller_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_seller_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_seller_app/middlewares/mail_verification_route_middleware.dart';
import 'package:active_ecommerce_seller_app/my_theme.dart';
import 'package:active_ecommerce_seller_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_seller_app/screens/home.dart';
import 'package:active_ecommerce_seller_app/screens/login.dart';
import 'package:active_ecommerce_seller_app/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    _initPackageInfo();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (e) {
      // Handle error gracefully - use default values
      print('Error getting package info: $e');
      if (mounted) {
        setState(() {
          _packageInfo = PackageInfo(
            appName: AppConfig.app_name,
            packageName: 'com.example.app',
            version: '1.0.0',
            buildNumber: '1',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSplashScreen(
      //comment this
      seconds: 3,
      //comment this
      navigateAfterSeconds: access_token.$!.isNotEmpty ? Home() : Login(),
      //navigateAfterFuture: loadFromFuture(), //uncomment this
      version: Text(
        "version ${_packageInfo.version}",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11.0,
            color: MyTheme.app_accent_border),
      ),
      useLoader: false,
      loadingText: Text(
        AppConfig.app_name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      image: Image.asset(
        "assets/logo/white_logo.png",
        width: 54,
        height: 72,
      ),
      backgroundColor: MyTheme.splash_screen_color,
      backgroundPhotoSize: 120.0,
      photoSize: 55,
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  /// Seconds to navigate after for time based navigation
  final int? seconds;

  /// App version, shown in the middle of screen in case of no image available
  final Text version;

  /// Page background color
  final Color backgroundColor;

  /// Style for the laodertext
  final TextStyle styleTextUnderTheLoader;

  /// The page where you want to navigate if you have chosen time based navigation
  final dynamic navigateAfterSeconds;

  /// Main image size
  final double? photoSize;

  final double? backgroundPhotoSize;

  /// Triggered if the user clicks the screen
  final dynamic onClick;

  /// Loader color
  final Color? loaderColor;

  /// Main image mainly used for logos and like that
  final Image? image;

  final Image? backgroundImage;

  /// Loading text, default: "Loading"
  final Text loadingText;

  ///  Background image for the entire screen
  final ImageProvider? imageBackground;

  /// Background gradient for the entire screen
  final Gradient? gradientBackground;

  /// Whether to display a loader or not
  final bool useLoader;

  /// Custom page route if you have a custom transition you want to play
  final Route? pageRoute;

  /// RouteSettings name for pushing a route with custom name (if left out in MaterialApp route names) to navigator stack (Contribution by Ramis Mustafa)
  final String? routeName;

  /// expects a function that returns a future, when this future is returned it will navigate
  final Future<dynamic>? navigateAfterFuture;
  final Function? afterSplashScreen;

  /// Use one of the provided factory constructors instead of.
  @protected
  CustomSplashScreen({
    this.loaderColor,
    this.navigateAfterFuture,
    this.seconds,
    this.photoSize,
    this.backgroundPhotoSize,
    this.pageRoute,
    this.onClick,
    this.navigateAfterSeconds,
    this.version = const Text(''),
    this.backgroundColor = Colors.white,
    this.styleTextUnderTheLoader = const TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    this.image,
    this.backgroundImage,
    this.loadingText = const Text(""),
    this.imageBackground,
    this.gradientBackground,
    this.useLoader = true,
    this.routeName,
    this.afterSplashScreen,
  });

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await access_token.load();
      final result = await AuthHelper().fetch_and_set();

      if (!mounted) return;

      if (result.result != null && result.result!) {
        AIZRoute.pushAndRemoveAll(context, Main(),
            middleware: MailVerificationRouteMiddleware());
      } else {
        AIZRoute.pushAndRemoveAll(context, Login());
      }
    } catch (e) {
      print('Error during app initialization: $e');
      // Fallback to login screen on error
      if (mounted) {
        AIZRoute.pushAndRemoveAll(context, Login());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: widget.onClick,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: widget.imageBackground == null
                    ? null
                    : DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.imageBackground!,
                ),
                gradient: widget.gradientBackground,
                color: widget.backgroundColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.image,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.loadingText,
                        ),
                        widget.version,
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}