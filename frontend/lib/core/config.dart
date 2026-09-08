/// 全局配置
class AppConfig {
  /// 后端 base URL
  /// - Android 模拟器调试：10.0.2.2 = 宿主机的 127.0.0.1
  /// - 真机调试：改成宿主机内网 IP（如 http://192.168.1.5:8765）
  /// - iOS 模拟器：127.0.0.1 直通宿主
  /// - 生产：替换为 https://api.xiaolanbook.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8765',
  );

  static const String appName = '小蓝书';
  static const String appSlogan = '记录生活，分享灵感';
}