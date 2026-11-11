// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// // import 'package:http/http.dart' as http;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Test Gemini API',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const TestGeminiScreen(),
//     );
//   }
// }

// class TestGeminiScreen extends StatefulWidget {
//   const TestGeminiScreen({super.key});

//   @override
//   State<TestGeminiScreen> createState() => _TestGeminiScreenState();
// }

// class _TestGeminiScreenState extends State<TestGeminiScreen> {
//   // Tu endpoint definitivo en cPanel
//   final String _apiUrl = 'https://www.latandera.com/gemini/api/analizar-imagen';

//   XFile? _imageFile;
//   bool _isLoading = false;
//   String _statusMessage = 'Selecciona una imagen para probar el endpoint';
//   Map<String, dynamic>? _jsonResult;

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickAndUploadImage(ImageSource source) async {
//     try {
//       // 1. Abrir cámara o galería
//       final XFile? picked = await _picker.pickImage(
//         source: source,
//         imageQuality: 85, // Comprimir un poco para agilizar el envío
//       );

//       if (picked == null) return;

//       setState(() {
//         _imageFile = picked;
//         _isLoading = true;
//         _statusMessage = 'Subiendo y analizando imagen...';
//         _jsonResult = null;
//       });

//       // 2. Crear la petición HTTP POST Multipart
//       var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

//       // Adjuntar archivo con la clave 'imagen' (que espera tu backend con multer)
//       request.files.add(
//         await http.MultipartFile.fromPath('imagen', picked.path),
//       );

//       // 3. Enviar petición
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       // 4. Procesar respuesta
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         setState(() {
//           _isLoading = false;
//           _jsonResult = decoded['data'];
//           _statusMessage = '¡Conexión exitosa y procesado correctamente!';
//         });
//       } else {
//         final decoded = jsonDecode(response.body);
//         setState(() {
//           _isLoading = false;
//           _statusMessage =
//               'Error (${response.statusCode}): ${decoded['error'] ?? response.body}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _statusMessage = 'Error de conexión / Excepción: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Endpoint Gemini')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             Text(
//               'Destino:\n$_apiUrl',
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey,
//                 fontFamily: 'monospace',
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Contenedor de previsualización
//             Container(
//               height: 240,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.shade400),
//               ),
//               child: _imageFile != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.file(
//                         File(_imageFile!.path),
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                   : const Center(
//                       child: Text(
//                         'Sin imagen seleccionada',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 20),

//             // Botones de acción
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading
//                         ? null
//                         : () => _pickAndUploadImage(ImageSource.camera),
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Cámara'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading
//                         ? null
//                         : () => _pickAndUploadImage(ImageSource.gallery),
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text('Galería'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Estado de la petición
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else
//               Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   color: _jsonResult != null
//                       ? Colors.green.shade700
//                       : Colors.red.shade700,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//             const SizedBox(height: 20),

//             // Resultado JSON devuelto por el servidor
//             if (_jsonResult != null) ...[
//               const Text(
//                 'Respuesta JSON del Servidor:',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade900,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: SelectableText(
//                   const JsonEncoder.withIndent('  ').convert(_jsonResult),
//                   style: const TextStyle(
//                     color: Colors.greenAccent,
//                     fontFamily: 'monospace',
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
