import re
import glob

# 1. status_badge.dart AppLocalizations
with open('lib/features/groups/presentation/widgets/status_badge.dart', 'r') as f:
    content = f.read()
content = content.replace("AppLocalizations.of(context)!", "context.l10n")
with open('lib/features/groups/presentation/widgets/status_badge.dart', 'w') as f:
    f.write(content)

# 2. split_participant_tile.dart initialValue
with open('lib/features/groups/presentation/widgets/split_participant_tile.dart', 'r') as f:
    content = f.read()
content = re.sub(r"initialValue:\s*[^,]+,\n", "", content)
with open('lib/features/groups/presentation/widgets/split_participant_tile.dart', 'w') as f:
    f.write(content)

# 3. Typography
def fix_typography(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # context.customTypography.labelSmallMono -> context.textTheme.labelSmall
    content = content.replace("context.customTypography.labelSmallMono", "context.textTheme.labelSmall")
    content = content.replace("context.customTypography.labelLargeMono", "context.textTheme.labelLarge")
    content = content.replace("context.customTypography.bodyLargeMono", "context.textTheme.bodyLarge")
    content = content.replace("context.customTypography.bodyMediumMono", "context.textTheme.bodyMedium")
    
    with open(filepath, 'w') as f:
        f.write(content)

files = glob.glob('lib/features/groups/**/*.dart', recursive=True)
for filepath in files:
    fix_typography(filepath)
