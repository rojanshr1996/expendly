import 'core/config/app_config.dart';
import 'main.dart';

void main() async {
  await bootstrapApp(
    const AppConfig(
      flavor: AppFlavor.dev,
      appName: 'Expendly Dev',
      enableLogging: true,
      showFlavorBanner: true,
    ),
  );
}
