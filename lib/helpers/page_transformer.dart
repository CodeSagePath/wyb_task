import 'package:flutter/material.dart';

class CylindricalPageTransformer extends StatelessWidget {
  final Widget page;
  final double offset;

  const CylindricalPageTransformer({
    super.key,
    required this.page,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    // Adjust the rotation to simulate horizontal swipe effect
    final double rotation = offset * 0.2;
    final double translation = offset * MediaQuery.of(context).size.width * 0.7;

    // Applying 3D transformation for swipe effect
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Slight perspective
      ..rotateY(rotation) // Y-axis rotation for the effect
      ..translate(translation, 0.0, 0.0); // Horizontal translation

    // Adjusting opacity based on offset
    final double opacity = (1 - offset.abs()).clamp(0.0, 1.0);

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: page,
      ),
    );
  }
}



// class CylindricalPageTransformer extends StatelessWidget {
//   final Widget page;
//   final double offset;

//   const CylindricalPageTransformer({super.key, required this.page, required this.offset});

//   @override
//   Widget build(BuildContext context) {
//     // Adjust the rotation to simulate horizontal swipe effect
//     final double rotation = offset * 0.2;
//     final double translation = offset * MediaQuery.of(context).size.width * 0.7;

//     // Applying 3D transformation for swipe effect
//     final Matrix4 transform = Matrix4.identity()
//       ..setEntry(3, 2, 0.001) // Slight perspective
//       ..rotateY(rotation) // Y-axis rotation for the effect
//       ..translate(translation, 0.0, 0.0); // Horizontal translation

//     // Adjusting opacity based on offset
//     final double opacity = (1 - offset.abs()).clamp(0.0, 1.0);

//     return Transform(
//       transform: transform,
//       alignment: Alignment.center,
//       child: Opacity(
//         opacity: opacity,
//         child: page,
//       ),
//     );
//   }
// }
