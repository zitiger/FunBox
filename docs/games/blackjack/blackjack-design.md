# 21点平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的21点（Blackjack）小游戏模块。
- **模式**：1 人类玩家 vs 庄家(AI)
- **用牌**：6副标准52张（共312张，含大小王但剔除）
- **目标**：手牌点数接近21点且不超过，超过庄家

## 2. 文件结构

```
code/lib/src/games/blackjack/
├── game_blackjack_module.dart       # GameModule 实现
├── models/
│   ├── card.dart                    # 扑克牌模型
│   └── blackjack_session.dart      # 游戏会话
├── logic/
│   ├── blackjack_engine.dart       # 发牌、计点、判定
│   └── dealer_ai.dart             # 庄家AI（固定规则）
├── pages/
│   ├── blackjack_start_page.dart   # 开始页
│   └── blackjack_play_page.dart    # 对局页
└── widgets/
    ├── card_widget.dart            # 单张牌组件
    ├── hand_widget.dart            # 手牌展示
    ├── chip_widget.dart            # 筹码显示
    └── action_bar_widget.dart      # 操作栏（要牌/停牌/双倍/分牌）
```

## 3. 数据结构

### 3.1 扑克牌 (Card)

| 字段 | 类型 | 说明 |
|------|------|------|
| `suit` | `CardSuit` | 花色 |
| `rank` | `int` | 点数：2-10=面值，J/Q/K=10，A=1或11 |

### 3.2 游戏会话 (BlackjackSession)

```dart
class BlackjackSession {
  List<Card> playerHand;          // 玩家手牌
  List<Card> dealerHand;          // 庄家手牌
  List<Card> deck;                // 牌堆
  int playerChips;                // 玩家筹码
  int currentBet;                 // 当前下注额
  bool dealerCardHidden;          // 庄家第二张牌是否隐藏
  bool isPlayerTurn;              // 是否玩家回合
  bool isGameOver;                // 是否结束
  String result;                  // 结果：win/lose/push/blackjack
  int startTimeMs;                // 开始时间
  int elapsedMs;                  // 已用时间
}
```

### 3.3 游戏阶段

```dart
enum BlackjackPhase { betting, dealing, playerTurn, dealerTurn, finished }
```

## 4. 游戏流程

```
开始
  ├─ 玩家下注
  ├─ 发牌：玩家2张（明牌），庄家2张（1明1暗）
  ├─ 检查黑杰克（21点）：
  │    ├─ 玩家21点 → 直接获胜（1.5倍赔率）
  │    ├─ 庄家21点 → 庄家胜
  │    └─ 双方21点 → 平局
  ├─ 玩家回合：
  │    ├─ 要牌（Hit）：再抽1张
  │    ├─ 停牌（Stand）：结束回合
  │    ├─ 双倍（Double）：筹码翻倍，再抽1张后停牌
  │    └─ 分牌（Split）：对子可分为两手
  ├─ 庄家回合（揭示暗牌，按规则抽牌）：
  │    庄家点数 < 17 → 必须抽牌
  │    庄家点数 ≥ 17 → 停牌
  └─ 比牌：点数大者胜，爆牌（>21）则负
```

## 5. 计点规则

| 牌 | 点数 |
|----|------|
| 2-10 | 面值 |
| J/Q/K | 10 |
| A | 1 或 11（取对玩家有利值） |

## 6. 庄家AI规则

庄家遵循固定规则（无策略变化）：
- 点数 < 17：必须抽牌
- 点数 ≥ 17：停牌
- 软17（A+6）：视具体规则，首版采用"庄家软17停牌"

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         21点                 │
│      经典纸牌博弈            │
│                             │
│   ┌─────────────────────┐   │
│   │     开始新局         │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │     继续游戏         │   │
│   └─────────────────────┘   │
│        游戏规则              │
└─────────────────────────────┘
```

### 7.2 对局页

```
┌─────────────────────────────┐
│  ← 返回   21点   筹码:xxx    │
│                             │
│      庄家手牌                │
│   [牌1] [牌2(暗)]           │
│   庄家点数: ?               │
│                             │
│  ┌───────────────────────┐  │
│  │      牌桌区域          │  │
│  └───────────────────────┘  │
│                             │
│      玩家手牌                │
│   [牌1] [牌2] [牌3] ...     │
│   玩家点数: 18               │
│                             │
│  下注: xxx                  │
│  ┌──────┬──────┬──────┐     │
│  │ 要牌 │ 停牌  │ 双倍  │     │
│  └──────┴──────┴──────┘     │
└─────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 牌面 | 白底 + 角标点数 + 中央花色 |
| 牌背 | 深蓝底 + 网格纹理 |
| 花色色值 | ♥♦ 红色，♠♣ 黑色 |
| 筹码 | 圆形筹码图标 + 数字 |
| 点数 | 大字显示当前点数 |

## 9. GameBlackjackModule 接入

```dart
class GameBlackjackModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → BlackjackStartPage
  // buildRuleEntry → BlackjackStartPage(showRulesOnEntry: true)
  // createSessionSerializer → BlackjackSession ↔ JSON
  // createResultAdapter → BlackjackResult → 摘要
}
```

## 10. 验收标准

- [ ] 启动游戏 → 玩家和庄家各发2张
- [ ] 黑杰克（21点）正确判定
- [ ] 要牌/停牌/双倍/分牌操作正常
- [ ] A计1或11正确
- [ ] 爆牌（>21）判定正确
- [ ] 庄家按规则自动抽牌
- [ ] 筹码计算正确
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)