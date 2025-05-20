/// Exception de base pour l'application
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception pour les erreurs de stockage
class StorageException extends AppException {
  StorageException(super.message);
}

/// Exception pour les erreurs d'importation/exportation
class ImportExportException extends AppException {
  ImportExportException(super.message);
}

/// Exception pour les erreurs métier
class BusinessException extends AppException {
  BusinessException(super.message);
}

/// Exception pour les erreurs de validation
class ValidationException extends AppException {
  ValidationException(super.message);
}
