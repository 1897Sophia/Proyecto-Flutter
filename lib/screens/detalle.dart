import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetallePelicula extends StatefulWidget {
  final int idPelicula;

  const DetallePelicula({Key? key, required this.idPelicula}) : super(key: key);

  @override
  State<DetallePelicula> createState() => _DetallePeliculaState();
}

class _DetallePeliculaState extends State<DetallePelicula> {
  late Pelicula _detallePelicula;

  @override
  void initState() {
    super.initState();
    _detallePelicula = Pelicula(); // Inicializa _detallePelicula aquí
    _obtenerDetallesPelicula(widget.idPelicula);
  }

  Future<void> _obtenerDetallesPelicula(int idPelicula) async {
    final response = await http.get(Uri.parse(
        'https://tiusr23pl.cuc-carrera-ti.ac.cr/Peliculas/api/Peliculas/ObtenerPeliculaPorId/$idPelicula'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _detallePelicula = Pelicula.fromJson(jsonResponse);
      });
    } else {
      print('Error al obtener los detalles de la película');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Película'),
      ),
      body: _buildDetallePelicula(),
    );
  }

  Widget _buildDetallePelicula() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_detallePelicula.idPelicula != null) ...[
            Image.network(_detallePelicula.poster),
            SizedBox(height: 16.0),
            Text(
              _detallePelicula.titulo,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Fecha: ${_detallePelicula.fecha}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Descripción: ${_detallePelicula.descripcion}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Involucrados: ${_detallePelicula.involucrados}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Comentarios: ${_detallePelicula.comentarios}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
          if (_detallePelicula.idPelicula == null) ...[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 16.0),
            Text(
              'Cargando detalles de la película...',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ],
      ),
    );
  }
}

class Pelicula {
  int? idPelicula;
  String titulo = '';
  String poster = '';
  String descripcion = '';
  String fecha = '';
  List<Involucrado> involucrados = [];
  List<Comentario> comentarios = [];

  Pelicula();

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    List<Involucrado> parseInvolucrados(involucrados) {
      return involucrados
          .map<Involucrado>(
              (involucrado) => Involucrado.fromJson(involucrado['involucrado']))
          .toList();
    }

    List<Comentario> parseComentarios(comentarios) {
      return comentarios
          .map<Comentario>((comentario) => Comentario.fromJson(comentario))
          .toList();
    }

    return Pelicula()
      ..idPelicula = json['idPelicula']
      ..titulo = json['titulo'] ?? ''
      ..poster = json['poster'] ?? ''
      ..descripcion = json['descripcion'] ?? ''
      ..fecha = json['fecha'] ?? ''
      ..involucrados = parseInvolucrados(json['involucrados'])
      ..comentarios = parseComentarios(json['comentarios']);
  }
}

class Critico {
  final int idCritico;
  final String nombreCritico;
  final int calificacion;

  Critico({
    required this.idCritico,
    required this.nombreCritico,
    required this.calificacion,
  });

  factory Critico.fromJson(Map<String, dynamic> json) {
    return Critico(
      idCritico: json['idCritico'],
      nombreCritico: json['nombreCritico'] ?? '',
      calificacion: json['calificacion'] ?? 0,
    );
  }
}

class Involucrado {
  final InvolucradoDetalle involucrado;

  Involucrado({required this.involucrado});

  factory Involucrado.fromJson(Map<String, dynamic> json) {
    return Involucrado(
      involucrado: InvolucradoDetalle.fromJson(json['involucrado']),
    );
  }
}

class InvolucradoDetalle {
  final int idInvolucrado;
  final String nombre;
  final String apellidos;
  final String facebook;
  final String instagram;
  final String twitter;
  final String otros;
  final String rol;

  InvolucradoDetalle({
    required this.idInvolucrado,
    required this.nombre,
    required this.apellidos,
    required this.facebook,
    required this.instagram,
    required this.twitter,
    required this.otros,
    required this.rol,
  });

  factory InvolucradoDetalle.fromJson(Map<String, dynamic> json) {
    return InvolucradoDetalle(
      idInvolucrado: json['idInvolucrado'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      otros: json['otros'] ?? '',
      rol: json['rol'] ?? '',
    );
  }
}

class Comentario {
  final int idComentario;
  final String nombreUsuario;
  final String comentarioTexto;
  final String fecha;
  final List<Comentario> respuestas;

  Comentario({
    required this.idComentario,
    required this.nombreUsuario,
    required this.comentarioTexto,
    required this.fecha,
    required this.respuestas,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    List<Comentario> parseRespuestas(respuestas) {
      return respuestas
          .map<Comentario>((respuesta) => Comentario.fromJson(respuesta))
          .toList();
    }

    return Comentario(
      idComentario: json['idComentario'],
      nombreUsuario: json['nombreUsuario'] ?? '',
      comentarioTexto: json['comentarioTexto'] ?? '',
      fecha: json['fecha'] ?? '',
      respuestas: parseRespuestas(json['respuestas']),
    );
  }
}
