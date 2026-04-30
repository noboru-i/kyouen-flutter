import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final dir = Directory('build/screenshots');
        if (!dir.existsSync()) dir.createSync(recursive: true);

        // App Store申請要件: アルファチャンネルを除去してRGBで保存
        final decoded = img.decodePng(Uint8List.fromList(bytes))!;
        final rgb = decoded.convert(numChannels: 3);
        final pngBytes = img.encodePng(rgb);

        File('${dir.path}/$name.png').writeAsBytesSync(pngBytes);
        return true;
      },
);
