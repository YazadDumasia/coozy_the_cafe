abstract class ISuspensionBean {
  bool isShowSuspension = false;

  String getSuspensionTag(); //Suspension Tag
}

/// Suspension Util.
class SuspensionUtil {
  /// sort list by suspension tag.
  /// Sort according to [A-Z].
  static void sortListBySuspensionTag(List<ISuspensionBean>? list) {
    if (list == null || list.isEmpty) return;
    list.sort((a, b) {
      if (a.getSuspensionTag() == '@' || b.getSuspensionTag() == '#') {
        return -1;
      } else if (a.getSuspensionTag() == '#' || b.getSuspensionTag() == '@') {
        return 1;
      } else {
        return a.getSuspensionTag().compareTo(b.getSuspensionTag());
      }
    });
  }

  /// get index data list by suspension tag.
  /// Get a list of indexes.
  static List<String> getTagIndexList(List<ISuspensionBean>? list) {
    final List<String> indexData = <String>[];
    if (list != null && list.isNotEmpty) {
      String? tempTag;
      for (int i = 0, length = list.length; i < length; i++) {
        final String tag = list[i].getSuspensionTag();
        if (tempTag != tag) {
          indexData.add(tag);
          tempTag = tag;
        }
      }
    }
    return indexData;
  }

  /// set show suspension status.
  /// Set the display of the hover header state.
  static void setShowSuspensionStatus(List<ISuspensionBean>? list) {
    if (list == null || list.isEmpty) return;
    String? tempTag;
    for (int i = 0, length = list.length; i < length; i++) {
      final String tag = list[i].getSuspensionTag();
      if (tempTag != tag) {
        tempTag = tag;
        list[i].isShowSuspension = true;
      } else {
        list[i].isShowSuspension = false;
      }
    }
  }
}
