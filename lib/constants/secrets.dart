import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000';

// Session token is now managed by AuthService and stored locally
// Use AuthService.instance.sessionToken to access it