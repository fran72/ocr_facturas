import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Gemini API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestGeminiScreen(),
    );
  }
}

class TestGeminiScreen extends StatefulWidget {
  const TestGeminiScreen({super.key});

  @override
  State<TestGeminiScreen> createState() => _TestGeminiScreenState();
}

class _TestGeminiScreenState extends State<TestGeminiScreen> {
  final String _apiUrl = 'https://www.latandera.com/gemini/api/analizar-imagen';

  XFile? _imageFile;
  bool _isLoading = false;
  String _statusMessage = 'Selecciona una imagen para probar el endpoint';
  dynamic _jsonResult;

  final ImagePicker _picker = ImagePicker();
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    // Configuración para certificados SSL (solo en plataformas móviles, no en web)
    if (!kIsWeb) {
      (_dio.httpClientAdapter as dynamic).onHttpClientCreate =
          (HttpClient client) {
            client.badCertificateCallback = (
              X509Certificate cert,
              String host,
              int port,
            ) => true;
            return client;
          };
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _imageFile = picked;
        _isLoading = true;
        _statusMessage = 'Subiendo y analizando imagen...';
        _jsonResult = null;
      });

      // 1. Obtenemos los bytes del archivo
      final bytes = await picked.readAsBytes();
      final originalName = picked.name; // Ej: "image_picker_7C9F...jpg" o puede venir sin extensión limpia

      // Nos aseguramos de extraer una extensión válida o por defecto .jpg
      String extension = originalName.contains('.')
          ? originalName.split('.').last.toLowerCase()
          : 'jpg';
      String filename =
          'upload_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // 2. Crear FormData con Dio
      FormData formData = FormData.fromMap({
        // 'prompt': 'Extrae todos los textos de esta imagen', // Tu prompt aquí
        'imagen': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
        ),
      });

      // 3. Enviar petición POST con Dio
      final response = await _dio.post(_apiUrl, data: formData);

      // 4. Procesar respuesta
      if (response.statusCode == 200) {
        final decoded = response.data;
        setState(() {
          _isLoading = false;
          _jsonResult = decoded['data'];
          _statusMessage = '¡Conexión exitosa y procesado correctamente!';
        });
      } else {
        final decoded = response.data;
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Error (${response.statusCode}): ${decoded['error'] ?? response.toString()}';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error Dio: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error de conexión / Excepción: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Endpoint Gemini')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Destino:\n$_apiUrl',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),

            // Previsualización adaptada Web / Móvil
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                          : Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                    )
                  : const Center(
                      child: Text(
                        'Sin imagen seleccionada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickAndUploadImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickAndUploadImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _jsonResult != null
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            if (_jsonResult != null) ...[
              const Text(
                'Respuesta JSON del Servidor:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_jsonResult),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
