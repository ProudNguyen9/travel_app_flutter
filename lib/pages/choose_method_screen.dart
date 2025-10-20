import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/extensions.dart';

class ChooseMethodPayScreen extends StatefulWidget {
  const ChooseMethodPayScreen({super.key});

  @override
  State<ChooseMethodPayScreen> createState() => _ChooseMethodPayScreenState();
}

class _ChooseMethodPayScreenState extends State<ChooseMethodPayScreen> {
  String selected = 'online';

  Widget buildOption(String value, String label) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => setState(() => selected = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E90FF),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E90FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.lato(color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFFF1F1F3),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: SvgPicture.asset(
                      'assets/icons/Arrow.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                  Text(
                    'Make Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1E28),
                    ),
                  ),
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFFF1F1F3),
                      ),
                    ),
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/Notifications.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ],
              ),

              const Gap(30),

              // 🔹 Payment Method
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(15),
              buildOption('online', 'Online Payment'),
              buildOption('direct', 'Direct Transfer'),

              const Gap(25),

              // 🔹 Select Card
              Text(
                "Select Card",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF151111),
                ),
              ),
              const Gap(15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var icon in [
                      'visa.png',
                      'paypal.png',
                      'mastercard.png',
                      'applepay.png'
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/$icon',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Gap(30),

              // 🔹 Card Info
              TextField(
                decoration: inputDecoration("Nguyen Huu Hao"),
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("9990 3456 2104 8999"),
                keyboardType: TextInputType.number,
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("03/28"),
                keyboardType: TextInputType.datetime,
              ),
              const Gap(15),
              TextField(
                decoration: inputDecoration("CVV"),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),

              const Gap(30),

              // 🔹 Continue button
              Center(
                child: SizedBox(
                  width: context.deviceSize.width * 0.8,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {},
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
