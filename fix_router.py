with open('lib/core/router/app_router.dart', 'r') as f:
    content = f.read()

content = content.replace("import '../features/groups", "import '../../features/groups")
with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(content)
