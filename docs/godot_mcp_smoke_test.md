# Godot MCP 冒烟测试

本项目的 2D 主版本和 3D 实验版本都已接入 [WhiteGiverMa/godot-mcp](https://github.com/WhiteGiverMa/godot-mcp)。MCP 源码和 Godot 可执行文件放在本地 `tools/`，该目录已加入 `.gitignore`，不会进入游戏提交。

## 当前接入

- MCP 构建入口：`tools/godot-mcp/build/index.js`
- Godot：`tools/godot/4.7-stable/Godot_v4.7-stable_win64_console.exe`
- 2D 运行时脚本：`versions/2d/scripts/mcp_interaction_server.gd`
- 3D 运行时脚本：`versions/3d/scripts/mcp_interaction_server.gd`
- 自动加载：两个版本的 `project.godot` 都包含 `McpInteractionServer`
- 端口：`127.0.0.1:9090`

## MCP 客户端配置

将下面的配置中的路径替换为本机项目绝对路径：

```json
{
  "mcpServers": {
    "godot-mcp": {
      "command": "node",
      "args": ["C:/项目路径/tools/godot-mcp/build/index.js"],
      "env": {
        "GODOT_PATH": "C:/项目路径/tools/godot/4.7-stable/Godot_v4.7-stable_win64_console.exe",
        "GODOT_PROJECT_PATH": "C:/项目路径/versions/2d"
      }
    }
  }
}
```

## 已验证的冒烟流程

1. Godot 4.7 以 headless debug 启动当前主版本 `versions/2d/scenes/main.tscn`（需要验证 3D 时改为 `versions/3d/scenes/house_prototype.tscn`）。
2. MCP 运行时服务器成功监听 `127.0.0.1:9090`。
3. 通过 TCP MCP 指令 `get_scene_tree` 读取场景树，确认 `McpInteractionServer`、主场景和 `Player` 均存在。
4. 通过 `get_property` 读取玩家节点的 `position`，返回出生点坐标；2D 路径为 `/root/Main/Player`，3D 路径为 `/root/HousePrototype/Player`。
5. godot-mcp 自身测试通过：426/426。

以后改动 2D 地图或 3D 房屋后，优先重复对应版本的流程，再做画面和操作层面的人工检查。
