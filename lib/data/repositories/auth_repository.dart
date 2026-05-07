import 'package:segundo_parcial/core/constants/app_constants.dart';
import 'package:segundo_parcial/core/utils/crypto_utils.dart';
import 'package:segundo_parcial/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  // Obtener todos los usuaiors registrados
  Future<List<UserModel>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(AppConstants.usersKey) ?? [];
    return usersJson.map((json) => UserModel.fromJson(json)).toList();
  }

  // Guardar lista de usuarios
  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((u) => u.toJson()).toList();
    await prefs.setStringList(AppConstants.usersKey, usersJson);
  }

  // Registrar nuevo usuario
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();

    // Verificar si el email ya existe
    final emailExists = users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) {
      throw Exception('El correo ya esta registrado');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      name: name, 
      email: email.toLowerCase(), 
      hashedPassword: CryptoUtils.hashPassword(password), 
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveUsers(users);
    await _setCurrentUser(newUser);
    return newUser;
  }

  // Iniciar sesion
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();

    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Usuario no encontrado'),
    );

    if (!CryptoUtils.verifyPassword(password, user.hashedPassword)) {
      throw Exception('Contraseña incorrecta');
    }

    await _setCurrentUser(user);
    return user;
  }

  // Guardar usuario actual en sesión
  Future<void> _setCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currentUserKey, user.toJson());
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.currentUserKey);
    if (userJson == null) return null;
    return UserModel.fromJson(userJson);
  }

  // Verificar si hay sesion activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Cerrar sesion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.currentUserKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

}