import 'package:flutter/material.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../widgets/chore_widgets.dart';

class CreateChoreSuccessPage extends StatelessWidget {
  const CreateChoreSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // SUCCESS ICON
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: kPrimaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Việc nhà đã được tạo\nthành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Mọi người trong nhà đã nhận được\nthông báo này.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kGreyText,
              ),
            ),

            const Spacer(),

            // ===== BUTTON: VIEW CHORES =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // ❗ QUAN TRỌNG
                    Navigator.pop(context); // đóng success page
                    Navigator.pushReplacementNamed(context, '/chores');
                  },
                  child: const Text(
                    'Xem việc nhà',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== BUTTON: CLOSE =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1E4EA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      bottomNavigationBar: const HousePalBottomNav(
        currentIndex: 1,
        isSubPage: true,
      ),
    );
  }
}
