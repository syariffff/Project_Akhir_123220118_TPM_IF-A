import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _userBoxName = 'usersBox';
  static const String _sessionBoxName = 'sessionBox';

  static const String _sessionKey = 'session';
  static const String _usernameKey = 'username';

  String selectedCurrency = 'IDR';
  double currencyRate = 1.0; // default: 1 untuk IDR

  double convertPrice(double price) {
    return price * currencyRate;
  }

  // ===== PASSWORD ENCRYPTION =====

  // Generate random salt untuk setiap password
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Hash password dengan salt menggunakan SHA-256
  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Encrypt password dengan salt
  static Map<String, String> _encryptPassword(String password) {
    final salt = _generateSalt();
    final hashedPassword = _hashPassword(password, salt);
    return {
      'hash': hashedPassword,
      'salt': salt,
    };
  }

  // Verify password dengan hash dan salt yang tersimpan
  static bool _verifyPassword(String password, String storedHash, String storedSalt) {
    final hashedInput = _hashPassword(password, storedSalt);
    return hashedInput == storedHash;
  }

  // ===== USER =====

  // Register user dengan password yang dienkripsi
  static Future<void> register(String username, String email, String password, String profile) async {
    var userBox = Hive.box(_userBoxName);
    
    // Encrypt password
    final encryptedData = _encryptPassword(password);
    
    // Simpan data user dengan password terenkripsi
    await userBox.put(username, {
      'passwordHash': encryptedData['hash'],
      'passwordSalt': encryptedData['salt'],
      'email': email,
      'profile': profile,
    });

    // Menyimpan data di SharedPreferences (tanpa password untuk keamanan)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('profileImageUrl', profile);
    // Tidak menyimpan password di SharedPreferences untuk keamanan
  }

  // Cek apakah user sudah terdaftar
  static Future<bool> isUserRegistered(String username) async {
    var userBox = Hive.box(_userBoxName);
    return userBox.containsKey(username);
  }

  // Validasi login user dan password dengan enkripsi
  static Future<bool> validateLogin(String username, String password) async {
    var userBox = Hive.box(_userBoxName);
    final userData = userBox.get(username);
    
    if (userData == null) return false;
    
    // Jika data lama (string), convert ke format baru
    if (userData is String) {
      // Backward compatibility: jika masih format lama
      return userData == password;
    }
    
    // Format baru dengan enkripsi
    if (userData is Map) {
      final storedHash = userData['passwordHash'];
      final storedSalt = userData['passwordSalt'];
      
      if (storedHash != null && storedSalt != null) {
        return _verifyPassword(password, storedHash, storedSalt);
      }
    }
    
    return false;
  }

  // Get user data (email, profile) berdasarkan username
  static Future<Map<String, dynamic>?> getUserData(String username) async {
    var userBox = Hive.box(_userBoxName);
    final userData = userBox.get(username);
    
    if (userData == null) return null;
    
    // Jika data lama (string), return data minimal
    if (userData is String) {
      return {
        'email': '',
        'profile': 'assets/images/leehan.jpg',
      };
    }
    
    // Format baru
    if (userData is Map) {
      return {
        'email': userData['email'] ?? '',
        'profile': userData['profile'] ?? 'assets/images/leehan.jpg',
      };
    }
    
    return null;
  }

  // Update user data (untuk edit profile)
  static Future<void> updateUserData(String username, {String? email, String? profile}) async {
    var userBox = Hive.box(_userBoxName);
    final userData = userBox.get(username);
    
    if (userData != null && userData is Map) {
      final updatedData = Map<String, dynamic>.from(userData);
      
      if (email != null) updatedData['email'] = email;
      if (profile != null) updatedData['profile'] = profile;
      
      await userBox.put(username, updatedData);
    }
  }

  // Change password (untuk fitur ganti password)
  static Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    // Validasi password lama
    final isValid = await validateLogin(username, oldPassword);
    if (!isValid) return false;
    
    var userBox = Hive.box(_userBoxName);
    final userData = userBox.get(username);
    
    if (userData != null && userData is Map) {
      final encryptedData = _encryptPassword(newPassword);
      final updatedData = Map<String, dynamic>.from(userData);
      
      updatedData['passwordHash'] = encryptedData['hash'];
      updatedData['passwordSalt'] = encryptedData['salt'];
      
      await userBox.put(username, updatedData);
      return true;
    }
    
    return false;
  }

  // ===== SESSION =====

  // Simpan status login dan username
  static Future<void> login(String username) async {
    var sessionBox = Hive.box(_sessionBoxName);
    await sessionBox.put(_sessionKey, true);
    await sessionBox.put(_usernameKey, username);

    // Load user data ke SharedPreferences saat login
    final userData = await getUserData(username);
    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('email', userData['email'] ?? '');
      await prefs.setString('profileImageUrl', userData['profile'] ?? 'assets/images/leehan.jpg');
    }
  }

  // Hapus status login
  static Future<void> logout() async {
    var sessionBox = Hive.box(_sessionBoxName);
    await sessionBox.put(_sessionKey, false);
    await sessionBox.delete(_usernameKey);

    // Clear SharedPreferences saat logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('profileImageUrl');
  }

  // Cek apakah user sedang login
  static Future<bool> checkSession() async {
    var sessionBox = Hive.box(_sessionBoxName);
    return sessionBox.get(_sessionKey, defaultValue: false);
  }

  // Ambil username dari session
  static Future<String?> getUsername() async {
    var sessionBox = Hive.box(_sessionBoxName);
    return sessionBox.get(_usernameKey);
  }

  // ===== MIGRATION =====

  // Migrate old data (jika ada data lama dengan password plain text)
  static Future<void> migrateOldData() async {
    var userBox = Hive.box(_userBoxName);
    final keys = userBox.keys.toList();
    
    for (final key in keys) {
      final userData = userBox.get(key);
      
      // Jika masih format lama (String), convert ke format baru
      if (userData is String) {
        final encryptedData = _encryptPassword(userData);
        
        await userBox.put(key, {
          'passwordHash': encryptedData['hash'],
          'passwordSalt': encryptedData['salt'],
          'email': '',
          'profile': 'assets/images/leehan.jpg',
        });
      }
    }
  }
}