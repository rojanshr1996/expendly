/// Data layer local exceptions.
class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Local Database Exception']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local Cache Exception']);
}
