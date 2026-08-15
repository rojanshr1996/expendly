import glob
import re

files = glob.glob('lib/features/groups/**/*.dart', recursive=True)
files.append('lib/features/dashboard/presentation/pages/dashboard_page.dart')

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Dashboard cubit issue
    if 'dashboard_page.dart' in filepath:
        # duplicate cubit variable
        content = re.sub(r"final cubit = context\.read<DashboardCubit>\(\);\n\s*final cubit = context\.read<DashboardCubit>\(\);", 
                         r"final cubit = context.read<DashboardCubit>();", content)
        # Maybe it's defined twice separately
        lines = content.split('\n')
        new_lines = []
        cubit_count = 0
        for line in lines:
            if "final cubit = context.read<DashboardCubit>();" in line:
                cubit_count += 1
                if cubit_count > 1:
                    continue # Skip second definition
            new_lines.append(line)
        content = '\n'.join(new_lines)

    # 1. Null check on textTheme
    # e.g., context.textTheme.labelSmall.copyWith -> context.textTheme.labelSmall!.copyWith
    for style in ['labelSmall', 'labelLarge', 'labelMedium', 'bodyLarge', 'bodyMedium', 'headlineSmall', 'headlineLarge', 'headlineMedium', 'titleLarge', 'titleMedium', 'titleSmall']:
        content = content.replace(f"context.textTheme.{style}.copyWith", f"context.textTheme.{style}!.copyWith")
        content = content.replace(f"context.textTheme.{style}?.copyWith", f"context.textTheme.{style}!.copyWith")

    # balances_view.dart headlineSmall issue
    content = content.replace("context.customTypography.headlineSmall", "context.textTheme.headlineSmall")
    # if it had .copyWith it might be context.textTheme.headlineSmall.copyWith without !
    content = content.replace("context.textTheme.headlineSmall.copyWith", "context.textTheme.headlineSmall!.copyWith")
    
    with open(filepath, 'w') as f:
        f.write(content)

for filepath in files:
    fix_file(filepath)
