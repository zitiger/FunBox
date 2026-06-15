# 扑克平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典扑克（Classic Poker）小游戏模块，采用德州扑克简化版。
- **模式**：1 人类玩家 + 2 AI 对手
- **玩法**：简化德州扑克（无翻牌/转牌/河牌阶段，直接比牌）
- **AI 强度**：中等（根据手牌强度决定跟注/弃牌）

## 2. 文件结构

```
code/lib/src/games/poker/
├── game_poker_module.dart    # GameModule 实现
├── models/
│   ├── card.dart                     # 扑克牌模型
│   └── poker_session.dart           # 游戏会话
├── logic/
│   ├── poker_engine.dart            # 发牌、比牌、筹码管理
│   ├── hand_evaluator.dart          # 牌型识别与比较
│   └── ai_strategy.dart            # AI 下注决策
├── pages/
│   ├── poker_start_page.dart        # 开始页
│   └── poker_play_page.dart         # 对局页
└── widgets/
    ├── card_widget.dart             # 单张牌组件
    ├── player_hand_widget.dart      # 手牌展示
    ├── chip_widget.dart             # 筹码显示
    └── action_bar_widget.dart       # 操作栏（跟注/加注/弃牌）
```

## 3. 数据结构

### 3.1 扑克牌 (Card)

| 字段 | 类型 | 说明 |
|------|------|------|
| `suit` | `CardSuit` | 花色：spade / heart / club / diamond |
| `rank` | `int` | 点数：2=2, 3=3, …, 13=K, 14=A |

### 3.2 游戏会话 (PokerSession)

```dart
class PokerSession {
  List<Card> playerHand;          // 玩家手牌（2张）
  List<Card> ai1Hand;             // AI1手牌（2张）
  List<Card> ai2Hand;             // AI2手牌（2张）
  List<Card> communityCards;      // 公共牌（5张）
  List<Card> deck;                // 剩余牌堆
  int playerChips;                // 玩家筹码
  int ai1Chips;                   // AI1筹码
  int ai2Chips;                   // AI2筹码
  int pot;                        // 当前底池
  int currentBet;                 // 当前下注额
  int currentPlayer;              // 当前操作玩家（0/1/2）
  int dealerIndex;                // 庄家位置
  GamePhase phase;                // 游戏阶段
  bool gameOver;                  // 是否结束
  int winnerIndex;                // 获胜者（-1=未结束）
}
```

### 3.3 游戏阶段

```dart
enum PokerPhase { dealing, preflop, flop, turn, river, showdown, finished }
```

## 4. 牌型系统（10种）

| 牌型 | 英文 | 说明 |
|------|------|------|
| 皇家同花顺 | Royal Flush | 同花色的 A-K-Q-J-10 |
| 同花顺 | Straight Flush | 同花色的连续5张 |
| 四条 | Four of a Kind | 4张同点数 |
| 葫芦 | Full House | 3条+1对 |
| 同花 | Flush | 5张同花色 |
| 顺子 | Straight | 5张连续（A可作为最小） |
| 三条 | Three of a Kind | 3张同点数 |
| 两对 | Two Pair | 2对 |
| 一对 | One Pair | 1对 |
| 高牌 | High Card | 无以上牌型，比最大单张 |

## 5. 游戏流程

```
开始
  ├─ 每人起始筹码 1000
  ├─ 庄家位随机确定
  ├─ 每人发 2 张底牌
  └─ 进入下注轮：
       ├─ 翻牌前（Pre-flop）：仅看手牌下注
       ├─ 翻牌（Flop）：发3张公共牌 → 下注
       ├─ 转牌（Turn）：发1张公共牌 → 下注
       ├─ 河牌（River）：发1张公共牌 → 下注
       └─ 摊牌（Showdown）：比牌，胜者赢得底池
```

### 5.1 下注选项

| 选项 | 说明 |
|------|------|
| 弃牌（Fold） | 放弃本局，已投入筹码不退回 |
| 过牌（Check） | 无人下注时可选择不下注 |
| 跟注（Call） | 投入与当前下注额相同的筹码 |
| 加注（Raise） | 投入超过当前下注额的筹码 |

## 6. AI 策略

```
轮到 AI 下注：
  1. 评估手牌强度（0-1 之间）
  2. 手牌强度 > 0.7 → 加注
  3. 手牌强度 0.4-0.7 → 跟注
  4. 手牌强度 < 0.4 → 弃牌
  5. 筹码不足时更保守
```

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│       经典扑克               │
│      简化德州扑克            │
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
│  ← 返回   经典扑克   设置    │
│                             │
│        AI1 筹码:xxx         │
│      [AI1手牌(牌背)]         │
│                             │
│  ┌───────────────────────┐  │
│  │    公共牌 5张          │  │
│  │    [底池: xxx]         │  │
│  └───────────────────────┘  │
│                             │
│        AI2 筹码:xxx         │
│      [AI2手牌(牌背)]         │
│                             │
│      [玩家手牌 2张]          │
│  筹码:xxx                    │
│  ┌──────┬──────┬──────┐     │
│  │ 弃牌 │ 跟注  │ 加注  │     │
│  └──────┴──────┴──────┘     │
└─────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 牌面 | 白底 + 角标点数 + 中央花色 |
| 花色色值 | ♥♦ 红色 `#E53E3E`，♠♣ 黑色 `#1A1A2E` |
| 筹码 | 圆形筹码图标 + 数字 |
| 底池 | 居中卡片展示 |

## 9. GamePokerModule 接入

```dart
class GamePokerModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → PokerStartPage
  // buildRuleEntry → PokerStartPage(showRulesOnEntry: true)
  // createSessionSerializer → PokerSession ↔ JSON
  // createResultAdapter → PokerResult → 摘要
}
```

## 10. 验收标准

- [ ] 启动游戏 → 每人发2张底牌，5张公共牌
- [ ] 10种牌型正确识别和比较
- [ ] 下注流程完整（弃牌/跟注/加注）
- [ ] 底池正确分配
- [ ] 筹码不足时正确判定
- [ ] AI 自动下注决策
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)