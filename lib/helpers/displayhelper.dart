import 'package:hellclientui/workers/game.dart';

class DisplayHelper {
  bool isHudVisible(Game game) {
    if (game.showAllLines &&
        game.renderSettings.isAlllinesInline() &&
        game.renderSettings.isAlllinesInlineTop()) {
      return false;
    }
    return true;
  }
}
