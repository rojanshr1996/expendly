import re

files = [
    'lib/features/groups/presentation/widgets/groups_shimmer.dart',
    'lib/features/groups/presentation/widgets/event_detail_shimmer.dart'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove all .animateShimmer() from Containers
    content = content.replace(".animateShimmer()", "")
    
    # Check if 'skeletonizer' import is there
    if 'package:skeletonizer/skeletonizer.dart' not in content:
        content = "import 'package:skeletonizer/skeletonizer.dart';\n" + content

    # Add .animateShimmer() to the outermost if needed, but Skeletonizer might be enough based on the example.
    # The example in instructions literally says "Wrap the whole shimmer widget tree in a single .animateShimmer() call on the outermost widget:" 
    # and then shows Skeletonizer with NO .animateShimmer() at the end.
    # Wait, in dashboard_shimmer.dart it returns `SingleChildScrollView(...).animateShimmer();`
    # Let's wrap the outermost return with .animateShimmer();
    if "return ListView" in content:
        content = content.replace("return ListView", "return Skeletonizer(\nenabled: true,\nchild: ListView")
        content = content.replace(";\n  }\n}", ",\n    ).animateShimmer();\n  }\n}")
    elif "return SingleChildScrollView" in content:
        content = content.replace("return SingleChildScrollView", "return Skeletonizer(\nenabled: true,\nchild: SingleChildScrollView")
        content = content.replace(";\n  }\n}", ",\n    ).animateShimmer();\n  }\n}")

    with open(filepath, 'w') as f:
        f.write(content)
