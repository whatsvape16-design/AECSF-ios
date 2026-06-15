# Diya Vape — iOS 独立打包目录

本目录为 `sites/diyavape.shop/ios/` 的独立副本，便于单独推送到 GitHub / Codemagic。

## 目录结构

```
ios/
├── DiyaVape/              # Swift 源码
├── DiyaVape.xcodeproj     # Xcode 工程
├── assets/icons/          # 图标源文件
├── scripts/               # 构建与 CI 脚本
├── codemagic.yaml         # Codemagic 配置
├── ExportOptions.plist
└── docs/cloud-build.md
```

## 本地构建（需 macOS + Xcode）

```bash
python3 scripts/prepare_ios_icons.py
bash scripts/build_ios.sh simulator   # 模拟器
bash scripts/build_ios.sh archive     # 真机 IPA
```

## Codemagic

Configuration file 填：

```
codemagic.yaml
```

（仓库根目录，与 `DiyaVape.xcodeproj` 同级）

### Codemagic 编辑器仍报 `paths extra fields`？

GitHub 已修复。若网页编辑器仍显示旧内容（含 `paths:` / `IOS_DIR: ios`）：

1. **不要**在编辑器里保存旧版
2. 点 **Check for configuration files** 从 GitHub 重新拉取
3. 或 **Repository settings** → Configuration file 确认为 `codemagic.yaml`
4. 确认分支为 `main`，再刷新页面

## 同步说明

主副本仍在 `sites/diyavape.shop/ios/`。修改后如需同步，请手动复制或对比 diff。
