# 闲趣盒子小游戏本地 Package 化迁移实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `闲趣盒子` 从“小游戏源码位于主工程/镜像到 generated”迁移为“每个小游戏一个本地 Flutter package”，同时保持大厅自动注册与最少手工接入。

**Architecture:** 新增一个公共接口包 `funbox_game_api`，让主工程和小游戏包都依赖它；将所有小游戏迁移到 `packages/` 下，主工程只保留平台层；升级生成器，自动扫描 package、维护主工程 path dependencies、生成注册表，并移除 `generated/game_modules` 源码镜像。

**Tech Stack:** Flutter, Dart, 本地 path package, 自定义代码生成脚本, flutter_test, dart analyze

---

## 文件结构与职责

### 新建目录

- `packages/funbox_game_api/`
- `packages/game_2048/`
- `packages/game_landlord/`
- `packages/game_gomoku/`
- `packages/game_minesweeper/`
- `packages/game_snake/`
- `packages/game_solitaire/`
- `packages/game_airplane/`
- `packages/game_tetris/`

### 主要修改文件

- 修改: `code/tool/generate_game_registry.dart`
- 修改: `code/pubspec.yaml`
- 修改: `code/test/game_registry_generator_test.dart`
- 修改: `code/lib/src/generated/game_registry.g.dart`（由脚本生成）
- 修改: `code/lib/src/platform/games/game_catalog.dart`
- 修改: `code/lib/src/models/home_models.dart`
- 修改: `code/lib/src/pages/home_page.dart`
- 修改: `code/lib/src/pages/category_page.dart`
- 修改: `code/lib/src/pages/favorites_page.dart`
- 修改: `docs/game-module-spec.md`
- 修改: `docs/funbox-product-tech-plan.md`

### 计划删除目录

- 删除: `code/games/`
- 删除: `code/lib/src/generated/game_modules/`

---

### Task 1: 创建公共接口包 `funbox_game_api`

**Files:**
- Create: `packages/funbox_game_api/pubspec.yaml`
- Create: `packages/funbox_game_api/lib/funbox_game_api.dart`
- Create: `packages/funbox_game_api/lib/src/game_manifest.dart`
- Create: `packages/funbox_game_api/lib/src/game_module.dart`
- Modify: `code/pubspec.yaml`

- [ ] **Step 1: 写接口包结构测试清单**

确认要迁出的类型只有：

```text
GameManifest
GameModule
GameSessionAdapter
GameResultAdapter
```

预期：
- 不把主工程 UI、主题、路由带进公共包
- 公共包只依赖 `flutter/widgets.dart`

- [ ] **Step 2: 创建 `packages/funbox_game_api/pubspec.yaml`**

写入：

```yaml
name: funbox_game_api
description: Shared game integration contracts for FunBox.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
```

- [ ] **Step 3: 创建 `game_manifest.dart`**

写入：

```dart
class GameManifest {
  const GameManifest({
    required this.id,
    required this.title,
    required this.category,
    required this.packageName,
    required this.iconAsset,
    required this.coverAsset,
    required this.supportsResume,
    required this.supportedModes,
    required this.sortOrder,
    required this.enabled,
  });

  final String id;
  final String title;
  final String category;
  final String packageName;
  final String iconAsset;
  final String coverAsset;
  final bool supportsResume;
  final List<String> supportedModes;
  final int sortOrder;
  final bool enabled;
}
```

- [ ] **Step 4: 创建 `game_module.dart`**

写入：

```dart
import 'package:flutter/widgets.dart';

import 'game_manifest.dart';

abstract class GameModule {
  const GameModule();

  GameManifest get manifest;

  Widget buildStartPage(BuildContext context);

  Widget buildRuleEntry(BuildContext context);

  GameSessionAdapter createSessionSerializer();

  GameResultAdapter createResultAdapter();
}

abstract class GameSessionAdapter {
  const GameSessionAdapter();

  Map<String, Object?> encode(Object? session);

  Object? decode(Map<String, Object?> payload);
}

abstract class GameResultAdapter {
  const GameResultAdapter();

  Map<String, Object?> toSummary(Object? result);
}
```

- [ ] **Step 5: 创建包导出入口 `funbox_game_api.dart`**

写入：

```dart
export 'src/game_manifest.dart';
export 'src/game_module.dart';
```

- [ ] **Step 6: 主工程增加对接口包的 path 依赖**

在 `code/pubspec.yaml` 的 `dependencies` 下增加：

```yaml
  funbox_game_api:
    path: ../packages/funbox_game_api
```

- [ ] **Step 7: 运行分析验证公共包可被主工程识别**

Run:

```bash
cd code
dart analyze
```

Expected:
- 没有 `funbox_game_api` 导入错误

- [ ] **Step 8: Commit**

```bash
git add packages/funbox_game_api code/pubspec.yaml
git commit -m "feat: add shared game api package"
```

---

### Task 2: 主工程改为依赖 `funbox_game_api`

**Files:**
- Modify: `code/lib/src/platform/games/game_manifest.dart`
- Modify: `code/lib/src/platform/games/game_module.dart`
- Modify: `code/lib/src/platform/games/static_game_module.dart`
- Modify: `code/lib/src/platform/games/placeholder_game_page.dart`
- Modify: `code/lib/src/generated/game_registry.g.dart`
- Test: `code/test/home_shell_test.dart`

- [ ] **Step 1: 写一个失败测试，确保注册表和平台层能从公共包读取类型**

在 `code/test/home_shell_test.dart` 维持现有大厅渲染用例，并预期：

```text
大厅仍能构建
generatedGameModules 仍能被 home shell 消费
```

- [ ] **Step 2: 运行测试，确认迁移前基线**

Run:

```bash
cd code
flutter test --no-pub test/home_shell_test.dart
```

Expected:
- 现有测试通过，作为迁移基线

- [ ] **Step 3: 把主工程中的接口文件改为转发或直接删除引用点**

建议先把 `code/lib/src/platform/games/game_manifest.dart` 改成：

```dart
export 'package:funbox_game_api/funbox_game_api.dart' show GameManifest;
```

把 `code/lib/src/platform/games/game_module.dart` 改成：

```dart
export 'package:funbox_game_api/funbox_game_api.dart'
    show GameModule, GameSessionAdapter, GameResultAdapter;
```

- [ ] **Step 4: 调整 `static_game_module.dart` 导入**

改为：

```dart
import 'package:funbox_game_api/funbox_game_api.dart';
import 'package:flutter/widgets.dart';
```

并保持实现不变。

- [ ] **Step 5: 运行大厅测试验证迁移后仍可渲染**

Run:

```bash
cd code
flutter test --no-pub test/home_shell_test.dart
```

Expected:
- 测试通过

- [ ] **Step 6: Commit**

```bash
git add code/lib/src/platform/games code/test/home_shell_test.dart
git commit -m "refactor: move platform game contracts to api package"
```

---

### Task 3: 将 2048 迁移为本地 package

**Files:**
- Create: `packages/game_2048/pubspec.yaml`
- Create: `packages/game_2048/game_manifest.yaml`
- Create: `packages/game_2048/lib/game_module.dart`
- Create: `packages/game_2048/lib/src/...`
- Create: `packages/game_2048/assets/images/...`
- Modify: `code/test/game_registry_generator_test.dart`

- [ ] **Step 1: 写失败测试，要求生成器能识别 package 目录**

在 `code/test/game_registry_generator_test.dart` 增加断言：

```text
扫描 packages/game_2048
生成 package:game_2048/game_module.dart import
不再生成 generated/game_modules/2048
```

- [ ] **Step 2: 运行测试，确认新断言失败**

Run:

```bash
cd code
flutter test --no-pub test/game_registry_generator_test.dart
```

Expected:
- FAIL，原因是当前生成器仍按旧目录结构工作

- [ ] **Step 3: 创建 `packages/game_2048/pubspec.yaml`**

写入：

```yaml
name: game_2048
description: 2048 game package for FunBox.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  funbox_game_api:
    path: ../funbox_game_api
```

- [ ] **Step 4: 创建 `packages/game_2048/game_manifest.yaml`**

写入：

```yaml
id: 2048
title: 2048
category: puzzle
packageName: game_2048
iconAsset: assets/images/icon.png
coverAsset: assets/images/icon.png
supportsResume: true
supportedModes:
  - classic
sortOrder: 10
enabled: true
```

- [ ] **Step 5: 把现有 2048 代码迁到 package**

迁移这些目录：

```text
code/games/2048/lib/game_module.dart -> packages/game_2048/lib/game_module.dart
code/games/2048/lib/game_2048_module.dart -> packages/game_2048/lib/src/game_2048_module.dart
code/games/2048/lib/logic -> packages/game_2048/lib/src/logic
code/games/2048/lib/models -> packages/game_2048/lib/src/models
code/games/2048/lib/pages -> packages/game_2048/lib/src/pages
code/games/2048/assets -> packages/game_2048/assets
```

- [ ] **Step 6: 调整 2048 package 内导入**

目标：

```dart
import 'package:funbox_game_api/funbox_game_api.dart';
import 'package:flutter/material.dart';
```

并避免导入主工程页面。

- [ ] **Step 7: 让入口暴露 `createGameModule`**

`packages/game_2048/lib/game_module.dart` 写成：

```dart
import 'package:funbox_game_api/funbox_game_api.dart';

import 'src/game_2048_module.dart';

GameModule createGameModule(GameManifest manifest) {
  return Game2048Module(manifest: manifest);
}
```

- [ ] **Step 8: 运行格式化与单测**

Run:

```bash
cd code
dart format ../packages/game_2048
flutter test --no-pub test/game_registry_generator_test.dart
```

Expected:
- 2048 package 可被生成器识别

- [ ] **Step 9: Commit**

```bash
git add packages/game_2048 code/test/game_registry_generator_test.dart
git commit -m "refactor: migrate 2048 to local package"
```

---

### Task 4: 将 斗地主 迁移为本地 package

**Files:**
- Create: `packages/game_landlord/pubspec.yaml`
- Create: `packages/game_landlord/game_manifest.yaml`
- Create: `packages/game_landlord/lib/game_module.dart`
- Create: `packages/game_landlord/lib/src/...`
- Create: `packages/game_landlord/assets/images/...`
- Test: `code/test/home_shell_test.dart`

- [ ] **Step 1: 复制 2048 的 package 结构，建立 斗地主 package 骨架**

创建：

```text
packages/game_landlord/pubspec.yaml
packages/game_landlord/game_manifest.yaml
packages/game_landlord/lib/game_module.dart
packages/game_landlord/lib/src/
packages/game_landlord/assets/
```

- [ ] **Step 2: 写 manifest**

```yaml
id: landlord
title: 斗地主
category: board
packageName: game_landlord
iconAsset: assets/images/icon.png
coverAsset: assets/images/icon.png
supportsResume: true
supportedModes:
  - ai
sortOrder: 30
enabled: true
```

- [ ] **Step 3: 迁移斗地主源码与资源**

迁移：

```text
code/games/landlord/lib/* -> packages/game_landlord/lib/src 或 lib/
code/games/landlord/assets -> packages/game_landlord/assets
```

- [ ] **Step 4: 调整 package 导入与入口**

入口保持：

```dart
GameModule createGameModule(GameManifest manifest) {
  return GameLandlordModule(manifest: manifest);
}
```

- [ ] **Step 5: 运行大厅测试与分析**

Run:

```bash
cd code
flutter test --no-pub test/home_shell_test.dart
dart analyze
```

Expected:
- 大厅仍能显示 `2048` 和 `斗地主`
- 无 package 导入错误

- [ ] **Step 6: Commit**

```bash
git add packages/game_landlord code/test/home_shell_test.dart
git commit -m "refactor: migrate landlord to local package"
```

---

### Task 5: 升级生成器为 package 扫描模式

**Files:**
- Modify: `code/tool/generate_game_registry.dart`
- Modify: `code/test/game_registry_generator_test.dart`
- Modify: `code/pubspec.yaml`

- [ ] **Step 1: 写失败测试，要求生成器扫描 `packages/` 并更新依赖**

在 `code/test/game_registry_generator_test.dart` 增加断言：

```text
能够识别 package 下 manifest
会更新主工程 dependencies 生成区块
会生成 package import
不会再生成源码镜像目录
```

- [ ] **Step 2: 运行测试，确认失败**

Run:

```bash
cd code
flutter test --no-pub test/game_registry_generator_test.dart
```

Expected:
- FAIL，原因是旧生成器还在扫描 `games/`

- [ ] **Step 3: 修改扫描根目录逻辑**

生成器要支持：

```dart
--packages-root packages
```

并识别：

```text
pubspec.yaml
game_manifest.yaml
lib/game_module.dart
```

- [ ] **Step 4: 加入 packageName 校验**

实现规则：

```text
manifest.packageName == package pubspec name
```

不一致则抛出 `FormatException`。

- [ ] **Step 5: 增加主工程 dependencies 生成区块**

在 `code/pubspec.yaml` 维护：

```yaml
# BEGIN GENERATED GAME PACKAGE DEPS
# END GENERATED GAME PACKAGE DEPS
```

生成器自动替换这一区块。

- [ ] **Step 6: 改注册表 import 生成方式**

目标生成：

```dart
import 'package:game_2048/game_module.dart' as game_2048;
import 'package:game_landlord/game_module.dart' as game_landlord;
```

- [ ] **Step 7: 删除源码镜像生成逻辑**

删除：

```text
_syncGeneratedModules
_copyDirectory
generated/game_modules 相关逻辑
```

- [ ] **Step 8: 运行测试验证生成器绿灯**

Run:

```bash
cd code
flutter test --no-pub test/game_registry_generator_test.dart
```

Expected:
- 全部通过

- [ ] **Step 9: Commit**

```bash
git add code/tool/generate_game_registry.dart code/test/game_registry_generator_test.dart code/pubspec.yaml
git commit -m "feat: generate package dependencies and registry"
```

---

### Task 6: 大厅改为读取 package 资源

**Files:**
- Modify: `code/lib/src/models/home_models.dart`
- Modify: `code/lib/src/platform/games/game_catalog.dart`
- Modify: `code/lib/src/pages/home_page.dart`
- Modify: `code/lib/src/pages/category_page.dart`
- Modify: `code/lib/src/pages/favorites_page.dart`
- Test: `code/test/home_shell_test.dart`

- [ ] **Step 1: 写失败测试，要求大厅卡片支持 package 资源**

在 `home_shell_test.dart` 中保持现有页面渲染检查，并新增断言：

```text
GameCardData 保留 packageName
卡片组件从 manifest 读取 package 信息
```

- [ ] **Step 2: 运行测试确认失败**

Run:

```bash
cd code
flutter test --no-pub test/home_shell_test.dart
```

Expected:
- FAIL，原因是当前模型不含 `packageName`

- [ ] **Step 3: 给 `GameCardData` 增加 `packageName`**

例如：

```dart
class GameCardData {
  const GameCardData({
    required this.gameId,
    required this.title,
    required this.category,
    required this.coverAsset,
    required this.iconAsset,
    required this.packageName,
    required this.supportsResume,
  });

  final String packageName;
}
```

- [ ] **Step 4: 修改 `game_catalog.dart` 投影逻辑**

确保从 `GameManifest` 投影时带出：

```dart
packageName: module.manifest.packageName,
```

- [ ] **Step 5: 修改图片加载方式**

所有游戏图片加载改为：

```dart
Image.asset(
  game.coverAsset,
  package: game.packageName,
)
```

以及 icon 的对应用法。

- [ ] **Step 6: 运行大厅测试**

Run:

```bash
cd code
flutter test --no-pub test/home_shell_test.dart
```

Expected:
- 测试通过

- [ ] **Step 7: Commit**

```bash
git add code/lib/src/models/home_models.dart code/lib/src/platform/games/game_catalog.dart code/lib/src/pages
git commit -m "feat: load game assets from local packages"
```

---

### Task 7: 迁移剩余小游戏为 package 占位模块

**Files:**
- Create: `packages/game_gomoku/...`
- Create: `packages/game_minesweeper/...`
- Create: `packages/game_snake/...`
- Create: `packages/game_solitaire/...`
- Create: `packages/game_airplane/...`
- Create: `packages/game_tetris/...`
- Modify: `code/pubspec.yaml`
- Modify: `code/lib/src/generated/game_registry.g.dart`

- [ ] **Step 1: 为每个剩余游戏创建最小 package 骨架**

每个目录至少包含：

```text
pubspec.yaml
game_manifest.yaml
lib/game_module.dart
assets/images/icon.png
```

- [ ] **Step 2: 占位模块统一使用 `StaticGameModule` 接口思路**

如果某游戏还没有真实玩法实现，则 package 内 `createGameModule` 可以返回一个占位实现，但该占位实现必须位于 package 内，而不是主工程手写特判。

- [ ] **Step 3: 跑生成器刷新依赖与注册表**

Run:

```bash
cd code
dart run tool/generate_game_registry.dart --packages-root ../packages --registry-out lib/src/generated/game_registry.g.dart --pubspec pubspec.yaml
```

Expected:
- 所有小游戏 package 都出现在生成区块和注册表中

- [ ] **Step 4: 运行全量测试**

Run:

```bash
cd code
flutter test --no-pub
```

Expected:
- 现有测试全部通过

- [ ] **Step 5: Commit**

```bash
git add packages code/lib/src/generated/game_registry.g.dart code/pubspec.yaml
git commit -m "refactor: migrate remaining games to local packages"
```

---

### Task 8: 删除旧结构并清理生成遗留

**Files:**
- Delete: `code/games/`
- Delete: `code/lib/src/generated/game_modules/`
- Modify: `code/tool/generate_game_registry.dart`
- Test: `code/test/game_registry_generator_test.dart`

- [ ] **Step 1: 写失败测试，要求旧目录不存在时系统仍可工作**

在生成器测试中确认：

```text
没有 code/games 也能完成扫描与注册
没有 generated/game_modules 也能通过编译
```

- [ ] **Step 2: 删除旧目录**

删除：

```text
code/games/
code/lib/src/generated/game_modules/
```

- [ ] **Step 3: 清理生成器和文档中的旧路径引用**

确保工程中不再出现：

```text
code/games/
generated/game_modules
```

- [ ] **Step 4: 运行全量验证**

Run:

```bash
cd code
flutter test --no-pub
dart analyze
```

Expected:
- 测试通过
- 无错误和 warning

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: remove legacy game module structure"
```

---

### Task 9: 更新规范与总方案文档

**Files:**
- Modify: `docs/game-module-spec.md`
- Modify: `docs/funbox-product-tech-plan.md`
- Modify: `docs/game-package-architecture.md`

- [ ] **Step 1: 更新小游戏模块规范文档路径**

把所有：

```text
code/games/<game_id>/
```

改为：

```text
packages/game_<id>/
```

- [ ] **Step 2: 更新接口来源**

在文档中明确：

```text
公共接口来源于 funbox_game_api
```

- [ ] **Step 3: 更新生成器职责描述**

把“复制源码到 generated/game_modules”改为：

```text
扫描 packages
更新主工程 path dependencies
生成 registry
```

- [ ] **Step 4: 文档自检**

检查是否还存在这些旧表述：

```text
generated/game_modules
code/games/<id>/
复制小游戏源码
```

- [ ] **Step 5: Commit**

```bash
git add docs/game-module-spec.md docs/funbox-product-tech-plan.md docs/game-package-architecture.md
git commit -m "docs: update architecture docs for local package games"
```

---

### Task 10: 最终回归验证

**Files:**
- Test: `code/test/game_registry_generator_test.dart`
- Test: `code/test/home_shell_test.dart`

- [ ] **Step 1: 运行生成器**

Run:

```bash
cd code
dart run tool/generate_game_registry.dart --packages-root ../packages --registry-out lib/src/generated/game_registry.g.dart --pubspec pubspec.yaml
```

Expected:
- 成功生成注册表和依赖区块

- [ ] **Step 2: 运行全量测试**

Run:

```bash
cd code
flutter test --no-pub
```

Expected:
- 全部通过

- [ ] **Step 3: 运行静态分析**

Run:

```bash
cd code
dart analyze
```

Expected:
- 无 error
- 无 warning

- [ ] **Step 4: 手工验收检查**

检查以下场景：

```text
首页能展示 2048 与 斗地主
分类页能按 category 渲染
收藏页能通过 gameId 找回模块
游戏封面图和图标能正常加载
继续游戏入口仍能进入对应小游戏
```

- [ ] **Step 5: Commit**

```bash
git add code/lib/src/generated/game_registry.g.dart code/pubspec.yaml
git commit -m "test: verify local package game architecture"
```

---

## 自检结论

### 规格覆盖

本计划覆盖了以下核心目标：

- 新建 `funbox_game_api`
- 全部小游戏迁移到 `packages/`
- 生成器切到 package 扫描模式
- 主工程自动维护 path dependencies
- 大厅改为读取 package 资源
- 删除旧目录与源码镜像
- 更新文档规范

### 无占位项检查

本计划没有使用以下无执行意义表述：

- `TODO`
- `后续补充`
- `按需处理`
- `适当支持`

### 类型一致性

计划中的统一约束如下：

- 小游戏入口：`createGameModule(GameManifest manifest)`
- 公共接口包：`funbox_game_api`
- 主工程注册表：`generatedGameModules`
- manifest 新增字段：`packageName`

这些命名在各任务中保持一致。

## 执行建议

推荐执行顺序：

1. 先做 `Task 1` 和 `Task 2`
2. 再做 `Task 3`、`Task 4` 验证真实样板游戏
3. 再做 `Task 5`、`Task 6` 打通自动注册与资源读取
4. 最后做 `Task 7`、`Task 8`、`Task 9`、`Task 10`

这样可以先用真实游戏验证架构，再做全量迁移，风险最低。
