import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Powered by Avaru" attribution: AdLease is a product of Avaru Tech
/// Company Limited.
///
/// Shows the official Avaru logo exactly as supplied
/// ([logoAsset], a byte-for-byte copy of the company master; see README,
/// "Brand"). The artwork is only scaled for display: it is never redrawn,
/// cropped, recoloured or replaced. AdLease stays the primary brand, so this
/// is meant for secondary places such as the splash screen footer, Settings
/// and the About dialog.
class PoweredByAvaru extends StatelessWidget {
  /// The official Avaru logo master. Its SHA-256 is checked by
  /// test/brand_test.dart.
  static const String logoAsset = 'assets/brand/avaru-logo-official.png';
  static const String label = 'Powered by Avaru';

  final double logoSize;
  final Color? textColor;

  const PoweredByAvaru({super.key, this.logoSize = 36, this.textColor});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            logoAsset,
            width: logoSize,
            height: logoSize,
            // Decode at the displayed size only, to keep memory use small.
            cacheWidth: (logoSize * dpr).ceil(),
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
