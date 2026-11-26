import os
import re

folder = 'lib/ui'

replacements = {
    'AppTheme.white': 'Theme.of(context).colorScheme.surface',
    'AppTheme.black': 'Theme.of(context).colorScheme.onSurface',
    'AppTheme.surfaceGrey': 'Theme.of(context).colorScheme.surfaceContainerHighest',
    'AppTheme.borderGrey': 'Theme.of(context).colorScheme.outline',
    'AppTheme.mediumGrey': 'Theme.of(context).colorScheme.onSurface.withOpacity(0.6)',
    'AppTheme.lightGrey': 'Theme.of(context).colorScheme.onSurface.withOpacity(0.4)',
    'AppTheme.accent': 'Theme.of(context).colorScheme.primary',
    
    'AppTheme.displayLarge': 'AppTheme.displayLarge(context)',
    'AppTheme.displayMedium': 'AppTheme.displayMedium(context)',
    'AppTheme.headlineLarge': 'AppTheme.headlineLarge(context)',
    'AppTheme.headlineMedium': 'AppTheme.headlineMedium(context)',
    'AppTheme.titleMedium': 'AppTheme.titleMedium(context)',
    'AppTheme.bodyLarge': 'AppTheme.bodyLarge(context)',
    'AppTheme.bodyMedium': 'AppTheme.bodyMedium(context)',
    'AppTheme.labelSmall': 'AppTheme.labelSmall(context)',
    'AppTheme.mono': 'AppTheme.mono(context)',
}

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    # Remove const before widgets that now have Theme.of(context)
    # This is a bit tricky, but let's just remove const from common ones:
    content = re.sub(r'const\s+(EdgeInsets|BorderRadius|SizedBox|BoxDecoration|Icon|Text|Center|Padding|Column|Row|Container)', r'\1', content)
    content = re.sub(r'const\s+\[', r'[', content)
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(folder):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
