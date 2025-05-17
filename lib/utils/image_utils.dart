import 'dart:math';
import 'package:flutter/material.dart';

class ImageUtils {
  static final List<String> placeholderImages = [
    "https://camo.githubusercontent.com/5a03084fafec21ac62b3746ddbc9f38c9a7ec1f8024be719178ce9a5cb3edebf/68747470733a2f2f6176617461722e6972616e2e6c696172612e72756e2f7075626c69632f626f793f757365726e616d653d53636f7474",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBzwZ-pkjd0Jmp-Z6iuxuueVArq8Sbz56pbEDDG3WdholeLBppYn-DgaEHt9sDxC1yqL0&usqp=CAU",
    "https://bundui-images.netlify.app/avatars/10.png",
    "https://avatar.iran.liara.run/public/61",
    "https://avatar.iran.liara.run/public/68"
  ];

  static String getRandomPlaceholderImage() {
    final random = Random();
    return placeholderImages[random.nextInt(placeholderImages.length)];
  }

  static Widget getPlaceholderImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      getRandomPlaceholderImage(),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
