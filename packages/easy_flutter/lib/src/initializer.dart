/// Contract for DI initialization steps.
///
/// Implement this for each layer of your dependency graph
/// (e.g. CoreInitializer, NetworkInitializer, RepositoryInitializer).
abstract class Initializer {
  /// Registers this layer's dependencies.
  Future<void> init();
}
