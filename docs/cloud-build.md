# Diya Vape iOS — 云端构建指南

在 Windows 上无法本地 `xcodebuild`，使用 **Codemagic**（推荐）或 **GitHub Actions** 在 macOS 云端打包。

## 方案对比

| 方案 | 签名方式 | 适用场景 |
|------|----------|----------|
| **Codemagic** | UI 连接 Apple Developer，自动管理证书 | 内测 IPA、TestFlight、最省心 |
| **GitHub Actions** | 手动上传 Secrets（.p12 + profile） | 已有 GHA、想留在 GitHub 生态 |
| **PWA** | 无需打包 | 用户 Safari 访问 `/install` 添加主屏幕 |

---

## 方案 A：Codemagic（推荐）

### 1. 注册并连接仓库

1. 打开 [codemagic.io](https://codemagic.io/) 注册账号
2. **Add application** → 选择 Git 提供商（GitHub / GitLab / Bitbucket）
3. 选中 **AECSF** 仓库
4. 项目设置 → **Configuration file** 填写：

   ```
   sites/diyavape.shop/codemagic.yaml
   ```

### 2. 连接 Apple Developer

1. Codemagic → **Team settings** → **Integrations** → **Developer Portal**
2. 使用 App Store Connect API Key 或 Apple ID 登录
3. 在 **Code signing identities** 中启用 **Automatic code signing**
4. Bundle ID：`shop.diyavape.app`
5. 分发类型：**Ad Hoc**（内测）或 **App Store**（上架）

Codemagic 会自动注入 `APPLE_DEVELOPER_TEAM_ID`，无需手写 Team ID。

### 3. 触发构建

| Workflow | 触发条件 | 产物 |
|----------|----------|------|
| `diya-vape-ios-adhoc` | push 到 `main` / `release/*`，且 `ios/**` 有变更 | `.ipa` |
| `diya-vape-ios-simulator` | PR 变更 `ios/**` | 模拟器 `.app`（编译验证） |

也可在 Codemagic 控制台手动 **Start new build**。

### 4. 下载 IPA

构建完成后 → **Artifacts** → 下载 `*.ipa`。

内测安装：将 IPA 通过 [Diawi](https://diawi.com/)、TestFlight 或 Apple Configurator 分发给测试设备（Ad Hoc 需预先登记 UDID）。

---

## 方案 B：GitHub Actions

配置文件：`.github/workflows/diyavape-ios.yml`

### 自动编译（无需 Secrets）

- **push / PR** 变更 `sites/diyavape.shop/ios/**` 时自动跑模拟器编译
- 验证 Swift 代码能通过 `xcodebuild`

### 手动打签名 IPA

1. GitHub 仓库 → **Settings** → **Secrets and variables** → **Actions**
2. 添加以下 Secrets：

| Secret | 说明 |
|--------|------|
| `IOS_APPLE_TEAM_ID` | 10 位 Team ID（Apple Developer → Membership） |
| `IOS_BUILD_CERTIFICATE_BASE64` | Distribution 证书 `.p12` 的 Base64 |
| `IOS_P12_PASSWORD` | 导出 `.p12` 时设置的密码 |
| `IOS_PROVISION_PROFILE_BASE64` | Ad Hoc / Development profile 的 Base64 |
| `IOS_KEYCHAIN_PASSWORD` | 任意随机字符串（CI 临时钥匙串用） |

生成 Base64（在 Mac 或 WSL）：

```bash
base64 -i Certificates.p12 | pbcopy          # 证书
base64 -i DiyaVape.mobileprovision | pbcopy  # 描述文件
```

3. GitHub → **Actions** → **Diya Vape iOS** → **Run workflow**
4. 选择 `export_method`：`development` / `ad-hoc` / `app-store`
5. 完成后在 **Artifacts** 下载 IPA

---

## 本地脚本（Mac 上调试）

```bash
python3 sites/diyavape.shop/scripts/prepare_ios_icons.py
cd sites/diyavape.shop/ios && bash scripts/build_ios.sh simulator   # 模拟器
cd sites/diyavape.shop/ios && bash scripts/build_ios.sh archive       # 真机（需签名）
```

---

## 上架 / TestFlight（Codemagic 扩展）

在 `codemagic.yaml` 的 `diya-vape-ios-adhoc` workflow 中取消注释：

```yaml
publishing:
  app_store_connect:
    auth: integration
    submit_to_testflight: true
    beta_groups:
      - Internal Testers
```

并在 Codemagic UI 配置 App Store Connect API Key integration。

---

## 常见问题

**Q: 构建失败 `No signing certificate`？**  
A: Codemagic 需在 UI 完成 Apple Developer 集成；GHA 需检查 Secrets 是否齐全。

**Q: Ad Hoc 装不上？**  
A: 测试设备 UDID 必须包含在 Provisioning Profile 中。

**Q: 不想上架，只要 iOS 用户能用？**  
A: 部署 PWA 安装页 `https://diyavape.shop/install`，用户「添加到主屏幕」即可。
