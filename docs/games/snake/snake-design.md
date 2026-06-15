# 贪吃蛇平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的贪吃蛇（Snake）小游戏模块。
- **模式**：单人即时操作
- **操作**：方向键 / 触屏滑动
- **难度**：蛇身越长速度越快

## 2. 文件结构

```
code/lib/src/games/snake/
├── game_snake_module.dart          # GameModule 实现
├── models/
│   └── snake_session.dart          # 游戏会话数据模型
├── logic/
│   ├── snake_engine.dart           # 核心引擎（移动、碰撞、食物生成）
│   └── snake_direction.dart        # 方向枚举
├── pages/
│   ├── snake_start_page.dart       # 开始页
│   └── snake_play_page.dart        # 对局页
└── widgets/
    ├── snake_board.dart            # 蛇盘面绘制
    └── snake_score_panel.dart      # 分数面板
```

## 3. 数据结构

### 3.1 蛇身

蛇身由坐标点列表表示，头部为列表首元素。

| 字段 | 类型 | 说明 |
|------|------|------|
| `body` | `List<Point>` | 蛇身坐标列表，[0] 为头部 |
| `direction` | `Direction` | 当前移动方向：up / down / left / right |
| `length` | `int` | 蛇身长度 |

### 3.2 游戏会话 (SnakeSession)

```dart
class SnakeSession {
  List<Point> snakeBody;        // 蛇身坐标
  Direction direction;          // 当前方向
  Point food;                   // 食物位置
  int score;                    // 当前分数
  int bestScore;                // 历史最高分
  int speed;                    // 当前速度（毫秒/步）
  int gridWidth;                // 网格宽度（列数）
  int gridHeight;               // 网格高度（行数）
  bool isPaused;                // 是否暂停
  bool isGameOver;              // 是否结束
  int startTimeMs;              // 开始时间
  int elapsedMs;                // 已用时间
}
```

### 3.3 游戏阶段

```dart
enum SnakePhase { ready, playing, paused, finished }
```

## 4. 游戏流程

```
开始
  ├─ 初始化 N×M 网格（建议 20×15）
  ├─ 蛇初始位置：网格中央偏左，长度 3
  ├─ 初始方向：向右
  ├─ 随机生成第一个食物
  └─ 进入游戏循环：
       ├─ 按固定间隔移动蛇头
       ├─ 吃到食物 → 长度+1，分数+10，生成新食物
       ├─ 撞墙/撞自身 → 游戏结束
       └─ 更新速度（每吃5个食物加速一次）
```

## 5. 核心规则

| 规则 | 说明 |
|------|------|
| 移动 | 蛇头按当前方向移动一格，身体跟随 |
| 吃食物 | 蛇头与食物重合，蛇身延长1格，分数+10 |
| 食物生成 | 在空位上随机生成，不与蛇身重叠 |
| 碰撞检测 | 蛇头撞墙 或 撞到自身蛇身 → 游戏结束 |
| 速度 | 初始 300ms/步，每吃5个食物减少 20ms（最低 80ms） |
| 方向限制 | 不能反向（如向右时不能直接向左） |

## 6. AI 策略

无 AI 对手，纯单人游戏。

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         贪吃蛇               │
│      经典吃豆成长            │
│                             │
│   ┌─────────────────────┐   │
│   │     开始新局         │   │
│   └─────────────────────┘   │
│                             │
│   最高分：xxx                │
│                             │
│        游戏规则              │
└─────────────────────────────┘
```

### 7.2 对局页

```
┌─────────────────────────────┐
│  ← 返回    贪吃蛇    暂停    │
│  分数：xxx   最高：xxx       │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │      游戏盘面          │  │
│  │    (网格+蛇+食物)      │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│   方向键 / 滑动操作引导      │
└─────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 网格背景 | 浅色方格 + 深色底板 |
| 蛇头 | 圆角矩形 + 眼睛（方向区分） |
| 蛇身 | 圆角矩形 + 渐变过渡 |
| 食物 | 圆形 + 红色/橙色 |
| 碰撞特效 | 蛇头变红闪烁 |

## 9. GameSnakeModule 接入

```dart
class GameSnakeModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → SnakeStartPage
  // buildRuleEntry → SnakeStartPage(showRulesOnEntry: true)
  // createSessionSerializer → SnakeSession ↔ JSON
  // createResultAdapter → SnakeResult → 摘要
}
```

## 10. 验收标准

- [ ] 启动游戏 → 蛇初始3格，向右移动
- [ ] 方向键/滑动正常控制蛇头方向
- [ ] 不能反向移动
- [ ] 吃到食物 → 长度+1，分数+10
- [ ] 食物随机生成在空位上
- [ ] 撞墙 → 游戏结束
- [ ] 撞自身 → 游戏结束
- [ ] 速度随长度增加而加快
- [ ] 暂停/恢复功能正常
- [ ] 存档恢复正常
- [ ] 最高分持久化

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)