Write-Host "🔄 正在更新许可证声明..." -ForegroundColor Green
dart script/update_license.dart
Write-Host "按任意键继续..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")