import 'package:flutter/material.dart';

class OrderDetailsWidget extends StatelessWidget {
  final double bagTotal;
  final double bagSavings;
  final double deliveryFee;
  final double amountPayable;
  final String currency;

  const OrderDetailsWidget({
    Key? key,
    required this.bagTotal,
    required this.bagSavings,
    required this.deliveryFee,
    required this.amountPayable,
    this.currency = '₹',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ZigzagBorderPainter(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        // Remove decoration - let CustomPaint handle the background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'ORDER DETAILS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // Bag Total
            _buildOrderRow(
              'Bag Total',
              bagTotal,
              isRegular: true,
            ),
            const SizedBox(height: 16),

            // Bag Savings
            _buildOrderRow(
              'Bag Savings',
              bagSavings,
              isRegular: true,
              isSavings: true,
            ),
            const SizedBox(height: 16),

            // Delivery Fee
            _buildOrderRow(
              'Delivery Fee',
              deliveryFee,
              isRegular: true,
            ),
            const SizedBox(height: 24),

            // Amount Payable (larger and bold)
            _buildOrderRow(
              'Amount Payable',
              amountPayable,
              isRegular: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(
      String label,
      double amount,
      {
        required bool isRegular,
        bool isSavings = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isRegular ? 16 : 18,
            fontWeight: isRegular ? FontWeight.w500 : FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Row(
          children: [
            if (isSavings)
              Text(
                '- ',
                style: TextStyle(
                  fontSize: isRegular ? 16 : 18,
                  fontWeight: isRegular ? FontWeight.w500 : FontWeight.w600,
                  color: const Color(0xFFD2691E), // Orange color for savings
                ),
              ),
            Text(
              '$currency ${_formatAmount(amount)}',
              style: TextStyle(
                fontSize: isRegular ? 16 : 18,
                fontWeight: isRegular ? FontWeight.w500 : FontWeight.w600,
                color: isSavings
                    ? const Color(0xFFD2691E) // Orange color for savings
                    : Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    // Format number with commas for Indian number system
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts[1];

    // Add commas to whole part
    String formattedWhole = '';
    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        formattedWhole += ',';
      }
      formattedWhole += wholePart[i];
    }

    return '$formattedWhole.$decimalPart';
  }
}

// Custom painter for zigzag border
class ZigzagBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =  Color(0xffF7ECDB)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, 20); // Go up to where zigzag starts

    // Create zigzag pattern across the top
    double zigzagHeight = 20;
    double zigzagWidth = 20;
    int zigzagCount = (size.width / zigzagWidth).floor();

    for (int i = 0; i < zigzagCount; i++) {
      double x = i * zigzagWidth;
      if (i % 2 == 0) {
        // Peak up
        path.lineTo(x + zigzagWidth / 2, 0);
        path.lineTo(x + zigzagWidth, 20);
      } else {
        // Peak down
        path.lineTo(x + zigzagWidth / 2, 20);
        path.lineTo(x + zigzagWidth, 0);
      }
    }

    // Complete the remaining width if any
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

