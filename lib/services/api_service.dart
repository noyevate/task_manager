import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  final String baseUrl;
  final Duration timeout;

  ApiService({this.baseUrl = 'https://jsonplaceholder.typicode.com', this.timeout = const Duration(seconds: 10)});

  String _sample(String s, [int n = 300]) => s.length <= n ? s : '${s.substring(0, n)}...';

  Map<String, String> _defaultHeaders() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'Mozilla/5.0 (Flutter; TaskManager)',
      };

  Future<List<Task>> fetchTasks({int? limit}) async {
    final uri = Uri.parse('$baseUrl/todos${limit != null ? '?_limit=$limit' : ''}');
    final res = await _get(uri);
    try {
      final list = json.decode(res.body) as List<dynamic>;
      return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException('Failed to parse tasks JSON: $e. Body sample: ${_sample(res.body)}');
    }
  }

  Future<Task> fetchTask(int id) async {
    final uri = Uri.parse('$baseUrl/todos/$id');
    final res = await _get(uri);
    try {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return Task.fromJson(map);
    } catch (e) {
      throw ApiException('Failed to parse task JSON: $e. Body sample: ${_sample(res.body)}');
    }
  }

  Future<Task> createTask(Task task) async {
    final uri = Uri.parse('$baseUrl/todos');
    final body = json.encode(task.toJson());
    final res = await _post(uri, body);
    if (res.statusCode == 201 || (res.statusCode >= 200 && res.statusCode < 300)) {
      try {
        final map = json.decode(res.body) as Map<String, dynamic>;
        return Task.fromJson(map);
      } catch (e) {
        throw ApiException('Failed to parse create response: $e. Body sample: ${_sample(res.body)}');
      }
    }
    throw ApiException('Unexpected create status ${res.statusCode}. Body: ${_sample(res.body)}');
  }

  Future<Task> updateTask(Task task) async {
    final uri = Uri.parse('$baseUrl/todos/${task.id}');
    final body = json.encode(task.toJson());
    final res = await _put(uri, body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final map = json.decode(res.body) as Map<String, dynamic>;
        return Task.fromJson(map);
      } catch (e) {
        throw ApiException('Failed to parse update response: $e. Body sample: ${_sample(res.body)}');
      }
    }
    throw ApiException('Unexpected update status ${res.statusCode}. Body: ${_sample(res.body)}');
  }

  Future<void> deleteTask(String id) async {
    final uri = Uri.parse('$baseUrl/todos/$id');
    final res = await _delete(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }
    throw ApiException('Delete failed with status ${res.statusCode}. Body: ${_sample(res.body)}');
  }

  Future<http.Response> _get(Uri uri) async {
    final headers = _defaultHeaders();
    http.Response res;
    try {
      res = await http.get(uri, headers: headers).timeout(timeout);
    } catch (e) {
      throw ApiException('Network error during GET $uri: $e');
    }
    _validateResponseIsJson(res, uri);
    return res;
  }

  Future<http.Response> _post(Uri uri, String body) async {
    final headers = _defaultHeaders();
    http.Response res;
    try {
      res = await http.post(uri, headers: headers, body: body).timeout(timeout);
    } catch (e) {
      throw ApiException('Network error during POST $uri: $e');
    }
    _validateResponseIsJson(res, uri);
    return res;
  }

  Future<http.Response> _put(Uri uri, String body) async {
    final headers = _defaultHeaders();
    http.Response res;
    try {
      res = await http.put(uri, headers: headers, body: body).timeout(timeout);
    } catch (e) {
      throw ApiException('Network error during PUT $uri: $e');
    }
    _validateResponseIsJson(res, uri);
    return res;
  }

  Future<http.Response> _delete(Uri uri) async {
    final headers = _defaultHeaders();
    http.Response res;
    try {
      res = await http.delete(uri, headers: headers).timeout(timeout);
    } catch (e) {
      throw ApiException('Network error during DELETE $uri: $e');
    }
    final contentType = res.headers['content-type'] ?? '';
    if (res.body.trim().isNotEmpty && !contentType.contains('application/json')) {
      throw ApiException('Expected JSON/empty body from DELETE but received content-type=$contentType '
          'status=${res.statusCode}. Body sample: ${_sample(res.body)}');
    }
    return res;
  }

  void _validateResponseIsJson(http.Response res, Uri uri) {
    final contentType = res.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      final snippet = _sample(res.body);
      throw ApiException('Expected JSON from $uri but received content-type="$contentType", status=${res.statusCode}. '
          'Body sample:\n$snippet');
    }
  }
}
