$replacements = @{
    "LucideIcons.list_plus" = "LucideIcons.listPlus"
    "LucideIcons.check_square" = "LucideIcons.checkSquare"
    "LucideIcons.shopping_cart" = "LucideIcons.shoppingCart"
    "LucideIcons.check_circle" = "LucideIcons.checkCircle"
    "LucideIcons.image_off" = "LucideIcons.imageOff"
    "LucideIcons.clipboard_list" = "LucideIcons.clipboardList"
    "LucideIcons.alert_triangle" = "LucideIcons.alertTriangle"
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
