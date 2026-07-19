# 暴雨100天 — Agent 开发指引

## 引擎与工具链

- Godot 4.7 Standard + GDScript + GL Compatibility。不要更换引擎、语言或渲染方案。
- 当前主工程：`versions/3d/project.godot`。主场景：`versions/3d/scenes/house_prototype.tscn`。
- `versions/2d/` 是冻结的旧版工程。除非用户明确要求修复或恢复2D版本，否则不要继续修改。
- 项目以中文为 UI 和内容语言；提交信息和代码注释也用中文。

## 架构要点

- 当前3D房屋由 `versions/3d/scripts/house_prototype.gd` 程序化搭建；第一人称控制器是 `versions/3d/scripts/first_person_controller.gd`。
- 2D版的事件、状态、物资、HUD和存档实现保存在 `versions/2d/scripts/`，需要时选择性迁移到3D，不复制2D地图、摄像机、碰撞或坐标逻辑。
- 两个Godot工程互不跨目录引用资源。迁移后的代码和数据只在3D工程中继续维护。
- PRD 在 `docs/暴雨100天_PRD_v0.1.md`，开发顺序见其第 18 节。

## 测试

- 使用 Godot MCP 工具运行项目并测试，不要只靠代码阅读判断可用。
- 当前3D冒烟测试：打开 `versions/3d/project.godot` → 启动项目 → 走遍一楼、楼梯和二楼 → 切换1—7档水位 → 检查碰撞和报错。
- 迁移剧情系统后，再恢复“F1跳转阶段并走完新内容”的剧情冒烟流程。
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

- 2D版的 `T` 键快捷移动约束在机制迁入3D后继续保留：只改位置，不推进时间、不触发事件。
- 修改地图或碰撞后复测所有快捷移动落点。

### 存档

- 2D版使用 `F5` 保存 / `F9` 读取；存档系统迁入3D后，新增状态变量仍须同步加入保存和读取逻辑。

## Git 交付

- 原子化提交：一个提交只表达一个清楚目的。
- 提交前运行 `git diff --check`，确认没有意外文件（`project.godot` 常被编辑器自动重写，不要提交无意义改动）。
- 不要提交 `.godot/` 目录（已在 .gitignore 中）。
