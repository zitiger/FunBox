# 五子棋平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的五子棋（Gomoku）小游戏模块。
- **模式**：双人对战（本地同屏） 或 人机对战
- **棋盘**：15×15 标准棋盘
- **规则**：无禁手，先连成五子者获胜
- **AI 强度**：中等（防守+进攻平衡）

## 2. 文件结构

```
code/lib/src/games/gomoku/
├── game_gomoku_module.dart          # GameModule 实现
├── models/
│   └── gomoku_session.dart          # 游戏会话数据模型
├── logic/
│   ├── gomoku_engine.dart           # 核心引擎（落子、胜负判定）
│   └── ai_strategy.dart             # AI 落子决策
├── pages/
│   ├── gomoku_start_page.dart       # 开始页（选模式）
│   └── gomoku_play_page.dart        # 对局页
└── widgets/
    ├── gomoku_board.dart            # 棋盘绘制
    ├── stone_widget.dart            # 棋子组件
    └── gomoku_score_panel.dart      # 比分面板
```

## 3. 数据结构

### 3.1 棋盘状态

棋盘使用 15×15 二维数组表示。

| 值 | 含义 |
|----|------|
| `0` | 空位 |
| `1` | 黑子 |
| `2` | 白子 |

### 3.2 游戏会话 (GomokuSession)

```dart
class GomokuSession {
  List<List<int>> board;        // 15×15 棋盘
  int currentPlayer;            // 1=黑方, 2=白方
  int playerSide;               // 人类玩家执黑/白（1/2）
  GameMode mode;                // pvp（双人）或 pve（人机）
  List<Point> moveHistory;      // 落子历史
  int moveCount;                // 已落子数
  bool isGameOver;              // 是否结束
  int winner;                   // 获胜方（0=未结束, 1=黑胜, 2=白胜, 3=平局）
  int blackWins;                // 黑方胜局数
  int whiteWins;                // 白方胜局数
  int startTimeMs;              // 开始时间
  int elapsedMs;                // 已用时间
}
```

### 3.3 游戏阶段

```dart
enum GomokuPhase { playing, finished }
```

## 4. 游戏流程

```
开始
  ├─ 进入开始页 → 选择模式（双人对战 / 人机对战）
  ├─ 人机模式：玩家执黑先手
  ├─ 双人模式：黑方先手
  └─ 进入回合循环：
       ├─ 当前玩家选择空位落子
       ├─ 检查五连 → 有则当前玩家获胜
       ├─ 检查棋盘满 → 满则平局
       └─ 切换玩家
```

## 5. 胜负判定

| 结果 | 条件 |
|------|------|
| 黑胜 | 黑子横向/纵向/斜向（45°/135°）连成5子 |
| 白胜 | 白子连成5子 |
| 平局 | 棋盘落满且无人连五 |
| 禁手 | 首版不引入禁手规则 |

## 6. AI 策略

### 6.1 决策流程

```
轮到 AI 落子：
  1. 检查是否能五连获胜 → 优先落子
  2. 检查对手是否即将五连 → 必须堵
  3. 检查是否能形成活四/双三 → 进攻
  4. 防守对手的活三/活四
  5. 无威胁时选择靠近中心的空位
```

### 6.2 评估函数

对每个候选位置评分：
- 五连：+10000
- 活四：+1000
- 双活三：+500
- 单活三：+100
- 活二：+10

同等评分下选择靠近棋盘中心的位置。

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         五子棋               │
│      连成五子即获胜           │
│                             │
│   ┌─────────────────────┐   │
│   │     双人对战         │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │     人机对战         │   │
│   └─────────────────────┘   │
│                             │
│   胜场：黑 xx  白 xx         │
│                             │
│        游戏规则              │
└─────────────────────────────┘
```

### 7.2 对局页

```
┌─────────────────────────────┐
│  ← 返回   五子棋   重新开始   │
│  黑方 ★   白方 ○             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │      15×15 棋盘        │  │
│  │                       │  │
│  │                       │  │
│  └───────────────────────┘  │
│  当前回合：黑方              │
└─────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 棋盘 | 木纹底色 + 网格线，天元和星位标记 |
| 黑子 | 实心黑色圆 + 轻微光泽 |
| 白子 | 实心白色圆 + 轻微光泽 |
| 最后落子 | 红点标记 |
| 获胜连线 | 高亮连线效果 |

## 9. GameGomokuModule 接入

```dart
class GameGomokuModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → GomokuStartPage
  // buildRuleEntry → GomokuStartPage(showRulesOnEntry: true)
  // createSessionSerializer → GomokuSession ↔ JSON
  // createResultAdapter → GomokuResult → 摘要
}
```

## 10. 验收标准

- [ ] 开始页 → 选择双人/人机模式
- [ ] 棋盘正确渲染 15×15 网格
- [ ] 黑白双方轮流落子
- [ ] 不能在有棋子的位置落子
- [ ] 五连判定正确（横/竖/两对角线）
- [ ] 棋盘满时判定平局
- [ ] AI 能正常落子且响应时间 < 0.5s
- [ ] AI 能防守玩家的四连/三连
- [ ] 重开功能正常
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)