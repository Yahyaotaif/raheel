import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:raheel/pages/login.dart';
import 'package:raheel/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughPage extends StatefulWidget {
  const WalkthroughPage({super.key});

  @override
  State<WalkthroughPage> createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = <Widget>[
      _buildTab(
        title: 'مرحباً بك في رحيل',
        description: 'احجز رحلاتك بسهولة أو أنشئ رحلة كسائق خلال دقائق.',
        icon: Icons.route,
        colorBegin: const Color(0xFFE9F5F4),
        colorEnd: const Color(0xFFF7FBFB),
      ),
      _buildTab(
        title: 'رحلات المسافرين',
        description: 'ابحث عن وجهتك، راجع التفاصيل، ثم احجز مقعدك بثقة.',
        icon: Icons.event_seat,
        colorBegin: const Color(0xFFF2F6FF),
        colorEnd: const Color(0xFFFBFCFF),
      ),
      _buildTab(
        title: 'لوحة السائق',
        description: 'أنشئ رحلة وحدد المقاعد والوقت، وتابع طلبات الحجز.',
        icon: Icons.drive_eta,
        colorBegin: const Color(0xFFF4F1FF),
        colorEnd: const Color(0xFFFCFBFF),
      ),
      _buildTab(
        title: 'جاهز للانطلاق',
        description: 'يمكنك تغيير اللغة والإعدادات لاحقاً من الملف الشخصي.',
        icon: Icons.rocket_launch,
        colorBegin: const Color(0xFFEAF6EE),
        colorEnd: const Color(0xFFF9FDFB),
      ),
    ];
  }

  Widget _buildTab({
    required String title,
    required String description,
    required IconData icon,
    required Color colorBegin,
    required Color colorEnd,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colorBegin, colorEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(icon, size: 64, color: kAppBarColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walkthrough_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: IntroSlider(
        listCustomTabs: _tabs,
        renderSkipBtn: _buildNavChip('تخطي'),
        renderNextBtn: _buildNavChip('التالي'),
        renderDoneBtn: _buildNavChip('ابدأ'),
        isShowPrevBtn: false,
        navigationBarConfig: NavigationBarConfig(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          backgroundColor: Colors.transparent,
        ),
        onDonePress: _completeWalkthrough,
        onSkipPress: _completeWalkthrough,
        indicatorConfig: const IndicatorConfig(
          colorIndicator: Colors.black26,
          colorActiveIndicator: kAppBarColor,
          sizeIndicator: 6,
          spaceBetweenIndicator: 10,
          typeIndicatorAnimation: TypeIndicatorAnimation.sizeTransition,
        ),
      ),
    );
  }

  Widget _buildNavChip(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: kAppBarColor,
        height: 1.0,
      ),
    );
  }
}
