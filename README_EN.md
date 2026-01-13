# 🛡️ FiveM Alliance Ban System - Client Plugin

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)](https://fivem.net/)
[![Version](https://img.shields.io/badge/version-2.0.0-orange.svg)](https://github.com/yourusername/lianban_client)

**Cross-server Alliance Ban System - Real-time Synchronization of Cheater Database**

[Features](#features) • [Installation](#installation) • [Configuration](#configuration) • [Usage](#usage) • [FAQ](#faq)

[中文文档](README.md) | **English**

</div>

---

## 📖 Introduction

The FiveM Alliance Ban System Client Plugin is a powerful cross-server anti-cheat solution. By connecting to a centralized ban database, multiple FiveM servers can share and synchronize cheater information in real-time, creating an alliance protection network to effectively enhance server security.

### 🎯 Why Alliance Ban?

- **Single-server Limitation**: Cheaters can continue causing harm on other servers
- **Information Silos**: Ban data is not shared between servers
- **Duplicate Ban Cost**: Same cheater needs to be reported multiple times
- **Lag Issue**: Other servers cannot promptly know about new cheaters

### ✨ Solution

This plugin connects to the Alliance Ban Platform via API to achieve:
- ✅ Auto-check alliance blacklist when players join
- ✅ In-game one-click query player ban status
- ✅ Admins can directly submit bans to the network database
- ✅ Review system ensures mistaken bans can be appealed
- ✅ Beautiful NUI management panel

---

## 🚀 Features

### Core Functions

| Feature | Description |
|---------|-------------|
| **Auto Ban Detection** | Automatically queries alliance database when players join, blocks blacklisted players |
| **Admin Panel** | Open NUI interface in-game to manage ban records |
| **Ban Query** | Support query by identifier (Steam, License, etc.) |
| **Submit Ban** | Admins can submit new ban requests to alliance database |
| **Unban Request** | Support filling in reasons to request unban for mistaken bans |
| **Multi-framework Support** | Compatible with ESX, QBCore and Standalone mode |
| **Adaptive Card** | Ban notifications use FiveM Adaptive Card, displaying detailed info and evidence |

### Management Panel Functions

- 🔍 **Query Ban**: Input identifier to query ban status in real-time
- 📋 **My Submissions**: View ban records submitted by your server
- ⚖️ **Submit Ban**: Fill in identifier, reason, evidence image link to submit new ban
- 🔓 **Request Unban**: Fill in reason to request unban for submitted bans (requires admin review)

---

## 📦 Installation

### Prerequisites

- FiveM Server (artifact version >= 2802)
- Alliance Ban Platform account and API key
- (Optional) ESX or QBCore framework

### Installation Steps

1. **Download Plugin**

```bash
git clone https://github.com/yourusername/lianban_client.git
```

2. **Place in Resources Directory**

Put the `lianban_client` folder in your server's `resources` directory:

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

3. **Add to server.cfg**

Add startup item in `server.cfg`:

```cfg
ensure lianban_client
```

4. **Restart Server**

```bash
restart lianban_client
# Or restart the entire server
```

---

## ⚙️ Configuration

### 1. config.lua (Client Config)

```lua
Config = {}

-- Alliance Ban Platform API URL (without /api)
Config.ApiUrl = "https://lianban.fivemzh.cn"

-- Check ban when player joins
Config.CheckBanOnJoin = true

-- Framework type: "standalone", "esx", "qbcore"
Config.Framework = "esx"

-- Admin permission groups
Config.AdminGroups = {
    "superadmin",
    "admin"
}
```

### 2. server_config.lua (Server-side Key)

```lua
ServerConfig = {}

-- Your API key (obtained from Alliance Ban Platform)
ServerConfig.ApiKey = "your_64_character_api_key_here"
```

> ⚠️ **Security Note**:
> - `server_config.lua` is server-side only, not sent to clients
> - Do not share your API key with others
> - If key is leaked, regenerate immediately on platform

---

## 🎮 Usage

### Command List

| Command | Permission | Description |
|---------|-----------|-------------|
| `/lbpanel` | Admin | Open Alliance Ban management panel |

### Management Panel Guide

#### 1. Open Panel

Admin inputs command in-game:
```
/lbpanel
```

#### 2. Query Ban

- Switch to "Query Ban" tab
- Input player identifier (e.g., `steam:110000xxxxxxxx`, `license:xxxxx`)
- Click "Query" button
- System displays whether the identifier is banned and detailed info

#### 3. Submit Ban

- Switch to "Submit Ban" tab
- Fill in the following info:
  - **Identifier**: Player's unique identifier
  - **Ban Reason**: Detailed description of violation (e.g., "Using cheats", "Malicious destruction")
  - **Evidence Link**: Upload screenshot/video to image host and paste link
- Click "Submit Ban"
- Wait for platform admin review (takes effect after approval)

#### 4. View My Submissions

- Switch to "My Submissions" tab
- View all ban records submitted by this server
- Click "Request Unban" to request unban for submitted bans

#### 5. Request Unban

- Find the record to unban in "My Submissions"
- Click "Request Unban" button
- Fill in unban reason in popup (e.g., "Mistaken ban", "Insufficient evidence")
- Submit and wait for admin review

---

## 🔌 API Integration

### Platform Registration

1. Visit Alliance Ban Platform: https://lianban.fivemzh.cn
2. Register account and login
3. Go to console, copy API key
4. Fill key into `server_config.lua`

### API Endpoints

Plugin automatically calls the following API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/check_ban` | GET/POST | Check if identifier is banned |
| `/api/my_bans` | GET | Get ban records of this server |
| `/api/submit_ban` | POST | Submit new ban request |
| `/api/request_unban` | POST | Submit unban request |
| `/api/stats` | GET | Get platform statistics |

For detailed API documentation, please visit [API Docs](https://lianban.fivemzh.cn/docs)

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Plugin Won't Start

**Symptoms**: Server errors on startup or plugin doesn't load

**Solutions**:
- Check if `fxmanifest.lua` exists
- Confirm `ensure lianban_client` is added in `server.cfg`
- Check server console for error messages

#### 2. Cannot Connect to API

**Symptoms**: Prompt "Request Timeout or Connection Failure"

**Solutions**:
- Check if `Config.ApiUrl` is correct
- Confirm server can access external network
- Verify API key is correctly filled in `server_config.lua`

#### 3. Admin Cannot Open Panel

**Symptoms**: Input `/lbpanel` prompts "No permission"

**Solutions**:
- Check if `Config.AdminGroups` contains user's permission group
- ESX users: Execute `SELECT group FROM users WHERE identifier = 'xxx'` to confirm permission group
- QBCore users: Check `qb-core/shared/permissions.lua`
- Standalone: Execute `add_ace group.admin command.lbpanel allow`

---

## 📊 Performance

- **Memory Usage**: About 1-2MB (including NUI)
- **Join Detection Delay**: Usually < 500ms
- **Query Response Time**: Average 200-300ms
- **Bandwidth Consumption**: About 1-5KB per API request

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

### Development Environment Setup

1. Fork this repository
2. Create new branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add some feature'`
4. Push branch: `git push origin feature/your-feature`
5. Submit Pull Request

---

## 📝 Changelog

### v2.0.0 (2025-01-13)

**New Features:**
- ✨ Redesigned NUI management panel with new dark theme
- ✨ Unban requires filling in reason and awaiting review
- ✨ Adaptive card displays ban info and evidence images
- ✨ QBCore framework support

**Improvements:**
- 🔒 Moved API key to `server_config.lua` for enhanced security
- 🎨 Optimized UI animations and interaction experience
- 📝 Improved error messages and toast notifications
- ⚡ Optimized API request performance

**Fixes:**
- 🐛 Fixed multi-identifier detection logic
- 🐛 Fixed modal close event conflicts
- 🐛 Fixed Standalone permission verification

### v1.0.0 (2024-12-01)

- 🎉 Initial release
- Basic ban query and submission functions
- ESX framework support

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

---

## 🔗 Links

- **Alliance Ban Platform**: https://lianban.fivemzh.cn
- **API Documentation**: https://lianban.fivemzh.cn/docs
- **Issue Tracker**: [GitHub Issues](https://github.com/yourusername/lianban_client/issues)
- **FiveM Forum**: [Discussion Thread](https://forum.cfx.re/)

---

## 👥 Credits

- **Developer**: Liuwan (FiveM Chinese Community)
- **Platform Support**: Alliance Ban Platform Team
- **Community Contributors**: Thanks to all users who submitted feedback and suggestions

---

## 📞 Contact

For questions or suggestions, please contact via:

- **GitHub Issues**: [Submit Issue](https://github.com/yourusername/lianban_client/issues)
- **Email**: support@fivemzh.cn

---

<div align="center">

**⭐ If this project helps you, please give it a Star! ⭐**

Made with ❤️ by FiveM Chinese Community

</div>
