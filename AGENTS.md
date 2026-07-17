# 暴雨100天 — Agent 开发指引

## 引擎与工具链

- Godot 4.7 Standard + GDScript + GL Compatibility。不要更换引擎、语言或渲染方案。
- 主场景：`scenes/main.tscn`。Autoload：`GameState`（`scripts/game_state.gd`）、`EventManager`（`scripts/event_manager.gd`）。
- 项目以中文为 UI 和内容语言；提交信息和代码注释也用中文。

## 架构要点

- `main.gd`（Node2D）是主控制器，负责阶段调度、互动分发和流程编排。
- `game_state.gd` 是全局状态单例：物资、家庭成员、时间、标记、存档。
- `event_manager.gd` 启动时扫描 `data/events/*.json` 并合并加载，按 ID 索引；新事件写入 JSON，不要硬编码进 `main.gd`。
- `hud.gd` 全部 UI 用代码动态构建，不依赖 .tscn 节点树。
- `world_map.gd` 按楼层程序化绘制灰盒地图、碰撞和互动点。
- PRD 在 `docs/暴雨100天_PRD_v0.1.md`，开发顺序见其第 18 节。

## 测试

- 使用 Godot MCP 工具运行项目并测试，不要只靠代码阅读判断可用。
- 冒烟测试流程：启动项目 → F1 调试工具跳转到目标阶段 → 走完新内容 → 检查无报错。
- `F1` 调试菜单只在 `OS.is_debug_build()` 下显示，正式构建自动隐藏。
- 每新增一个需要重复前置流程才能到达的阶段，都要在 F1 菜单加跳转入口。

## 关键惯例

### 事件系统

- 事件数据放 `data/events/*.json`，每个事件必须有：唯一 ID、阶段、条件、正文、选项、结果、合流点。
- 选项影响以小变化 + 延迟回响为主；用 `schedule_event` 安排跨日延迟事件。
- 新增效果类型时同步更新 `event_manager.gd` 的 `_apply_effect`、`_effects_summary` 和存档逻辑。

### HUD 目标

- HUD 必须始终显示当前目标，包含地点、对象和动作。
- 阶段、日期或关键选择变化后立即刷新目标文本。
- 版本结束处明确提示"当前版本到此结束"，不能让玩家以为卡死。

### 快捷移动

- `T` 键快捷移动必须保留，只改楼层和位置，不推进时间、不触发事件。
- 修改地图或碰撞后复测所有快捷移动落点。

### 存档

- `F5` 保存 / `F9` 读取。新增状态变量必须同步加入 `save_checkpoint` 和 `load_checkpoint`。

## Git 交付

- 原子化提交：一个提交只表达一个清楚目的。
- 提交前运行 `git diff --check`，确认没有意外文件（`project.godot` 常被编辑器自动重写，不要提交无意义改动）。
- 不要提交 `.godot/` 目录（已在 .gitignore 中）。
