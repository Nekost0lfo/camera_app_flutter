import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const CameraApp());

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Проверка и запрос разрешений
  Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Для использования камеры необходимо разрешение'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    } else if (source == ImageSource.gallery) {
      // Для галереи запрашиваем разрешение
      // На Android 13+ используется Permission.photos, на старых версиях - Permission.storage
      PermissionStatus status = await Permission.photos.request();
      
      // Если Permission.photos не поддерживается или отклонено, пробуем Permission.storage
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Для доступа к галерее необходимо разрешение'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    }
    return true;
  }

  // Получение изображения из камеры или галереи
  Future<void> _getImage(ImageSource source) async {
    // Проверяем разрешения перед выбором изображения
    final hasPermission = await _checkPermissions(source);
    if (!hasPermission) {
      return;
    }
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      
      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Сохранение изображения в локальное хранилище
  Future<void> _saveImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала выберите изображение'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/photo_$timestamp.jpg';
      
      await _image!.copy(newPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Фото успешно сохранено'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Очистка выбранного изображения
  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearImage,
              tooltip: 'Удалить изображение',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Отображение изображения
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Фото не выбрано',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Ошибка загрузки изображения'),
                          );
                        },
                      ),
                    ),
            ),
            
            const SizedBox(height: 30),
            
            // Кнопки действий
            Column(
              children: [
                // Кнопка камеры
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Сделать фото',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Кнопка галереи
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text(
                      'Выбрать из галереи',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple.shade50,
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Кнопка сохранения
                if (_image != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveImage,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Сохранить фото',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Информация о приложении
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Убедитесь, что предоставили разрешения для камеры и хранилища',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '• Фото сохраняются в папку приложения',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}