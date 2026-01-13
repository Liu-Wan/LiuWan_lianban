Config = {}

-- 封禁检查配置
Config.CheckBanOnJoin = true -- 玩家进服时是否检查封禁

-- 框架设置: "standalone", "esx", "qbcore"
Config.Framework = "esx"

-- 管理员权限配置 (用于游戏内命令 /lbpanel 和 面板访问)
-- ESX/QBCore: 填写用户组名称 (如 "superadmin", "admin")
-- Standalone: 填写 ace 权限组名称 (如 "superadmin", "admin", 对应 group.superadmin)
Config.AdminGroups = {
    "superadmin",
    "admin"
}
