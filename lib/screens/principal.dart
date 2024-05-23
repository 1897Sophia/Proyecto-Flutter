import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Principal());
}

class Principal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Películas SWG',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ScreenLogin(),
    );
  }
}

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final TextEditingController _searchController = TextEditingController();
  BusquedaPelicula? _searchedMovie;

  Future<BusquedaPelicula?> _buscarPelicula(String nombrePelicula) async {
    final response = await http.get(Uri.parse(
        'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Peliculas/BuscarPeliculaPorNombre?nombrePelicula=$nombrePelicula'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.isNotEmpty) {
        return BusquedaPelicula.fromJson(jsonResponse[0]);
      } else {
        return null; // Devolver null si no se encuentra ninguna película
      }
    } else {
      print('Error al buscar la película');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Películas'),
        actions: [
          IconButton(
            onPressed: () async {
              BusquedaPelicula? movie =
                  await _buscarPelicula(_searchController.text);
              if (movie != null) {
                setState(() {
                  _searchedMovie = movie;
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('No se encontraron películas'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: Icon(Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar películas',
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onSubmitted: (_) {
                // Lógica para la búsqueda al presionar Enter en el teclado
              },
            ),
          ),
        ),
      ),
      body: _searchedMovie != null
          ? _buildSearchedMovie()
          : _buildPeliculasRecientes(),
    );
  }

  Widget _buildSearchedMovie() {
    return ListView(
      children: [
        Card(
          child: ListTile(
            leading: Image.network(_searchedMovie!.poster),
            title: Text(_searchedMovie!.nombre),
            subtitle: Text(
              _searchedMovie!.descripcion +
                  "\n Fecha: \n" +
                  _searchedMovie!.fecha,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeliculasRecientes() {
    return FutureBuilder<List<Pelicula>>(
      future: _obtenerPeliculas(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Pelicula>? peliculas = snapshot.data;
          return ListView.builder(
            itemCount: peliculas!.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Image.network(peliculas[index].poster),
                  title: Text(peliculas[index].nombrePelicula),
                  subtitle: Text(
                    peliculas[index].descripcion +
                        "\n Involucrados: \n" +
                        peliculas[index].involucrados +
                        "\n Fecha: \n" +
                        peliculas[index].fecha,
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar las películas'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<List<Pelicula>> _obtenerPeliculas() async {
    final response = await http.get(Uri.parse(
        'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Peliculas/ObtenerPeliculasRecientes'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Pelicula.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar las películas');
    }
  }
}

class Pelicula {
  final int idPelicula;
  final String poster;
  final String nombrePelicula;
  final String descripcion;
  final String fecha;
  final String involucrados;
  final String comentarios;
  final String calificaciones;

  Pelicula({
    required this.idPelicula,
    required this.poster,
    required this.nombrePelicula,
    required this.descripcion,
    required this.fecha,
    required this.involucrados,
    required this.comentarios,
    required this.calificaciones,
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      idPelicula: json['idPelicula'],
      poster: json['poster'],
      nombrePelicula: json['nombrePelicula'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      involucrados: json['involucrados'] ?? '',
      comentarios: json['comentarios'] ?? '',
      calificaciones: json['calificaciones'] ?? '',
    );
  }
}

class BusquedaPelicula {
  final int idPelicula;
  final String poster;
  final String nombre;
  final String descripcion;
  final String fecha;

  BusquedaPelicula({
    required this.idPelicula,
    required this.poster,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
  });

  factory BusquedaPelicula.fromJson(Map<String, dynamic> json) {
    return BusquedaPelicula(
      idPelicula: json['idPelicula'],
      poster: json['poster'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
    );
  }
}
