# 暴雨100天 — Agent 开发指引

## 引擎与工具链

- Godot 4.7 Standard + GDScript + GL Compatibility。不要更换引擎、语言或渲染方案。
- 当前主工程：`versions/2d/project.godot`。主场景：`versions/2d/scenes/main.tscn`。
- `versions/3d/` 是冻结的第一人称房屋实验版。除非用户明确要求恢复 3D，否则不要继续修改。
- 项目以中文为 UI 和内容语言；提交信息和代码注释也用中文。

## 架构要点

- 2D 主工程的主控制器是 `versions/2d/scripts/main.gd`，全局状态是 `versions/2d/scripts/game_state.gd`，事件系统是 `versions/2d/scripts/event_manager.gd`。
- `versions/2d/scripts/world_map.gd` 程序化绘制房屋楼层、房间、家具、碰撞和互动点；当前地图只保留房屋内部与封闭窗边观察区，屋外为黑幕，不制作车库、前院或可漫游阳台。
- `versions/3d/` 与 2D 工程互不跨目录引用资源，仅作为冻结实验版保留。
- PRD 在 `docs/暴雨100天_PRD_v0.1.md`，开发顺序见其第 18 节。

## 测试

- 使用 Godot MCP 工具运行项目并测试，不要只靠代码阅读判断可用。
- 当前 2D 冒烟测试：打开 `versions/2d/project.godot` → 启动项目 → 检查一楼/二楼/玄关/窗边 → 用 F1 跳到目标阶段 → 走完新内容并检查报错。
- 3D 冒烟测试只在用户要求恢复 3D 时执行。
- `F1` 调试菜单只在 `OS.is_debug_build()` 下显示，正式构建自动隐藏。
- 每新增一个需要重复前置流程才能到达的阶段，都要在 F1 菜单加跳转入口。

## 关键惯例

### 事件系统

- 事件系统尚未迁入3D。迁移时将确认使用的事件放到 `versions/3d/data/events/*.json`。
- 每个事件必须有：唯一 ID、阶段、条件、正文、选项、结果、合流点。
- 选项影响以小变化 + 延迟回响为主；用 `schedule_event` 安排跨日延迟事件。
- 新增效果类型时同步更新 `event_manager.gd` 的 `_apply_effect`、`_effects_summary` 和存档逻辑。

### HUD 目标

- HUD 必须始终显示当前目标，包含地点、对象和动作。
- 阶段、日期或关键选择变化后立即刷新目标文本。
- 版本结束处明确提示"当前版本到此结束"，不能让玩家以为卡死。

### 快捷移动

- `T` 键快捷移动只改位置，不推进时间、不触发事件；外出事件不再依赖街道地图。
- 修改地图或碰撞后复测一楼、二楼、玄关、窗边和屋顶信息点落点。

### 存档

- 使用 `F5` 保存 / `F9` 读取；新增状态变量必须同步加入 `save_checkpoint` 和 `load_checkpoint`。

## Git 交付

- 原子化提交：一个提交只表达一个清楚目的。
- 提交前运行 `git diff --check`，确认没有意外文件（`project.godot` 常被编辑器自动重写，不要提交无意义改动）。
- 不要提交 `.godot/` 目录（已在 .gitignore 中）。
