/// Abstract Network Service interface for Phase 1 architecture
abstract class NetworkService {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String path, {dynamic data});
  Future<dynamic> put(String path, {dynamic data});
  Future<dynamic> delete(String path);
}

/// Mock Implementation of NetworkService for Phase 1
class MockNetworkService implements NetworkService {
  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success', 'data': []};
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success', 'data': data};
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success'};
  }

  @override
  Future<dynamic> delete(String path) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success'};
  }
}
