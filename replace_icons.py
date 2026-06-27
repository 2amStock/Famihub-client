import os
import re

replacements = {
    "package:phosphor_flutter/phosphor_flutter.dart": "package:lucide_icons/lucide_icons.dart",
    "PhosphorIcons.calendar()": "LucideIcons.calendar",
    "PhosphorIcons.bell()": "LucideIcons.bell",
    "PhosphorIcons.magnifyingGlass()": "LucideIcons.search",
    "PhosphorIcons.listPlus()": "LucideIcons.listPlus",
    "PhosphorIcons.checkSquareOffset()": "LucideIcons.checkSquare",
    "PhosphorIcons.gift()": "LucideIcons.gift",
    "PhosphorIcons.users()": "LucideIcons.users",
    "PhosphorIcons.shoppingCart()": "LucideIcons.shoppingCart",
    "PhosphorIcons.checkCircle()": "LucideIcons.checkCircle",
    "PhosphorIcons.plus()": "LucideIcons.plus",
    "PhosphorIcons.x()": "LucideIcons.x",
    "PhosphorIcons.imageBroken()": "LucideIcons.imageOff",
    "PhosphorIcons.quotes()": "LucideIcons.quote",
    "PhosphorIcons.house()": "LucideIcons.home",
    "PhosphorIcons.copy()": "LucideIcons.copy",
    
    "PhosphorIcons.clipboardText()": "LucideIcons.clipboardList",
    "PhosphorIcons.clock()": "LucideIcons.clock",
    "PhosphorIcons.warning()": "LucideIcons.alertTriangle",
    "PhosphorIcons.camera()": "LucideIcons.camera",
    "PhosphorIcons.hourglass()": "LucideIcons.hourglass",
    "PhosphorIcons.image()": "LucideIcons.image",
    
    "PhosphorIcons.star()": "LucideIcons.star",
    "PhosphorIcons.tag()": "LucideIcons.tag",
}

files = [
    r"c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\parent\parent_home_screen.dart",
    r"c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\child\my_tasks_screen.dart",
    r"c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\child\child_rewards_screen.dart",
]

for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    for k, v in replacements.items():
        content = content.replace(k, v)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Replaced all icons successfully!")
