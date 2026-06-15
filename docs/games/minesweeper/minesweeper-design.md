# 扫雷平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的扫雷（Minesweeper）小游戏模块。
- **模式**：单人
- **难度**：初级（9×9, 10雷）、中级（16×16, 40雷）、高级（30×16, 99雷）
- **操作**：点击翻开 / 长按标记

## 2. 文件结构

```
code/lib/src/games/minesweeper/
├── game_minesweeper_module.dart      # GameModule 实现
├── models/
│   └── minesweeper_session.dart      # 游戏会话
├── logic/
│   ├── minesweeper_engine.dart       # 核心引擎（布雷、翻开、判定）
│   └── flood_fill.dart              # 区域展开算法
├── pages/
│   ├── minesweeper_start_page.dart  # 开始页（选难度）
│   └── minesweeper_play_page.dart   # 对局页
└── widgets/
    ├── mine_grid.dart                # 网格绘制
    ├── cell_widget.dart              # 格子组件
    └── mine_counter.dart             # 剩余雷数/计时器
```

## 3. 数据结构

### 3.1 格子状态

| 值 | 含义 |
|----|------|
| -1 | 未翻开 |
| 0-8 | 已翻开，周围雷数 |
| 9 | 标记为雷（旗子） |
| 10 | 标记为问号 |

### 3.2 游戏会话 (MinesweeperSession)

```dart
class MinesweeperSession {
  List<List<int>> board;          // 盘面状态
  List<List<bool>> mines;         // 雷的位置（内部）
  int rows;                       // 行数
  int cols;                       // 列数
  int totalMines;                 // 总雷数
  int revealedCount;              // 已翻开格子数
  int flagCount;                  // 已标记旗子数
  bool isGameOver;                // 是否结束
  bool isWin;                     // 是否获胜
  bool firstClick;                // 是否首次点击
  int elapsedSeconds;             // 已用秒数
  int startTimeMs;                // 开始时间
}
```

### 3.3 难度预设

| 难度 | 行×列 | 雷数 |
|------|--------|------|
| 初级 | 9×9 | 10 |
| 中级 | 16×16 | 40 |
| 高级 | 16×30 | 99 |

## 4. 游戏流程

```
开始
  ├─ 选择难度
  ├─ 初始化空盘面
  ├─ 首次点击 → 布雷（避开首次点击位置及其周围）
  └─ 进入操作循环：
       ├─ 点击未翻开格子 → 翻开：
       │    ├─ 是雷 → 游戏结束（失败）
       │    ├─ 周围雷数=0 → 自动展开相邻区域
       │    └─ 周围雷数>0 → 显示数字
       ├─ 长按/右键 → 标记旗子
       └─ 所有非雷格子翻开 → 胜利
```

## 5. 核心规则

| 规则 | 说明 |
|------|------|
| 首次安全 | 首次点击不会是雷，且该位置周围8格也不会是雷 |
| 数字含义 | 该格子周围8格中的雷数 |
| 自动展开 | 翻开0的格子时，自动展开相邻格子 |
| 标记 | 旗子标记疑雷位置，不影响胜利判定 |
| 胜利 | 所有非雷格子被翻开 |
| 失败 | 点击到雷 |

## 6. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         扫雷                 │
│      经典逻辑推理            │
│                             │
│   ┌─────────────────────┐   │
│   │  初级 9×9 10雷       │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │  中级 16×16 40雷     │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │  高级 16×30 99雷     │   │
│   └─────────────────────┘   │
│        游戏规则              │
└─────────────────────────────┘
```

### 7.2 对局页

```
┌─────────────────────────────┐
│  ← 返回   扫雷   重新开始    │
│  🚩 xxx  ⏱ xxx             │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │      扫雷网格          │  │
│  │   (可滚动/缩放)        │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│   点击翻开 / 长按标记        │
└─────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 未翻开 | 浅色凸起方块 |
| 已翻开 | 深色凹陷方块 + 数字 |
| 数字1-8 | 各颜色区分（蓝/绿/红/紫/…） |
| 雷 | 炸弹图标 + 红色背景 |
| 旗子 | 红色三角旗 |
| 问号 | 灰色"?" |

## 9. GameMinesweeperModule 接入

```dart
class GameMinesweeperModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → MinesweeperStartPage
  // buildRuleEntry → MinesweeperStartPage(showRulesOnEntry: true)
  // createSessionSerializer → MinesweeperSession ↔ JSON
  // createResultAdapter → MinesweeperResult → 摘要
}
```

## 10. 验收标准

- [ ] 3种难度选择正常
- [ ] 首次点击安全（不是雷，周围也不是雷）
- [ ] 数字正确显示周围雷数
- [ ] 0格子自动展开
- [ ] 点击到雷 → 失败
- [ ] 所有非雷格子翻开 → 胜利
- [ ] 长按标记旗子/问号
- [ ] 计时器正确
- [ ] 网格可滚动（高级模式）
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)