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

## 同步说明

主副本仍在 `sites/diyavape.shop/ios/`。修改后如需同步，请手动复制或对比 diff。
