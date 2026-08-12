import 'core/config/app_config.dart';
import 'main.dart';

void main() async {
  await bootstrapApp(
    const AppConfig(
      flavor: AppFlavor.prod,
      appName: 'Expendly',
      enableLogging: true,
      showFlavorBanner: false,
    ),
  );
}
