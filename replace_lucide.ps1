$replacements = @{
    "package:lucide_icons/lucide_icons.dart" = "package:lucide_icons_flutter/lucide_icons.dart"
    "LucideIcons.listPlus" = "LucideIcons.list_plus"
    "LucideIcons.checkSquare" = "LucideIcons.check_square"
    "LucideIcons.shoppingCart" = "LucideIcons.shopping_cart"
    "LucideIcons.checkCircle" = "LucideIcons.check_circle"
    "LucideIcons.imageOff" = "LucideIcons.image_off"
    "LucideIcons.clipboardList" = "LucideIcons.clipboard_list"
    "LucideIcons.alertTriangle" = "LucideIcons.alert_triangle"
}

$files = @(
    "c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\parent\parent_home_screen.dart",
    "c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\child\my_tasks_screen.dart",
    "c:\Users\he181\.gemini\antigravity\scratch\FamiHub\famihub_flutter\lib\presentation\child\child_rewards_screen.dart"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw -Encoding UTF8
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    Set-Content $file -Value $content -Encoding UTF8
}
