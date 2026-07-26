import 'core/config/app_config.dart';
import 'main.dart';

void main() async {
  await bootstrapApp(
    const AppConfig(
      flavor: AppFlavor.qa,
      appName: 'Expendly QA',
      enableLogging: true,
      showFlavorBanner: true,
    ),
  );
}
