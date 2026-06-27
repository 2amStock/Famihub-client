$replacements = @{
    "package:phosphor_flutter/phosphor_flutter.dart" = "package:lucide_icons/lucide_icons.dart"
    "PhosphorIcons.calendar()" = "LucideIcons.calendar"
    "PhosphorIcons.bell()" = "LucideIcons.bell"
    "PhosphorIcons.magnifyingGlass()" = "LucideIcons.search"
    "PhosphorIcons.listPlus()" = "LucideIcons.listPlus"
    "PhosphorIcons.checkSquareOffset()" = "LucideIcons.checkSquare"
    "PhosphorIcons.gift()" = "LucideIcons.gift"
    "PhosphorIcons.users()" = "LucideIcons.users"
    "PhosphorIcons.shoppingCart()" = "LucideIcons.shoppingCart"
    "PhosphorIcons.checkCircle()" = "LucideIcons.checkCircle"
    "PhosphorIcons.plus()" = "LucideIcons.plus"
    "PhosphorIcons.x()" = "LucideIcons.x"
    "PhosphorIcons.imageBroken()" = "LucideIcons.imageOff"
    "PhosphorIcons.quotes()" = "LucideIcons.quote"
    "PhosphorIcons.house()" = "LucideIcons.home"
    "PhosphorIcons.copy()" = "LucideIcons.copy"
    
    "PhosphorIcons.clipboardText()" = "LucideIcons.clipboardList"
    "PhosphorIcons.clock()" = "LucideIcons.clock"
    "PhosphorIcons.warning()" = "LucideIcons.alertTriangle"
    "PhosphorIcons.camera()" = "LucideIcons.camera"
    "PhosphorIcons.hourglass()" = "LucideIcons.hourglass"
    "PhosphorIcons.image()" = "LucideIcons.image"
    
    "PhosphorIcons.star()" = "LucideIcons.star"
    "PhosphorIcons.tag()" = "LucideIcons.tag"
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
