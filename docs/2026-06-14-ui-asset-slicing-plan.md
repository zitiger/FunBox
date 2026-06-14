# FunBox 高保真界面切图清单

日期：2026-06-14

## 已确认设计稿

- 首页：[design/final/home-approved.png](</D:/Projects/flutter/FunBox/design/final/home-approved.png>)
- 分类：[design/final/category-approved.png](</D:/Projects/flutter/FunBox/design/final/category-approved.png>)
- 收藏：[design/final/favorites-approved.png](</D:/Projects/flutter/FunBox/design/final/favorites-approved.png>)
- 设置：[design/final/settings-approved.png](</D:/Projects/flutter/FunBox/design/final/settings-approved.png>)

说明：

- 以上 4 张图用于高保真确认和后续切图参考。
- 不建议把整屏图直接作为运行时素材；应根据下方清单拆成可复用静态资产，并由代码负责布局、文字、状态和交互。

## 资产原则

- 同一个游戏在首页最近游戏、推荐游戏、分类、收藏中，优先复用同一张 `icon`。
- 卡片背景、按钮、胶囊分类、开关、底部导航等，优先用代码绘制。
- 游戏进度、百分比、最近游玩时间、按钮文案、分类名称等动态信息，必须由代码渲染。
- 只有“带明显插画/质感”的视觉元素才建议切成图片。

## 建议保留为图片的静态资产

### 游戏图标

目标目录：

- `code/games/<slug>/assets/images/icon.png`

建议文件：

- `code/games/landlord/assets/images/icon.png`
- `code/games/2048/assets/images/icon.png`
- `code/games/snake/assets/images/icon.png`
- `code/games/minesweeper/assets/images/icon.png`
- `code/games/gomoku/assets/images/icon.png`
- `code/games/solitaire/assets/images/icon.png`
- `code/games/airplane/assets/images/icon.png`
- `code/games/tetris/assets/images/icon.png`

用途：

- 首页最近游戏
- 首页推荐卡片
- 分类页 3 列游戏网格
- 收藏页游戏卡片

## 建议保留为图片的插画类元素

目标目录：`code/assets/images/home/`

建议文件：

- `home_feature_illustration.png`

说明：

- 首页 Banner 建议只切中间的插画主体。
- Banner 的标题、副标题、按钮、标签不建议切图，全部由代码绘制。

## 建议由代码绘制的界面元素

- 页面标题
- 搜索按钮容器与搜索图标
- 分类胶囊
- 推荐卡片容器
- 收藏卡片容器
- 设置页分组卡片
- 开始 / 继续按钮
- 底部导航栏
- 所有文字
- 所有进度、百分比、状态标签

## 命名方案

### 游戏图标

- 目录格式：`games/<slug>/assets/images/icon.png`
- 示例：`games/landlord/assets/images/icon.png`

### 首页插画

- 格式：`home_<role>.png`
- 示例：`home_feature_illustration.png`

### 如果后续需要独立装饰物

- 格式：`decor_<scene>_<name>.png`
- 示例：`decor_home_star.png`

### 平台级入口图标

- 目录格式：`assets/images/icons/<name>.png`
- 示例：`assets/images/icons/more_games.png`

## 不建议继续沿用的旧命名

以下命名更像“按页面位置裁切”，复用性较差，建议后续逐步替换：

- `recent_2048.png`
- `recent_gomoku.png`
- `recent_landlord.png`
- `recent_minesweeper.png`
- `recent_snake.png`
- `card_2048.png`
- `card_gomoku.png`
- `card_landlord.png`
- `card_minesweeper.png`
- `card_more_games.png`
- `card_snake.png`

建议改为以“游戏本体图标”为核心，再由代码包裹成不同尺寸卡片。

## 推荐目录结构

```text
design/
  final/
    home-approved.png
    category-approved.png
    favorites-approved.png
    settings-approved.png

code/
  games/
    landlord/assets/images/icon.png
    2048/assets/images/icon.png
    snake/assets/images/icon.png
    minesweeper/assets/images/icon.png
    gomoku/assets/images/icon.png
    solitaire/assets/images/icon.png
    airplane/assets/images/icon.png
    tetris/assets/images/icon.png
  assets/images/
    home/home_feature_illustration.png
    icons/more_games.png
```

## 下一步建议

- 先把可复用游戏图标统一重绘并落到各自游戏目录
- 再单独产出首页 Banner 插画主体
- 最后由 Flutter 代码拼出首页、分类、收藏、设置的真实界面
