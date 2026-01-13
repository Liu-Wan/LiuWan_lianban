# 🛡️ FiveM 联盟封禁系统 - 客户端插件

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)](https://fivem.net/)
[![Version](https://img.shields.io/badge/version-2.0.0-orange.svg)](https://github.com/yourusername/lianban_client)

**跨服务器联盟封禁系统，实时同步全网作弊玩家数据**

[功能特性](#功能特性) • [安装教程](#安装教程) • [配置说明](#配置说明) • [使用方法](#使用方法) • [常见问题](#常见问题)

</div>

---

## 📖 项目介绍

FiveM联盟封禁系统客户端插件是一个强大的跨服务器反外挂解决方案。通过连接到中心化的封禁数据库，多个FiveM服务器可以实时共享和同步作弊玩家信息，形成联盟防护网，有效提升服务器安全性。

### 🎯 为什么需要联盟封禁？

- **单服封禁局限性**：作弊者换服后可以继续作恶
- **信息孤岛问题**：各服务器封禁数据不共享
- **重复封禁成本**：同一作弊者需要在多个服务器重复举报
- **滞后性问题**：其他服务器无法及时获知新出现的作弊者

### ✨ 解决方案

本插件通过API连接到联盟封禁平台，实现：
- ✅ 玩家进服时自动检查联盟黑名单
- ✅ 游戏内一键查询玩家封禁状态
- ✅ 管理员可直接提交封禁至全网数据库
- ✅ 审核制度确保误封可申诉解除
- ✅ 美观的NUI管理面板

---

## 🚀 功能特性

### 核心功能

| 功能 | 说明 |
|------|------|
| **自动封禁检测** | 玩家进服时自动查询联盟数据库，拦截黑名单玩家 |
| **管理员面板** | 游戏内打开NUI界面，管理封禁记录 |
| **封禁查询** | 支持按标识符（Steam、License等）查询封禁状态 |
| **提交封禁** | 管理员可提交新的封禁申请到联盟数据库 |
| **解除申请** | 支持填写理由申请解除误封 |
| **多框架支持** | 兼容 ESX、QBCore 和 Standalone 模式 |
| **自适应卡片** | 封禁提示使用FiveM Adaptive Card，显示详细信息和证据 |

### 管理面板功能

- 🔍 **查询封禁**：输入标识符实时查询封禁状态
- 📋 **我的提交**：查看自己服务器提交的封禁记录
- ⚖️ **提交封禁**：填写标识符、原因、证据图片链接提交新封禁
- 🔓 **申请解除**：对已提交的封禁填写理由申请解除（需管理员审核）

### 权限系统

支持三种框架的权限验证：
- **ESX**：基于用户组（如 `superadmin`、`admin`）
- **QBCore**：使用 `QBCore.Functions.HasPermission()`
- **Standalone**：使用ACE权限系统（`group.admin`）

---

## 📦 安装教程

### 前置要求

- FiveM服务器 (artifact 版本 >= 2802)
- 联盟封禁平台账号和API密钥
- （可选）ESX 或 QBCore 框架

### 安装步骤

1. **下载插件**

```bash
git clone https://github.com/yourusername/lianban_client.git
```

2. **放置到resources目录**

将 `lianban_client` 文件夹放入服务器的 `resources` 目录：

```
resources/
└── lianban_client/
    ├── config.lua
    ├── server_config.lua
    ├── fxmanifest.lua
    ├── client.lua
    ├── server.lua
    ├── ui/
    │   ├── index.html
    │   ├── style.css
    │   └── script.js
    └── README.md
```

3. **添加到server.cfg**

在 `server.cfg` 中添加启动项：

```cfg
ensure lianban_client
```

4. **重启服务器**

```bash
restart lianban_client
# 或者重启整个服务器
```

---

## ⚙️ 配置说明

### 1. config.lua（客户端配置）

```lua
Config = {}

-- 联盟封禁平台API地址（无需带 /api）
Config.ApiUrl = "https://lianban.fivemzh.cn"

-- 是否在玩家进服时检查封禁
Config.CheckBanOnJoin = true

-- 框架类型: "standalone", "esx", "qbcore"
Config.Framework = "esx"

-- 管理员权限组
Config.AdminGroups = {
    "superadmin",
    "admin"
}
```

### 2. server_config.lua（服务器端密钥）

```lua
ServerConfig = {}

-- 您的API密钥（在联盟封禁平台获取）
ServerConfig.ApiKey = "your_64_character_api_key_here"
```

> ⚠️ **安全提示**：
> - `server_config.lua` 仅服务器端可见，不会发送给客户端
> - 请勿将API密钥分享给他人
> - 如果密钥泄露，请立即在平台重新生成

### 配置参数详解

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `ApiUrl` | string | 联盟封禁平台地址 | - |
| `ApiKey` | string | 服务器API密钥 | - |
| `CheckBanOnJoin` | boolean | 进服检测开关 | `true` |
| `Framework` | string | 框架类型 | `"esx"` |
| `AdminGroups` | table | 管理员权限组 | `{"superadmin", "admin"}` |

---

## 🎮 使用方法

### 命令列表

| 命令 | 权限 | 说明 |
|------|------|------|
| `/lbpanel` | 管理员 | 打开联盟封禁管理面板 |

### 管理面板操作指南

#### 1. 打开面板

管理员在游戏内输入命令：
```
/lbpanel
```

#### 2. 查询封禁

- 切换到"查询封禁"标签
- 输入玩家标识符（如 `steam:110000xxxxxxxx`、`license:xxxxx`）
- 点击"查询"按钮
- 系统会显示该标识符是否被封禁及详细信息

#### 3. 提交封禁

- 切换到"提交封禁"标签
- 填写以下信息：
  - **标识符**：玩家的唯一标识符
  - **封禁原因**：详细描述违规行为（如"使用外挂"、"恶意破坏"等）
  - **证据链接**：上传截图/视频到图床后粘贴链接
- 点击"提交封禁"
- 等待平台管理员审核（审核通过后生效）

#### 4. 查看我的提交

- 切换到"我的提交"标签
- 查看本服务器提交的所有封禁记录
- 点击"申请解除"可以对已提交的封禁申请解除

#### 5. 申请解除封禁

- 在"我的提交"中找到需要解除的记录
- 点击"申请解除"按钮
- 在弹出框中填写解除理由（如"误封"、"证据不足"等）
- 提交后等待管理员审核

### 进服封禁检测

当 `Config.CheckBanOnJoin = true` 时，玩家连接服务器会：

1. 系统显示"正在核查联盟信用记录..."
2. 自动查询该玩家的所有标识符
3. 如果命中黑名单，显示自适应卡片：
   - 封禁原因
   - 触发标识符
   - 证据图片（如有）
   - 申诉提示
4. 拒绝该玩家进入服务器

---

## 🔌 API集成说明

### 平台注册

1. 访问联盟封禁平台：https://lianban.fivemzh.cn
2. 注册账号并登录
3. 进入控制台，复制API密钥
4. 将密钥填入 `server_config.lua`

### API端点

插件自动调用以下API端点：

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/check_ban` | GET/POST | 检查标识符是否被封禁 |
| `/api/my_bans` | GET | 获取本服务器的封禁记录 |
| `/api/submit_ban` | POST | 提交新的封禁申请 |
| `/api/request_unban` | POST | 提交解除封禁申请 |
| `/api/stats` | GET | 获取平台统计信息 |

详细API文档请查看平台的 [API文档页面](https://lianban.fivemzh.cn/docs)

---

## 🎨 界面预览

管理面板采用现代化设计，深色主题，响应式布局：

- **配色方案**：深蓝色背景 (#0f172a) + 紫色主题 (#6366f1)
- **字体**：Inter + Segoe UI
- **动画效果**：平滑过渡和渐入效果
- **Toast通知**：操作反馈提示

---

## 🔧 故障排查

### 常见问题

#### 1. 插件无法启动

**症状**：服务器启动时报错或插件不加载

**解决方法**：
- 检查 `fxmanifest.lua` 是否存在
- 确认 `server.cfg` 中已添加 `ensure lianban_client`
- 查看服务器控制台错误信息

#### 2. 无法连接到API

**症状**：提示"Request Timeout or Connection Failure"

**解决方法**：
- 检查 `Config.ApiUrl` 是否正确
- 确认服务器可以访问外网
- 验证API密钥是否正确填写在 `server_config.lua`

#### 3. 管理员无法打开面板

**症状**：输入 `/lbpanel` 提示"无权限访问"

**解决方法**：
- 检查 `Config.AdminGroups` 是否包含该用户的权限组
- ESX用户：执行 `SELECT group FROM users WHERE identifier = 'xxx'` 确认权限组
- QBCore用户：检查 `qb-core/shared/permissions.lua`
- Standalone：执行 `add_ace group.admin command.lbpanel allow`

#### 4. 进服时不检查封禁

**症状**：黑名单玩家可以正常进入服务器

**解决方法**：
- 确认 `Config.CheckBanOnJoin = true`
- 重启插件：`restart lianban_client`
- 查看控制台是否有API错误

#### 5. UI界面显示异常

**症状**：面板打开后显示空白或样式错误

**解决方法**：
- 确认 `ui/` 文件夹完整（index.html, style.css, script.js）
- 检查 `fxmanifest.lua` 中 `files` 部分是否正确
- 清除浏览器缓存：`F8` → `resmon` → 重启资源

### 调试模式

如需调试，可以在 `server.lua` 中添加日志输出：

```lua
-- 在 MakeAllianceRequest 回调中添加
print(string.format("^2[DEBUG] API Response: %s^0", json.encode(decoded)))
```

---

## 📊 性能说明

- **内存占用**：约 1-2MB（含NUI）
- **进服检测延迟**：通常 < 500ms
- **查询响应时间**：平均 200-300ms
- **带宽消耗**：每次API请求约 1-5KB

---

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 开发环境搭建

1. Fork本仓库
2. 创建新分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 提交Pull Request

### 代码规范

- Lua代码遵循 [Lua Style Guide](https://github.com/Olivine-Labs/lua-style-guide)
- JavaScript使用ES6+语法
- CSS使用BEM命名规范

---

## 📝 更新日志

### v2.0.0 (2025-01-13)

**新增功能：**
- ✨ 重写NUI管理面板，全新深色主题
- ✨ 解除封禁需填写理由并等待审核
- ✨ 自适应卡片显示封禁信息和证据图片
- ✨ 支持QBCore框架

**改进：**
- 🔒 API密钥移至 `server_config.lua` 提升安全性
- 🎨 优化UI动画和交互体验
- 📝 完善错误提示和Toast通知
- ⚡ 优化API请求性能

**修复：**
- 🐛 修复多标识符检测逻辑
- 🐛 修复模态框关闭事件冲突
- 🐛 修复Standalone权限验证

### v1.0.0 (2024-12-01)

- 🎉 首次发布
- 基础封禁查询和提交功能
- ESX框架支持

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

---

## 🔗 相关链接

- **联盟封禁平台**：https://lianban.fivemzh.cn
- **API文档**：https://lianban.fivemzh.cn/docs
- **问题反馈**：[GitHub Issues](https://github.com/yourusername/lianban_client/issues)
- **FiveM论坛**：[讨论帖](https://forum.cfx.re/)

---

## 👥 致谢

- **开发者**：六万 (FiveM中文社区)
- **平台支持**：联盟封禁平台团队
- **社区贡献者**：感谢所有提交反馈和建议的用户

---

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- **GitHub Issues**：[提交问题](https://github.com/yourusername/lianban_client/issues)
- **邮箱**：support@fivemzh.cn
- **QQ群**：123456789（FiveM中文社区）

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个Star支持一下！⭐**

Made with ❤️ by FiveM中文社区

</div>
