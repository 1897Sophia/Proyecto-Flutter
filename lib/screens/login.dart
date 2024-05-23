import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_lll/screens/principal.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  int _loginAttempts = 0;

  Future<bool> checkUserStatus(String username) async {
    final response = await http.get(
      Uri.parse(
        'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Usuarios/estado_usuario/$username',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final isActive = jsonResponse['activo'] == 1;
      return isActive;
    } else {
      return false;
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final loginResponse = await http.post(
      Uri.parse(
          'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Usuarios/login'),
      body: {
        'usuario': username,
        'clave': password,
      },
    );

    if (loginResponse.statusCode == 200) {
      final isActive = await checkUserStatus(username);

      if (!isActive) {
        print('El usuario se encuentra inactivo');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Usuario inactivo'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Su usuario se encuentra inactivo.'),
                    Text('Por favor, comuníquese con el administrador.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Válido');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Principal()),
        );
      }
    } else {
      _showErrorDialog('Usuario y/o contraseña inválidos');
      setState(() {
        _loginAttempts++;
      });

      if (_loginAttempts >= 3) {
        await _inactivateUser(username);
        print('Usuario inactivado: $username');
        _loginAttempts = 0;
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _inactivateUser(String username) async {
    final inactivationUrl =
        'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Usuarios/activar_inactivar_nombre';

    final activationModel =
        UserActivationModel(usuario: username, activar: false);

    final response = await http.put(
      Uri.parse(inactivationUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(activationModel.toJson()),
    );

    if (response.statusCode == 200) {
      print('Usuario inactivado exitosamente: $username');
    } else {
      print('Error al inactivar el usuario: $username');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SWG Películas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_loginAttempts >= 3)
              Text(
                'Su usuario se encuentra inactivo por favor comuníquese con el administrador',
                style: TextStyle(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class UserActivationModel {
  final String usuario;
  final bool activar;

  UserActivationModel({
    required this.usuario,
    required this.activar,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'activar': activar,
    };
  }
}
