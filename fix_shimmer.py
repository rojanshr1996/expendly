import re

files = [
    'lib/features/groups/presentation/widgets/groups_shimmer.dart',
    'lib/features/groups/presentation/widgets/event_detail_shimmer.dart'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace bad import
    content = content.replace("import '../../../../core/widgets/shimmer_extensions.dart';", "import '../../../../core/extensions/shimmer_extensions.dart';")
    
    # Check if there are Container().animateShimmer()
    # The instruction says "The project uses Skeletonizer for shimmers, not a custom .animateShimmer() on Container."
    # Let's replace Container(...).animateShimmer() with just Container(...) if they exist inside?
    # Or wrap the outermost with Skeletonizer?
    
    with open(filepath, 'w') as f:
        f.write(content)
