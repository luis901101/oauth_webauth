// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:web/web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as webPlugins;

void loadPage(String url) => window.location.assign(url);
String? originUrl() => window.location.origin;
void usePathUrlStrategy() => webPlugins.usePathUrlStrategy();

