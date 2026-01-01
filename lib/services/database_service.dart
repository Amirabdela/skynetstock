// Conditional export: re-export platform-specific implementation
export 'database_service_io.dart'
    if (dart.library.html) 'database_service_web.dart';
