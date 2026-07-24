import 'package:get_it/get_it.dart';

/// Global service locator instance.
///
/// Each feature package should provide its own `register*Dependencies(GetIt sl)`
/// function that the main app calls during initialization.
final sl = GetIt.instance;
