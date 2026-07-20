# 暴雨100天

项目当前回到 2D 俯视原型，优先验证前七天剧情、房屋内动线和水位表现。

## 目录

- `versions/2d/`：当前主开发版本，使用 Godot 4.7 制作房屋内 2D 游戏。
- `versions/3d/`：冻结的第一人称 3D 房屋实验版，仅用于对比和回退。
- `docs/`：两个版本共用的设计讨论、机制、剧情和PRD文档。

## 打开项目

- 开发当前版本：用 Godot 打开 `versions/2d/project.godot`。
- 查看 3D 实验版：用 Godot 打开 `versions/3d/project.godot`。

根目录本身不再是Godot工程，避免编辑器误开旧版或重新生成一套混合缓存。
