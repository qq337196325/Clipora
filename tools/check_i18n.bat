@echo off
echo 正在检查 i18n 文件完整性...
dart run tools/check_i18n_completeness.dart
pause