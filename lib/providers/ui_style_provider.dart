import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UIStyle {
  material,
  cupertino,
}

class UIStyleNotifier extends StateNotifier<UIStyle> {
  UIStyleNotifier() : super(UIStyle.material);

  void toggleStyle() {
    state = state == UIStyle.material ? UIStyle.cupertino : UIStyle.material;
  }

  bool get isMaterial => state == UIStyle.material;
  bool get isCupertino => state == UIStyle.cupertino;
}

final uiStyleProvider = StateNotifierProvider<UIStyleNotifier, UIStyle>((ref) {
  return UIStyleNotifier();
}); 