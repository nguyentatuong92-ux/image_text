import 'package:url_launcher/url_launcher.dart';

class SmartActionService {
  static final RegExp _phoneRegex = RegExp(r'(\+84|0)\d{9,10}');
  static final RegExp _emailRegex = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final RegExp _urlRegex = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
  );

  List<DetectedEntity> detectEntities(String text) {
    final List<DetectedEntity> entities = [];

    // Detect Phones
    for (var match in _phoneRegex.allMatches(text)) {
      entities.add(DetectedEntity(match.group(0)!, EntityType.phone));
    }

    // Detect Emails
    for (var match in _emailRegex.allMatches(text)) {
      entities.add(DetectedEntity(match.group(0)!, EntityType.email));
    }

    // Detect URLs
    for (var match in _urlRegex.allMatches(text)) {
      entities.add(DetectedEntity(match.group(0)!, EntityType.url));
    }

    return entities;
  }

  Future<void> performAction(DetectedEntity entity) async {
    Uri? uri;
    switch (entity.type) {
      case EntityType.phone:
        uri = Uri.parse('tel:${entity.value}');
        break;
      case EntityType.email:
        uri = Uri.parse('mailto:${entity.value}');
        break;
      case EntityType.url:
        uri = Uri.parse(entity.value);
        if (!uri.hasScheme) {
          uri = Uri.parse('https://${entity.value}');
        }
        break;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

enum EntityType { phone, email, url }

class DetectedEntity {
  final String value;
  final EntityType type;

  DetectedEntity(this.value, this.type);
}
