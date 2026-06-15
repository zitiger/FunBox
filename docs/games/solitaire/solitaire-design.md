# 接龙平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的空当接龙（Klondike Solitaire）小游戏模块。
- **模式**：单人
- **用牌**：标准 52 张扑克牌（不含大小王）
- **目标**：将所有牌按花色从 A 到 K 排列到收集区

## 2. 文件结构

```
code/lib/src/games/solitaire/
├── game_solitaire_module.dart        # GameModule 实现
├── models/
│   ├── card.dart                    # 扑克牌模型
│   └── solitaire_session.dart       # 游戏会话
├── logic/
│   ├── solitaire_engine.dart        # 发牌、移动、完成判定
│   └── solitaire_rules.dart         # 移动规则验证
├── pages/
│   ├── solitaire_start_page.dart    # 开始页
│   └── solitaire_play_page.dart     # 对局页
└── widgets/
    ├── card_widget.dart             # 单张牌组件
    ├── tableau_pile.dart            # 牌列组件
    ├── foundation_pile.dart         # 收集区组件
    └── stock_pile.dart              # 牌堆组件
```

## 3. 数据结构

### 3.1 区域划分

| 区域 | 说明 |
|------|------|
| Stock（牌堆） | 剩余未翻的牌，可逐张翻出 |
| Waste（废牌堆） | 从牌堆翻出的牌 |
| Tableau（牌列） | 7列牌，每列顶部1张翻开 |
| Foundation（收集区） | 4个空位，从A开始按花色升序排列 |

### 3.2 游戏会话 (SolitaireSession)

```dart
class SolitaireSession {
  List<Card> stock;              // 牌堆（剩余未翻）
  List<Card> waste;              // 废牌堆
  List<List<Card>> tableau;      // 7列牌列
  List<List<Card>> foundations;  // 4个收集区
  int score;                     // 当前分数
  bool isGameOver;               // 是否结束
  bool isWin;                    // 是否获胜
  int moveCount;                 // 移动次数
  int startTimeMs;               // 开始时间
  int elapsedMs;                 // 已用时间
}
```

## 4. 游戏流程

```
开始
  ├─ 洗牌 52 张
  ├─ 牌列发牌：第1列1张，第2列2张，…，第7列7张（每列仅顶部1张翻开）
  ├─ 剩余牌放入牌堆
  └─ 进入操作循环：
       ├─ 玩家点击牌堆 → 翻1张到废牌堆
       ├─ 玩家拖拽牌 → 按规则验证移动
       ├─ 检查4个收集区是否全部完成
       └─ 收集区完成 → 胜利
```

## 5. 移动规则

| 规则 | 说明 |
|------|------|
| 牌列移动 | 牌列中可将一张或多张牌移动到另一列，目标列顶部牌必须比移动牌的花色不同且点数大1 |
| 牌列排序 | 牌列中翻开牌必须红黑交替、点数递减 |
| 收集区放入 | 必须从 A 开始，同花色递增（A→K） |
| 空列填充 | 空列只能放 K（或以K开头的序列） |
| 废牌堆移动 | 废牌堆顶牌可移动到牌列或收集区 |
| 牌堆翻牌 | 每次翻1张到废牌堆，牌堆耗尽可循环 |

## 6. 计分规则

| 操作 | 得分 |
|------|------|
| 牌从废牌堆移到牌列 | +5 |
| 牌从牌列移到收集区 | +10 |
| 翻开牌列中扣着的牌 | +5 |
| 牌从收集区移回牌列 | -15 |

## 7. UI 布局

### 7.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│         接龙                 │
│      经典纸牌接龙            │
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
┌──────────────────────────────────────────┐
│  ← 返回   接龙   分数:xxx   重新开始       │
│                                          │
│  [牌堆] [废牌]  [收集区1] [收集区2] ...    │
│                                          │
│  ┌──────┬──────┬──────┬──────┬──────┬──────┬──────┐
│  │ 牌列1 │ 牌列2 │ 牌列3 │ 牌列4 │ 牌列5 │ 牌列6 │ 牌列7 │
│  │      │      │      │      │      │      │      │
│  │      │      │      │      │      │      │      │
│  │      │      │      │      │      │      │      │
│  └──────┴──────┴──────┴──────┴──────┴──────┴──────┘
└──────────────────────────────────────────┘
```

## 8. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 牌面 | 白底 + 角标点数 + 中央花色 |
| 牌背 | 深蓝底 + 网格纹理 |
| 花色色值 | ♥♦ 红色 `#E53E3E`，♠♣ 黑色 `#1A1A2E` |
| 选中态 | 牌面上移 + 金色边框 |
| 收集区 | 空位显示花色轮廓 |

## 9. GameSolitaireModule 接入

```dart
class GameSolitaireModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → SolitaireStartPage
  // buildRuleEntry → SolitaireStartPage(showRulesOnEntry: true)
  // createSessionSerializer → SolitaireSession ↔ JSON
  // createResultAdapter → SolitaireResult → 摘要
}
```

## 10. 验收标准

- [ ] 启动游戏 → 7列牌列正确发牌
- [ ] 牌堆翻牌功能正常
- [ ] 牌列移动规则（红黑交替、递减）正确
- [ ] 收集区从A开始按花色递增
- [ ] 空列只能放K
- [ ] 4个收集区全部完成 → 胜利
- [ ] 拖拽/点击操作流畅
- [ ] 计分规则正确
- [ ] 存档恢复正常

## 11. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)