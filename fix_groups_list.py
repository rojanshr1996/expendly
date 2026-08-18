filepath = 'lib/features/groups/presentation/pages/groups_list_page.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("context.customTypography.headlineMedium", "context.textTheme.headlineMedium")

with open(filepath, 'w') as f:
    f.write(content)
