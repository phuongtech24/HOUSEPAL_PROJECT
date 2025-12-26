import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/primary_button.dart'; // Import Widget mới

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final Widget nextPage;

  const OtpVerificationPage({super.key, required this.phoneNumber, required this.nextPage});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  void _onVerify() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget.nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFE0F7FA), shape: BoxShape.circle),
                child: const Icon(Icons.lock_person_outlined, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 24),
              const Text("Xác thực số điện thoại", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Vui lòng nhập mã OTP gồm 6 chữ số đã gửi đến số điện thoại\n${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45, height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
                        if (val.isEmpty && index > 0) FocusScope.of(context).previousFocus();
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 20),
              // Timer... (Giữ nguyên)
              
              const Spacer(),
              
              // DÙNG WIDGET MỚI
              PrimaryButton(text: "Bắt đầu ngay ->", onPressed: _onVerify),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}