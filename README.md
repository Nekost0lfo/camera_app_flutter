# Отчёт по практическому занятию №12; Батов Даниил ЭФБО-10-23
## Разработка приложения для работы с камерой и галереей в Flutter

### 1. Цели работы

- Изучить архитектуру и возможности аппаратной части мобильных устройств
- Ознакомиться с API камеры и галереи во Flutter
- Научиться создавать приложения, использующие камеру и хранилище устройства
- Разобраться с разрешениями, обработкой изображений и сохранением данных

### 2. Ход выполнения работы

#### 2.1. Подготовка проекта

Создан новый проект Flutter с использованием команды:
```bash
flutter create camera_app
cd camera_app
```

#### 2.2. Установка зависимостей

В файл **`pubspec.yaml`** добавлены следующие зависимости:

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.1.1
  permission_handler: ^11.3.0
  path_provider: ^2.1.4
```

После добавления зависимостей выполнена команда:
```bash
flutter pub get
```

#### 2.3. Настройка разрешений для Android

В файле **`android/app/src/main/AndroidManifest.xml`** добавлены разрешения:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
```

#### 2.4. Настройка разрешений для iOS

В файле **`ios/Runner/Info.plist`** добавлены описания использования функций:

```xml
<key>NSCameraUsageDescription</key>
<string>Для работы приложения требуется доступ к камере</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Для выбора изображений из галереи требуется разрешение</string>
<key>NSMicrophoneUsageDescription</key>
<string>Для записи видео требуется доступ к микрофону</string>
```

#### 2.5. Реализация основного функционала

Создан основной файл **`lib/main.dart`** со следующим функционалом:

- **Класс CameraApp** - главный виджет приложения
- **Класс CameraPage** - состояние главной страницы
- **Метод _checkPermissions()** - запрос разрешений у пользователя
- **Метод _getImage()** - получение изображения из камеры или галереи
- **Метод _saveImage()** - сохранение изображения в локальное хранилище
- **Метод _clearImage()** - очистка выбранного изображения

#### 2.6. Ключевые фрагменты кода

**Запрос разрешений:**
```dart
Future<void> _checkPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.storage,
    Permission.photos,
  ].request();
}
```

**Получение изображения:**
```dart
final XFile? pickedFile = await _picker.pickImage(
  source: source,
  maxWidth: 1800,
  maxHeight: 1800,
  imageQuality: 90,
);
```

**Сохранение изображения:**
```dart
final directory = await getApplicationDocumentsDirectory();
final timestamp = DateTime.now().millisecondsSinceEpoch;
final newPath = '${directory.path}/photo_$timestamp.jpg';
final newFile = await _image!.copy(newPath);
```

### 3. Скриншоты работы приложения

#### 3.1. Главный экран приложения

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/cd56e462-0904-46af-a99d-fe7d8f34d332" />


#### 3.2. Запрос разрешений

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/033c233a-10ba-4c33-b081-34353d723b83" />

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/4dd09604-3d42-4f8a-b20c-79fc6730d314" />



#### 3.3. Интерфейс камеры

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/32f893a2-4dbc-4a61-b0be-d16b33ed47bf" />


#### 3.4. Отображение выбранного фото

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/dcfaaf23-5d2b-4bb3-8651-67782dbca247" />


#### 3.5. Уведомление о сохранении

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/a4d48308-988f-492f-a597-d3514c7761a4" />


