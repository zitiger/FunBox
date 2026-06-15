# 俄罗斯方块平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的俄罗斯方块（Tetris）小游戏模块。
- **模式**：单人
- **操作**：方向键 / 触屏手势
- **难度**：随等级提升下落速度加快

## 2. 文件结构

```
code/lib/src/games/tetris/
├── game_tetris_module.dart          # GameModule 实现
├── models/
│   └── tetris_session.dart          # 游戏会话
├── logic/
│   ├── tetris_engine.dart           # 主循环（下落、锁定、消行）
│   ├── tetromino.dart              # 7种方块定义
│   ├── board_state.dart            # 盘面状态
│   └── rotation_system.dart        # 旋转系统（SRS）
├── pages/
│   ├── tetris_start_page.dart      # 开始页
│   └── tetris_play_page.dart       # 对局页
└── widgets/
    ├── tetris_board.dart            # 盘面绘制
    ├── tetromino_block.dart         # 方块单元
    ├── next_piece_preview.dart      # 下一块预览
    └── tetris_score_panel.dart      # 分数面板
```

## 3. 数据结构

### 3.1 方块类型 (Tetromino)

7种标准方块，每种有4种旋转状态。

| 类型 | 名称 | 颜色 |
|------|------|------|
| I | 长条 | 青色 `#00D4FF` |
| O | 方形 | 黄色 `#FFD700` |
| T | T形 | 紫色 `#9B59B6` |
| S | S形 | 绿色 `#2ECC71` |
| Z | Z形 | 红色 `#E74C3C` |
| J | J形 | 蓝色 `#3498DB` |
| L | L形 | 橙色 `#E67E22` |

### 3.2 游戏会话 (TetrisSession)

```dart
class TetrisSession {
  List<List<int>> board;          // 盘面（10×20，0=空，其它=颜色索引）
  Tetromino currentPiece;         // 当前方块
  int currentX;                   // 当前方块X坐标
  int currentY;                   // 当前方块Y坐标
  int currentRotation;            // 当前旋转状态（0-3）
  Tetromino nextPiece;            // 下一块方块
  int score;                      // 当前分数
  int bestScore;                  // 历史最高分
  int level;                      // 当前等级
  int linesCleared;               // 已消行数
  int fallIntervalMs;             // 当前下落间隔
  bool isGameOver;                // 是否结束
  int startTimeMs;                // 开始时间
  int elapsedMs;                  // 已用时间
}
```

## 4. 游戏流程

```
开始
  ├─ 初始化 10×20 盘面（空）
  ├─ 随机生成第一个方块
  ├─ 方块从顶部中央开始下落
  └─ 进入主循环：
       ├─ 每 N 毫秒方块下落一格
       ├─ 玩家操作：
       │    ├─ 左/右：移动方块
       │    ├─ 下：加速下落
       │    ├─ 旋转：顺时针旋转
       │    └─ 硬降：直接落到底部
       ├─ 方块到达底部/碰撞 → 锁定到盘面
       ├─ 检查完整行 → 消除 + 计分
       ├─ 生成新方块
       └─ 新方块无法放置 → 游戏结束
```

## 5. 核心规则

| 规则 | 说明 |
|------|------|
| 移动 | 左右移动方块，遇墙/已锁定方块则停止 |
| 旋转 | 顺时针旋转90°，使用SRS踢墙旋转 |
| 软降 | 按下键加速下落 |
| 硬降 | 瞬间落到底部 |
| 消行 | 整行填满则消除，上方行下落 |
| 等级 | 每消10行升1级，下落速度加快 |
| 结束 | 新方块生成时与已有方块重叠 |

## 6. 计分规则

| 操作 | 得分 |
|------|------|
| 单消（1行） | 100 × 等级 |
| 双消（2行） | 300 × 等级 |
| 三消（3行） | 500 × 等级 |
| 四消（Tetris） | 800 × 等级 |
| 软降 | 每格 +1 |
| 硬降 | 每格 +2 |

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│      俄罗斯方块              │
│    经典方块消除              │
│                             │
│   ┌─────────────────────┐   │
│   │     开始新局         │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │     继续游戏         │   │
│   └─────────────────────┘   │
│                             │
│   最高分：xxx                │
│                             │
│        游戏规则              │
└─────────────────────────────┘
```

### 7.2 对局页

```
┌──────────────────────────────────────┐
│  ← 暂停  俄罗斯方块  分数:xxx         │
│                                      │
│  ┌──────────────┬───────────────┐   │
│  │              │  下一块        │   │
│  │              │  [预览]        │   │
│  │   10×20      │               │   │
│  │   盘面       │  等级: 5       │   │
│  │              │  行数: 42      │   │
│  │              │               │   │
│  │              │               │   │
│  └──────────────┴───────────────┘   │
│                                      │
│     [←] [↓] [→] [旋转] [硬降]        │
└──────────────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 盘面背景 | 深色网格底板 |
| 方块 | 7种颜色区分，带轻微立体感 |
| 锁定方块 | 方块颜色 + 边框 |
| 当前方块 | 方块颜色 + 轻微发光 |
| 幽灵方块 | 半透明预览（显示硬降位置） |

## 9. GameTetrisModule 接入

```dart
class GameTetrisModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → TetrisStartPage
  // buildRuleEntry → TetrisStartPage(showRulesOnEntry: true)
  // createSessionSerializer → TetrisSession ↔ JSON
  // createResultAdapter → TetrisResult → 摘要
}
```

## 10. 验收标准

- [ ] 启动游戏 → 方块从顶部下落
- [ ] 7种方块正确生成和旋转
- [ ] 左右移动 / 旋转 / 软降 / 硬降正常
- [ ] 消行判定正确（1/2/3/4行）
- [ ] 计分规则正确
- [ ] 等级提升后速度加快
- [ ] 方块到顶 → 游戏结束
- [ ] 下一块预览正确
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)