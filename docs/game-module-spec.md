# 闲趣盒子小游戏模块规范文档

## 1. 文档目的

本文档用于约束 `闲趣盒子` 中每个小游戏的接入方式，确保小游戏具备以下特性：
- 可独立维护代码与资源
- 可通过统一接口接入平台
- 新增游戏时不需要修改大厅、分类、收藏等主框架页面代码
- 通过构建脚本自动生成注册表和资产声明

本文档中的 `闲趣盒子` 指产品名称，`FunBox` 指代码项目名。

## 2. 设计目标

小游戏模块规范的核心目标是让每个小游戏都成为一个“自带代码、自带资源、自带元数据”的独立单元。主框架不维护游戏名单，也不维护某个游戏的私有资源路径，而是只消费每个模块公开出来的统一描述。

这份规范优先保证以下能力：
- 零大厅代码改动接入新游戏
- 统一资源边界
- 统一 manifest 结构
- 统一平台注册方式
- 统一存档与结果适配接口

## 3. 目录结构规范

### 3.1 模块根目录
每个小游戏必须放在：

`code/games/<game_id>/`

其中 `<game_id>` 是小游戏的稳定唯一标识，也是后续注册、收藏、最近游玩、存档关联使用的主键。

### 3.2 最小目录结构
每个小游戏最少包含以下内容：

```text
code/games/<game_id>/
├─ assets/
│  └─ images/
├─ game_manifest.yaml
└─ lib/                # 推荐，当前允许后续逐步补齐
```

推荐扩展结构：

```text
code/games/<game_id>/
├─ assets/
│  ├─ images/
│  ├─ audio/
│  └─ data/
├─ lib/
│  ├─ pages/
│  ├─ logic/
│  ├─ models/
│  └─ widgets/
├─ test/
├─ rules.md
└─ game_manifest.yaml
```

### 3.3 当前已存在的模块目录
当前仓库内已存在以下游戏目录：
- `code/games/2048/`
- `code/games/airplane/`
- `code/games/gomoku/`
- `code/games/landlord/`
- `code/games/minesweeper/`
- `code/games/snake/`
- `code/games/solitaire/`
- `code/games/tetris/`

这些目录就是后续小游戏模块化的正式根目录。

## 4. 资源归属规范

### 4.1 基本原则
- 游戏私有资源必须放在该游戏自己的目录中。
- 主框架不存放某个游戏专属封面图、图标、局内图片、规则插图、音频。
- 平台页面只能通过模块元数据读取游戏资源，不能手写资源路径。

### 4.2 属于单游戏资源的内容
以下内容必须放在单游戏目录内：
- icon
- cover
- 局内贴图
- 卡面
- 棋子
- 背景图
- 游戏音效
- 规则插图

### 4.3 属于平台公共资源的内容
以下内容由主框架统一维护：
- App Logo
- 底部导航图标
- 平台空状态插图
- 通用按钮背景
- 平台统一背景装饰

### 4.4 资源目录要求
当前生成脚本会扫描 `assets/` 的第一层子目录并写入 `pubspec.yaml`，因此建议所有图片资源统一放在：

`code/games/<game_id>/assets/images/`

如果新增 `audio/`、`data/` 等目录，也必须放在 `assets/` 下，才能被生成脚本纳入资产声明。

## 5. Manifest 规范

### 5.1 文件位置
每个小游戏必须包含：

`code/games/<game_id>/game_manifest.yaml`

### 5.2 必填字段
当前 manifest 必须包含以下字段：

```yaml
id: gomoku
title: 五子棋
category: board
iconAsset: games/gomoku/assets/images/icon.png
coverAsset: games/gomoku/assets/images/icon.png
supportsResume: true
supportedModes:
  - ai
  - local
sortOrder: 20
enabled: true
```

字段含义如下：
- `id`：小游戏唯一标识，必须与目录名保持一致
- `title`：大厅展示名
- `category`：分类 id
- `iconAsset`：大厅、收藏、最近游玩使用的图标资源路径
- `coverAsset`：推荐位、开始页等可使用的主视觉资源路径
- `supportsResume`：是否支持继续游戏
- `supportedModes`：支持的模式列表
- `sortOrder`：排序权重，数字越小越靠前
- `enabled`：是否启用该游戏

### 5.3 字段约束
- `id` 必须稳定，不允许上线后随意改名
- `iconAsset` 和 `coverAsset` 必须指向真实存在的资源文件
- `category` 必须使用平台可识别的分类值
- `sortOrder` 必须为整数
- `enabled` 必须为布尔值
- `supportedModes` 必须为列表

### 5.4 当前推荐分类值
当前平台已使用的分类值包括：
- `board`
- `puzzle`
- `casual`
- `arcade`

如果要新增分类，必须先同步更新平台分类映射逻辑，否则大厅不会正确展示标签文本。

## 6. 平台接口规范

### 6.1 GameManifest
当前平台的 manifest 结构定义在：

[game_manifest.dart](/D:/Projects/flutter/FunBox/code/lib/src/platform/games/game_manifest.dart)

平台会把每个 `game_manifest.yaml` 生成成对应的 `GameManifest` 实例。大厅、分类、收藏、最近游玩都只消费这个结构。

### 6.2 GameModule
小游戏接入平台时，必须符合 `GameModule` 约束，接口定义在：

[game_module.dart](/D:/Projects/flutter/FunBox/code/lib/src/platform/games/game_module.dart)

当前平台要求 `GameModule` 提供：
- `manifest`
- `buildStartPage`
- `buildRuleEntry`
- `createSessionSerializer`
- `createResultAdapter`

### 6.3 Session 与 Result 适配
为保持可拔插，平台不理解每个游戏内部存档结构。小游戏必须自己提供：
- `GameSessionAdapter`
- `GameResultAdapter`

平台只关心：
- 如何调用
- 如何按 `gameId` 找到对应模块
- 如何在需要时把 payload 交回游戏模块解码

## 7. 自动生成机制

### 7.1 生成脚本
当前自动发现脚本位于：

[generate_game_registry.dart](/D:/Projects/flutter/FunBox/code/tool/generate_game_registry.dart)

### 7.2 脚本职责
脚本负责：
- 扫描 `code/games/` 下所有一级目录
- 读取每个目录中的 `game_manifest.yaml`
- 校验 manifest 必填字段
- 校验 `iconAsset` / `coverAsset` 指向的资源是否存在
- 收集 `assets/` 第一层资源目录
- 生成平台注册表
- 更新 `pubspec.yaml` 中的游戏资产声明片段

### 7.3 生成结果
脚本会生成或更新：
- [game_registry.g.dart](/D:/Projects/flutter/FunBox/code/lib/src/generated/game_registry.g.dart)
- [pubspec.yaml](/D:/Projects/flutter/FunBox/code/pubspec.yaml) 中 `# BEGIN GENERATED GAME ASSETS` 到 `# END GENERATED GAME ASSETS` 之间的内容

### 7.4 生成命令
在 `code/` 目录执行：

```bash
dart run tool/generate_game_registry.dart --games-root games --registry-out lib/src/generated/game_registry.g.dart --pubspec pubspec.yaml
```

如果本地 `dart run` 环境不稳定，也可以直接使用 Dart 可执行文件调用同一脚本。

## 8. 新增小游戏标准流程

新增一个小游戏时，必须按以下步骤操作：

1. 在 `code/games/` 下新建目录，例如 `code/games/sudoku/`
2. 添加 `assets/images/` 以及至少一个 `icon.png`
3. 新建 `game_manifest.yaml`
4. 在该模块目录内补齐 `lib/`、规则页、开始页、逻辑代码
5. 为该游戏实现符合 `GameModule` 要求的接入类
6. 运行生成脚本
7. 重新执行分析与测试

正确完成后，大厅、分类、收藏、推荐区不需要手改页面代码即可出现该游戏。

## 9. 禁止事项

以下做法不允许出现：
- 在大厅页面里手写某个新游戏的资源路径
- 在分类页里增加 `if (id == "xxx")` 之类的特判
- 把单游戏图片复制到主框架 `assets/` 中维护第二份副本
- 只加资源目录，不写 manifest
- 只写 manifest，不校验资源真实存在
- 修改 `game_registry.g.dart` 作为手工接入方式
- 手工改 `pubspec.yaml` 的生成片段作为长期方案

`game_registry.g.dart` 和生成区段属于生成文件，应该由脚本维护，而不是手动编辑。

## 10. 失败场景与处理规则

### 10.1 缺少 manifest
如果目录里没有 `game_manifest.yaml`，生成脚本会跳过该目录，该游戏不会接入平台。

### 10.2 manifest 缺字段
如果 manifest 缺必填字段，生成脚本必须直接失败，不能让应用运行时再崩溃。

### 10.3 资源路径无效
如果 `iconAsset` 或 `coverAsset` 指向不存在的文件，生成脚本必须直接失败。

### 10.4 assets 目录不规范
如果资源没有放到 `assets/` 下，生成脚本不会把它写进 `pubspec.yaml`，最终运行时会加载失败。

### 10.5 非稳定 id
如果后续改动了 `id`，收藏、最近游玩、存档恢复都可能失效，因此 `id` 一旦对外使用，就必须视为稳定主键。

## 11. 与大厅和总方案文档的关系

这份文档是以下两份文档的下位实现规范：
- [funbox-product-tech-plan.md](/D:/Projects/flutter/FunBox/docs/funbox-product-tech-plan.md)
- [lobby-design.md](/D:/Projects/flutter/FunBox/docs/lobby-design.md)

关系如下：
- 总方案定义“小游戏应可独立接入平台”
- 大厅文档定义“首页、分类、收藏如何从模块读取资源”
- 本文档定义“小游戏模块本身必须长成什么样，平台才能自动接入”

## 12. 验收标准

当一个新小游戏模块被提交时，至少应满足以下验收条件：
- 目录位于 `code/games/<game_id>/`
- 存在 `game_manifest.yaml`
- `iconAsset` 和 `coverAsset` 对应资源真实存在
- 资源放在该游戏自己的 `assets/` 目录中
- 运行生成脚本后，注册表成功更新
- 大厅、分类、收藏页面无需手改代码即可识别该游戏
- 不需要在主框架中复制该游戏的图片或音频

如果以上条件无法全部满足，则说明该小游戏还不符合可拔插模块规范。
