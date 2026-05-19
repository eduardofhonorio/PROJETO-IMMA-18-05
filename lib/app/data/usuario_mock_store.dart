

import '../../features/auth/model/usuario_model.dart';

class UsuarioMockStore {
  static final UsuarioMockStore _instance = UsuarioMockStore._internal();
  factory UsuarioMockStore() => _instance;
  UsuarioMockStore._internal();

  final List<UsuarioModel> usuarios = [];

  void cadastrar(UsuarioModel usuario) {
    usuarios.add(usuario);
  }

  bool autenticar(String email, String senha) {
    return usuarios.any((u) => u.email == email && u.senha == senha);
  }
}