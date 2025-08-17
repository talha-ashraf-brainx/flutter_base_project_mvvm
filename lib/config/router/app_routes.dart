enum AppRoutes {
  splash('/'),
  home('/home'),
  homepage('/homepage'),
  search('/search'),
  settings('/settings'),
  camera('/camera');

  const AppRoutes(this.path);
  final String path;

  @override
  String toString() => path;
}
