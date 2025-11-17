import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generate mocks for these classes
@GenerateMocks([
  http.Client,
  SharedPreferences,
])
void main() {}
