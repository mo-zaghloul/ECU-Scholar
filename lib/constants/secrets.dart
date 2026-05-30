import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000';

// EmailJS credentials
String get emailjsServiceId => dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
String get emailjsTemplateId => dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
String get emailjsPublicKey => dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';
String get emailjsPrivateKey => dotenv.env['EMAILJS_PRIVATE_KEY'] ?? '';