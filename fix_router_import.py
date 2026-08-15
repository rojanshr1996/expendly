filepath = 'lib/features/groups/presentation/pages/groups_list_page.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import '../../../../core/router/app_router.dart';", "import '../../../../core/router/app_router.gr.dart';")

with open(filepath, 'w') as f:
    f.write(content)
