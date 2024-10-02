class AssetUtil {
  AssetUtil._();

  static String userPhoto(int userId) {
    return 'packages/core/assets/avatar${userId % 12}.png';
  }

  static String coursePhoto(int courseId) {
    return 'packages/core/assets/course${courseId % 17}.jpg';
  }
}
