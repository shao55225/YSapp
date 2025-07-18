import 'package:intl/intl.dart';

/// 格式化工具类，提供各种格式化功能
class FormatUtil {
  /// 格式化价格，保留两位小数
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    return formatter.format(price);
  }
  
  /// 格式化日期时间
  static String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inSeconds < 60) {
        return '刚刚';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}天前';
      } else if (dateTime.year == now.year) {
        return DateFormat('MM-dd HH:mm').format(dateTime);
      } else {
        return DateFormat('yyyy-MM-dd').format(dateTime);
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// 格式化日期
  static String formatDate(DateTime dateTime, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(dateTime);
  }

  /// 格式化时间
  static String formatTime(DateTime dateTime, {String format = 'HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }

  /// 格式化货币
  static String formatCurrency(double amount, {String symbol = '¥', int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// 格式化数字（添加千位分隔符）
  static String formatNumber(num number, {int decimalDigits = 0}) {
    return NumberFormat.decimalPattern().format(number);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 格式化时长（秒转为分:秒）
  static String formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  /// 格式化播放次数
  static String formatPlayCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 10000).toStringAsFixed(1)}W';
    }
  }

  /// 格式化距离现在的时间
  static String formatTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化手机号（中间4位隐藏）
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 11) return phoneNumber;
    return '${phoneNumber.substring(0, 3)}****${phoneNumber.substring(7)}';
  }

  /// 格式化邮箱（部分隐藏）
  static String formatEmail(String email) {
    if (!email.contains('@')) return email;
    
    final List<String> parts = email.split('@');
    String name = parts[0];
    String domain = parts[1];
    
    if (name.length <= 2) {
      return '$name@$domain';
    } else {
      return '${name.substring(0, 2)}***@$domain';
    }
  }
  
  /// 计算对数
  static double log(num x, {num? base}) {
    if (base == null) {
      return _logBase(x, 10);
    }
    return _logBase(x, base);
  }
  
  /// 计算以指定底数的对数
  static double _logBase(num x, num base) => log10(x) / log10(base);
  
  /// 计算以10为底的对数
  static double log10(num x) => _ln(x) / _ln(10);
  
  /// 计算自然对数
  static double _ln(num x) {
    // 使用泰勒级数计算自然对数的近似值
    if (x <= 0) return double.nan;
    
    // 对于接近1的值，使用泰勒级数
    if ((x - 1).abs() < 0.5) {
      double sum = 0;
      double term = (x - 1) / (x);
      double termPower = term;
      for (int i = 1; i <= 10; i++) {
        sum += termPower / i;
        termPower *= term;
      }
      return sum;
    }
    
    // 对于其他值，使用换底公式
    int exponent = 0;
    while (x >= 10) {
      x /= 10;
      exponent++;
    }
    while (x < 1) {
      x *= 10;
      exponent--;
    }
    
    // 现在x在[1,10)范围内
    double lnx = _ln(x);
    return lnx + exponent * _ln(10);
  }
  
  /// 计算乘方
  static double pow(num x, num exponent) {
    if (exponent == 0) return 1;
    if (x == 0) return 0;
    
    bool isNegativeExponent = exponent < 0;
    exponent = exponent.abs();
    
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= x;
    }
    
    return isNegativeExponent ? 1 / result : result;
  }
} 