# 飞机平台接入设计文档

## 1. 概述

在 FunBox 平台中实现经典的飞机大战（Airplane War）射击小游戏模块。
- **模式**：单人纵版射击
- **操作**：触屏拖拽 / 键盘方向键 + 自动射击
- **难度**：随关卡递增，敌机越来越密集

## 2. 文件结构

```
code/lib/src/games/airplane/
├── game_airplane_module.dart      # GameModule 实现
├── models/
│   └── airplane_session.dart      # 游戏会话
├── logic/
│   ├── airplane_engine.dart       # 主循环（移动、碰撞、生成）
│   ├── bullet_manager.dart        # 子弹管理
│   ├── enemy_spawner.dart         # 敌机生成器
│   └── collision_detector.dart    # 碰撞检测
├── pages/
│   ├── airplane_start_page.dart   # 开始页
│   └── airplane_play_page.dart    # 对局页
└── widgets/
    ├── player_plane.dart             # 玩家飞机
    ├── enemy_plane.dart              # 敌机
    ├── bullet_widget.dart            # 子弹
    ├── explosion_effect.dart         # 爆炸特效
    └── hud_widget.dart              # 分数/生命/火力显示
```

## 3. 数据结构

### 3.1 实体类型

| 实体 | 说明 |
|------|------|
| Player | 玩家飞机，可沿X轴移动（底部固定Y轴） |
| Enemy | 敌机，从顶部向下移动 |
| Bullet | 子弹，从底部向上飞行 |
| PowerUp | 道具（火力提升、护盾、炸弹） |

### 3.2 游戏会话 (AirplaneWarSession)

```dart
class AirplaneWarSession {
  double playerX;                 // 玩家X坐标
  double playerY;                 // 玩家Y坐标（固定底部）
  int playerHP;                   // 玩家生命值
  int fireLevel;                  // 火力等级（1-5）
  int score;                      // 当前分数
  int bestScore;                  // 历史最高分
  int level;                      // 当前关卡
  List<Enemy> enemies;            // 当前敌机列表
  List<Bullet> bullets;           // 当前子弹列表
  List<PowerUp> powerUps;         // 当前道具列表
  bool isGameOver;                // 是否结束
  int startTimeMs;                // 开始时间
  int elapsedMs;                  // 已用时间
}
```

### 3.3 敌机类型

| 类型 | 生命 | 速度 | 分数 | 说明 |
|------|------|------|------|------|
| 小敌机 | 1 | 慢 | 100 | 直线向下 |
| 中敌机 | 3 | 中 | 300 | 直线向下 |
| 大敌机 | 10 | 慢 | 1000 | 可发射子弹 |
| Boss | 50+ | 慢 | 5000 | 多种攻击模式 |

## 4. 游戏流程

```
开始
  ├─ 玩家飞机出现在底部中央
  ├─ 初始火力等级1，生命3
  ├─ 自动射击
  └─ 进入主循环（60fps）：
       ├─ 玩家移动（触屏/键盘）
       ├─ 生成敌机（按关卡配置）
       ├─ 子弹移动
       ├─ 碰撞检测：
       │    ├─ 玩家子弹击中敌机 → 敌机扣血/摧毁
       │    ├─ 敌机子弹击中玩家 → 玩家扣血
       │    └─ 敌机碰撞玩家 → 玩家扣血
       ├─ 道具掉落与拾取
       ├─ 检查关卡完成条件
       └─ 玩家生命归零 → 游戏结束
```

## 5. 道具系统

| 道具 | 效果 |
|------|------|
| 火力提升 | 子弹数量/宽度增加（最高5级） |
| 护盾 | 持续5秒无敌 |
| 全屏炸弹 | 清除所有敌机 |
| 生命恢复 | +1 HP |

## 6. UI 布局

### 6.1 开始页

```
┌─────────────────────────────┐
│  ← 返回                     │
│                             │
│        [游戏图标]            │
│       飞机大战               │
│    经典纵版射击              │
│                             │
│   ┌─────────────────────┐   │
│   │     开始游戏         │   │
│   └─────────────────────┘   │
│                             │
│   最高分：xxx                │
│                             │
│        游戏规则              │
└─────────────────────────────┘
```

### 6.2 对局页

```
┌─────────────────────────────┐
│  ← 暂停   关卡:1   分数:xxx  │
│                             │
│                             │
│      游戏画面区域            │
│   (敌机从上方出现)           │
│                             │
│      玩家飞机                │
│                             │
│  HP: ♥♥♥  火力: ★★★        │
│  道具: [护盾] [炸弹]         │
└─────────────────────────────┘
```

## 7. 渲染方案

| 元素 | 渲染方式 |
|------|----------|
| 玩家飞机 | 矢量图形绘制（三角形+翅膀） |
| 敌机 | 不同颜色/形状区分类型 |
| 子弹 | 小矩形/圆形 |
| 爆炸 | 粒子扩散动画 |
| 背景 | 星空/云层滚动视差 |

## 8. GameAirplaneModule 接入

```dart
class GameAirplaneModule extends GameModule {
  // manifest 读自 game_manifest.yaml
  // buildStartPage → AirplaneWarStartPage
  // buildRuleEntry → AirplaneWarStartPage(showRulesOnEntry: true)
  // createSessionSerializer → AirplaneWarSession ↔ JSON
  // createResultAdapter → AirplaneWarResult → 摘要
}
```

## 9. 验收标准

- [ ] 启动游戏 → 玩家飞机出现在底部
- [ ] 触屏拖拽/键盘控制移动流畅
- [ ] 自动射击正常
- [ ] 敌机按关卡配置生成
- [ ] 碰撞检测正确
- [ ] 道具系统正常
- [ ] 关卡递增难度正确
- [ ] 生命归零 → 游戏结束
- [ ] 最高分持久化
- [ ] 存档恢复正常

## 10. 相关文档

- [游戏模块规范](../game-module-spec.md)
- [游戏界面风格设计要求](../game-ui-style-requirements.md)
- [大厅设计文档](../lobby-design.md)