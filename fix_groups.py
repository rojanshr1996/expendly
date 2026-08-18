import os
import re
import glob

files = glob.glob('lib/features/groups/**/*.dart', recursive=True)
files.append('lib/features/dashboard/presentation/pages/dashboard_page.dart')

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    # 1. Localization import & usage
    content = re.sub(
        r"import 'package:flutter_gen/gen_l10n/app_localizations\.dart';\n",
        r"",
        content
    )
    content = re.sub(
        r"\s*final l10n = AppLocalizations\.of\(context\)!(;)?",
        r"",
        content
    )
    content = re.sub(r"\bl10n\.", r"context.l10n.", content)

    # 3. AppColors
    content = content.replace("AppColors.textPrimary", "context.colorScheme.onSurface")
    content = content.replace("AppColors.textSecondary", "context.colorScheme.onSurfaceVariant")
    
    # 2. Add context_extensions import if needed
    if "context.customTypography" in content or "context.colorScheme" in content or "context.l10n" in content:
        if "context_extensions.dart" not in content:
            # Add to the end of imports
            # Find the last import
            last_import_idx = content.rfind("import ")
            if last_import_idx != -1:
                end_of_line = content.find("\n", last_import_idx)
                content = content[:end_of_line+1] + "import '../../../../core/extensions/context_extensions.dart';\n" + content[end_of_line+1:]
            else:
                content = "import '../../../../core/extensions/context_extensions.dart';\n" + content

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")
