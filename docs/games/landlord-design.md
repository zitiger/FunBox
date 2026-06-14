# 斗地主游戏开发设计文档

## 1. 概述

在 FunBox 平台中实现完整的斗地主（Fight the Landlord）小游戏模块。
- **模式**：1 人类玩家 + 2 AI 对手
- **牌型**：完整标准牌型（10种）
- **地主**：随机分配
- **AI 强度**：中等（能管则管、炸弹保留、阻止策略）

## 2. 文件结构

```
code/games/landlord/
├── assets/
│   └── images/
│       └── icon.png                     # 已有
└── game_manifest.yaml                   # 已有

code/lib/src/games/landlord/
├── game_landlord_module.dart            # GameModule 实现（注册、页面入口、存档适配）
├── models/
│   └── card.dart                        # 牌面模型 + 牌堆工具
├── logic/
│   ├── card_pattern.dart                # 牌型枚举 + 识别 + 比较规则
│   ├── game_engine.dart                 # 核心引擎（发牌、回合、胜负判定）
│   └── ai_strategy.dart                 # AI 出牌决策
├── pages/
│   ├── landlord_start_page.dart         # 开始页（新局 / 继续 / 规则）
│   └── landlord_play_page.dart          # 主游戏页（三栏布局 + 手牌交互）
└── widgets/
    ├── card_widget.dart                 # 单张牌组件（程序化绘制）
    ├── player_hand_widget.dart          # 底部手牌区（横向排列 + 选择交互）
    └── opponent_area_widget.dart        # AI 对手区域（牌背 + 头像 + 剩余张数）
```

## 3. 数据结构

### 3.1 牌面 (Card)

54 张牌，由 标准 52 张（♠♥♣♦ 各 A-K）+ 小王 + 大王 组成。

| 字段 | 类型 | 说明 |
|------|------|------|
| `suit` | `CardSuit` | 花色：spade / heart / club / diamond / joker |
| `rank` | `int` | 点数：3=3 … 13=K, 14=A, 15=2, 16=小王, 17=大王 |

**大小关系（升序）**：3 < 4 < 5 < 6 < 7 < 8 < 9 < 10 < J < Q < K < A < 2 < 小王 < 大王

**花色无关大小**，只在单牌点数相同时为同一级别。

### 3.2 游戏会话 (GameSession)

```dart
class GameSession {
  List<Card> playerHand;          // 玩家手牌
  int playerIndex;                // 0=人类, 1=AI左, 2=AI右
  int landlordIndex;              // 地主编号
  List<Card> holeCards;           // 底牌（3张）
  List<int> cardCounts;           // 三人剩余牌数
  int currentTurn;                // 当前回合玩家编号
  List<Card> lastPlay;            // 上一手出的牌
  int lastPlayPlayer;             // 上一手出牌玩家（-1=无人出）
  int roundCount;                 // 回合计数
  GamePhase phase;                // 游戏阶段
  bool gameOver;                  // 是否结束
  int winnerIndex;                // 获胜者编号（-1=未结束）
  int startTimeMs;                // 开始时间
  int elapsedMs;                  // 已用时间
}
```

### 3.3 游戏阶段 (GamePhase)

```dart
enum GamePhase { dealing, playing, finished }
```

## 4. 牌型系统（10 种完整牌型）

### 4.1 牌型枚举

| 牌型 | 英文 | 识别规则 |
|------|------|----------|
| `single` | 单牌 | 1 张 |
| `pair` | 对子 | 2 张同点数 |
| `triple` | 三条 | 3 张同点数 |
| `tripleWithOne` | 三带一 | 3 张同点 + 1 张任意 |
| `tripleWithPair` | 三带二 | 3 张同点 + 1 对 |
| `straight` | 顺子 | ≥5 张连续单牌（3-A），不含 2 和大小王 |
| `consecutivePairs` | 连对 | ≥3 对连续对子（3-A），不含 2 和大小王 |
| `plane` | 飞机 | ≥2 连三，可带等量单牌或对子作翅膀 |
| `bomb` | 炸弹 | 4 张同点数 |
| `rocket` | 火箭/王炸 | 大王 + 小王 |

### 4.2 牌型比较规则

| 比较场景 | 规则 |
|----------|------|
| 同类型普通牌型 | 比主牌（点数）：对子比点数，顺子比最大牌 |
| 炸弹 vs 普通 | 炸弹 > 任何普通牌型 |
| 炸弹 vs 炸弹 | 比点数 |
| 火箭 vs 任何 | 火箭 > 炸弹 > 普通 |
| 不同普通牌型 | 不可比较（必须同类型） |

## 5. 游戏流程

```
开始
  ├─ 洗牌 54 张
  ├─ 随机确定地主（0/1/2）
  ├─ 每人发 17 张，剩下 3 张为底牌
  ├─ 地主获得底牌
  ├─ 地主先出牌
  └─ 进入回合循环：
       ├─ 当前玩家操作：出牌 或 不出(Pass)
       ├─ 出牌 → 校验牌型 + 比较大小 → 更新 lastPlay
       ├─ 不出 → lastPlay 不变（若连续 2 人不出，lastPlay 清空）
       ├─ 某玩家手牌清空 → 该玩家获胜
       └─ 换下一位玩家
```

### 5.1 "不出"连续两轮规则

当 Player A 出牌后，Player B 不出，Player C 也不出：
- `lastPlay` 清空（新回合）
- Player A 重新自由出牌

## 6. AI 策略

### 6.1 决策流程

```
轮到 AI 出牌：
  1. 如果是新回合（lastPlay 为空）：
     → 优先出最小的单牌或小对子（消耗弱牌）
     → 手牌少时（≤2张）直接出完
  
  2. 如果是响应出牌（需要管上一手）：
     → 查找所有能管住 lastPlay 的牌型组合
     → 选择其中最小的（不浪费大牌）
     → 无牌可管则 Pass
  
  3. 炸弹/火箭使用策略：
     → 默认保留，在以下情况使用：
       - 对方仅剩 1-2 张且即将获胜
       - 自己手牌 ≤4 张且能一次出完
       - 对手是地主且自己即将获胜
```

### 6.2 特殊判断

- **阻止出牌**：当对手仅剩 1 张牌时，AI 尽量出他能出的最大牌，而非最小
- **农民配合**：两个 AI 农民之间有基础配合意识（不对同阵营出炸弹）

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         斗地主               │
│      经典三人扑克            │
│                             │
│   ┌─────────────────────┐   │
│   │     开始新局         │   │
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │     继续游戏         │   │  (有存档时显示)
│   └─────────────────────┘   │
│   ┌─────────────────────┐   │
│   │     游戏规则         │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

### 7.2 游戏页

```
┌─────────────────────────────┐
│         对手1                │
│    ♠♣♥♦ (牌背×n)            │
│         AI-1            剩余 │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │    上次出牌展示区      │  │
│  │    (居中显示)          │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│ 对手2                 地主标记│
│                             │
│    ♠♣♥♦ (手牌可点选)        │
│ ┌──┬──┬──┬──┬──┬──┬──┬──┐  │
│ │出│  │  │  │  │  │  │不│  │
│ │牌│  │提│  │…│  │  │  │出│  │
│ └──┴──┴──┴──┴──┴──┴──┴──┘  │
└─────────────────────────────┘
```

## 8. 卡片渲染

不依赖外部图片资源，全部程序化绘制：

| 元素 | 渲染方式 |
|------|----------|
| 牌面 | 圆角矩形背景（白）+ 左上角点数 + 中心花色符号 |
| 花色色值 | ♥♦ 红色 `#E53E3E`，♠♣ 黑色 `#1A1A2E` |
| 牌背 | 深蓝色底 `#1A225D` + 浅色网格纹理 |
| 大小王 | 红色小王（Joker Red）/ 黑色大王（Joker Black）+ 星标符号 |
| 选中态 | 牌面上移 + 金色边框 `#FFA534` |

## 9. GameLandlordModule 接入

```dart
class GameLandlordModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → LandlordStartPage
  // buildRuleEntry → LandlordStartPage(showRulesOnEntry: true)
  // createSessionSerializer → GameSession ↔ JSON
  // createResultAdapter → GameResult → 摘要
}
```

注册表 `game_registry.g.dart` 中将：
```dart
// 原来：
const StaticGameModule(manifest: GameManifest(id: 'landlord', ...))

// 改为：
const GameLandlordModule()
```

## 10. 验收标准

- [ ] 启动游戏 → 正常发牌 17+17+17+3
- [ ] 地主获得底牌后手牌 20 张
- [ ] 所有 10 种牌型正确识别和比较
- [ ] AI 自动出牌，不出时不卡死
- [ ] 连续两人不出 → 回合重置
- [ ] 某方出完 → 显示胜负结果
- [ ] "不出"按钮和"提示"按钮功能正常
- [ ] 存档恢复正常
- [ ] `dart run tool/generate_game_registry.dart` 成功更新注册表

## 11. 相关文档

- [游戏模块规范](../game_module_spec.md)
- [FunBox 产品技术方案](../funbox_product_tech_plan.md)
- [大厅设计文档](../lobby_design.md)
