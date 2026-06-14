# 闲趣盒子小游戏本地 Package 化架构方案

## 1. 文档目标

本文档用于定义 `闲趣盒子` 小游戏从当前“主工程内模块 + 生成桥接”形态，升级到“每个小游戏一个本地 Flutter package”的目标架构。

方案目标有三点：

- 保持“新增小游戏尽量不改大厅代码”的接入体验
- 取消把游戏源码复制到 `code/lib/src/generated/game_modules/` 的中间层做法
- 让每个小游戏真正具备“自带代码、自带资源、自带元数据”的独立模块边界

本文档是后续实现计划、迁移执行和规范更新的上位设计依据。

## 2. 背景与问题

当前仓库已经实现了“扫描 manifest + 生成注册表”的自动接入机制，但仍存在一个结构性问题：为了满足 Flutter 主工程编译约束，小游戏源码会被复制到 `code/lib/src/generated/game_modules/<game_id>/`，再由主工程引用。

这种做法虽然能工作，但有以下局限：

- `code/games/<game_id>/` 中的源码不是真正被编译的源码真身
- 生成目录中存在与源码目录重复的代码副本
- 生成目录承担了编译桥和源码镜像双重角色，不利于长期维护
- 当小游戏数量增加时，源码真身与生成副本的关系会提高认知成本

因此，需要把小游戏进一步升级为本地 package，使主工程能够直接依赖包，而不是依赖复制后的源码镜像。

## 3. 总体设计

### 3.1 目标结构

迁移完成后的目录结构建议为：

```text
code/
├─ lib/
│  └─ src/
│     ├─ platform/
│     └─ generated/
│        └─ game_registry.g.dart
├─ tool/
│  └─ generate_game_registry.dart
└─ pubspec.yaml

packages/
├─ funbox_game_api/
├─ game_2048/
├─ game_landlord/
├─ game_gomoku/
├─ game_snake/
└─ ...
```

其中：

- `code/` 是主工程，只负责平台能力
- `packages/funbox_game_api/` 是小游戏公共接口包
- `packages/game_<id>/` 是每个小游戏的本地 Flutter package

### 3.2 职责分层

#### 主工程 `code/`

主工程只保留平台职责：

- 大厅、分类、收藏、设置
- 路由和页面骨架
- 收藏、最近游玩、存档恢复
- 游戏注册表消费
- 生成器脚本

主工程不再存放某个具体小游戏的实现代码。

#### 公共接口包 `funbox_game_api`

该包只负责小游戏接入平台所需的最小公共接口定义，例如：

- `GameManifest`
- `GameModule`
- `GameSessionAdapter`
- `GameResultAdapter`
- 可能的公共设置类型

该包不包含任何具体游戏实现，也不依赖主工程 UI。

#### 小游戏包 `game_<id>`

每个小游戏包只负责自身能力：

- 规则逻辑
- AI
- 局内状态
- 开始页 / 规则页 / 对局页
- 自己的资源文件
- 自己的 manifest

小游戏包不直接依赖大厅或主工程页面。

## 4. 每个小游戏 Package 的标准结构

每个小游戏 package 目录建议为：

```text
packages/game_2048/
├─ lib/
│  ├─ game_module.dart
│  └─ src/
│     ├─ pages/
│     ├─ logic/
│     ├─ models/
│     └─ widgets/
├─ assets/
│  ├─ images/
│  ├─ audio/
│  └─ data/
├─ test/
├─ game_manifest.yaml
└─ pubspec.yaml
```

说明如下：

- `lib/game_module.dart` 是该 package 暴露给主工程的统一入口
- `lib/src/` 存放具体实现
- `assets/` 存放该游戏专属资源
- `game_manifest.yaml` 存放小游戏元数据
- `pubspec.yaml` 定义该 package 自身依赖与资源声明

## 5. 依赖方向设计

### 5.1 推荐依赖关系

推荐依赖关系如下：

```text
主工程 code
  ├─ 依赖 funbox_game_api
  ├─ 依赖 game_2048
  ├─ 依赖 game_landlord
  └─ 依赖其他小游戏包

game_2048 / game_landlord / 其他小游戏包
  └─ 依赖 funbox_game_api
```

该结构有两个关键特征：

- 主工程依赖小游戏包
- 小游戏包只依赖公共 API 包，不依赖主工程

### 5.2 为什么必须引入 `funbox_game_api`

如果不把公共接口抽成单独 package，而是让小游戏包直接依赖主工程中的 `GameModule` 等类型，会形成反向依赖风险：

- 主工程需要依赖小游戏包
- 小游戏包又依赖主工程

这会导致循环依赖或耦合边界不清。

因此，`funbox_game_api` 是 package 化方案中必须存在的稳定中间层。

## 6. Manifest 设计

### 6.1 文件位置

每个小游戏包根目录必须包含：

`packages/game_<id>/game_manifest.yaml`

### 6.2 推荐字段

推荐字段如下：

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

字段说明：

- `id`：游戏稳定唯一标识
- `title`：大厅显示名
- `category`：分类 id
- `packageName`：该小游戏 package 名称，必须与 `pubspec.yaml` 中 `name` 一致
- `iconAsset`：package 内部图标资源路径
- `coverAsset`：package 内部封面资源路径
- `supportsResume`：是否支持继续游戏
- `supportedModes`：支持模式列表
- `sortOrder`：排序权重
- `enabled`：是否启用

### 6.3 资源路径规则

manifest 中的资源路径只写 package 内部路径，不写主工程相对路径。例如：

- 正确：`assets/images/icon.png`
- 错误：`games/2048/assets/images/icon.png`

平台渲染时通过：

- `asset path`
- `packageName`

组合加载资源，而不是把所有资源都当成主工程 asset。

## 7. 公共接口设计

### 7.1 `GameManifest`

公共接口包中的 `GameManifest` 需要至少包含：

- `id`
- `title`
- `category`
- `packageName`
- `iconAsset`
- `coverAsset`
- `supportsResume`
- `supportedModes`
- `sortOrder`
- `enabled`

相比当前结构，新增的关键字段是 `packageName`。

### 7.2 `GameModule`

每个小游戏 package 统一暴露：

- `createGameModule(GameManifest manifest)`

由该入口返回符合公共 API 约束的 `GameModule` 实例。

该设计有两个目的：

- 保持 `game_manifest.yaml` 作为元数据单一来源
- 避免游戏代码中再硬编码一份重复 manifest

### 7.3 存档与结算

小游戏继续通过：

- `GameSessionAdapter`
- `GameResultAdapter`

向平台提供会话保存、恢复和结算摘要能力。

平台仍然只按 `gameId` 定位模块，不理解各小游戏内部 payload 结构。

## 8. 主工程大厅与页面层改造要求

大厅、分类、收藏、最近游玩等页面的核心数据驱动方式不变，但需要适配 package 资源加载方式。

### 8.1 页面层保持不变的部分

- 页面继续消费 `generatedGameModules`
- 收藏继续只存 `gameId`
- 最近游玩继续只存 `gameId`
- 恢复入口继续通过注册表反查模块

### 8.2 页面层需要调整的部分

所有小游戏资源展示都必须支持 package asset 读取。例如：

```dart
Image.asset(
  manifest.coverAsset,
  package: manifest.packageName,
)
```

也就是说，大厅卡片投影结构中必须保留 `packageName` 信息，不能只保留资源路径字符串。

## 9. 生成器职责升级

现有生成器需要从“扫描 manifest + 复制源码 + 生成注册表”升级为“扫描 package + 更新依赖 + 生成注册表”。

### 9.1 扫描范围

扫描根目录改为：

`packages/`

### 9.2 识别一个小游戏 package 的条件

一个目录要被识别为小游戏 package，至少应满足：

- 存在 `pubspec.yaml`
- 存在 `game_manifest.yaml`
- 存在 `lib/game_module.dart`
- package 不是 `funbox_game_api`

### 9.3 生成器校验项

生成器必须在生成阶段完成以下校验：

- `manifest.packageName` 与 package `pubspec.yaml` 中的 `name` 一致
- `id` 合法且稳定
- `iconAsset` / `coverAsset` 对应资源存在于该 package 内
- `lib/game_module.dart` 存在
- package 处于 `enabled: true` 或 `false` 时都可被正确识别

如果校验失败，生成阶段直接失败，不允许把问题留到运行期。

### 9.4 自动更新主工程依赖

生成器需要自动维护主工程 [pubspec.yaml](D:/Projects/flutter/FunBox/code/pubspec.yaml) 的小游戏依赖区块，例如：

```yaml
# BEGIN GENERATED GAME PACKAGE DEPS
game_2048:
  path: ../packages/game_2048
game_landlord:
  path: ../packages/game_landlord
# END GENERATED GAME PACKAGE DEPS
```

这样新增游戏时无需手改主工程依赖列表。

### 9.5 自动生成注册表

生成器生成的 [game_registry.g.dart](D:/Projects/flutter/FunBox/code/lib/src/generated/game_registry.g.dart) 需要直接 import package：

```dart
import 'package:game_2048/game_module.dart' as game_2048;
import 'package:game_landlord/game_module.dart' as game_landlord;
```

并生成统一的 `generatedGameModules`。

### 9.6 不再生成源码镜像

迁移完成后，以下目录不再作为长期方案的一部分：

`code/lib/src/generated/game_modules/`

因为 package 已经是可直接编译引用的正式模块边界，不需要再复制小游戏源码。

## 10. 迁移方案

虽然目标是把全部小游戏切到 `packages/`，但执行顺序需要分阶段进行，避免一次性打散整个工程。

### 阶段 1：建立公共 API 包

新建：

`packages/funbox_game_api/`

迁移以下内容到该包：

- `GameManifest`
- `GameModule`
- `GameSessionAdapter`
- `GameResultAdapter`

主工程和小游戏都改为依赖该包。

### 阶段 2：迁移样板游戏

优先迁移：

- `2048`
- `斗地主`

因为这两款游戏已经有真实代码，能够完整验证：

- 本地 package 依赖是否可用
- 资源读取是否正确
- 注册表生成是否正确
- 大厅接入是否无感知

### 阶段 3：迁移其余游戏

其余还处于占位或轻实现状态的小游戏统一迁到 `packages/`，完成目录规范收口。

### 阶段 4：删除旧结构

迁移全部完成后，清理：

- `code/games/`
- `code/lib/src/generated/game_modules/`

确保源码真身只存在于 `packages/`。

## 11. 文档同步要求

迁移到 package 化方案后，以下文档需要同步更新：

- [game_module_spec.md](D:/Projects/flutter/FunBox/docs/game_module_spec.md)
- [funbox_product_tech_plan.md](D:/Projects/flutter/FunBox/docs/funbox_product_tech_plan.md)

更新重点包括：

- 模块根目录从 `code/games/<id>/` 改为 `packages/game_<id>/`
- 公共接口来源改为 `funbox_game_api`
- 生成器职责从“复制源码”改为“维护 path dependencies + 生成注册表”

## 12. 验收标准

package 化方案完成后，应满足以下条件：

- 新增一个小游戏 package 后，不修改大厅页面代码即可出现在首页、分类、收藏中
- 主工程不再维护具体游戏的手写 import
- 主工程不再复制小游戏源码到 `generated/game_modules`
- 每个小游戏的代码、资源、manifest 均位于自己的 package 目录
- 主工程通过自动生成的 path dependencies 引入本地游戏包
- 大厅和详情页能正确读取 package 内部资源
- 收藏、最近游玩、继续游戏仍通过 `gameId` 正常工作
- manifest 缺字段、资源缺失、包名不匹配时，生成阶段直接失败

## 13. 推荐结论

本地 package 化是比当前“源码镜像到 generated”更长期、更清晰的架构方案。

它保留了现有“扫描 + 自动注册”的优点，同时进一步实现了：

- 更清晰的模块边界
- 更符合 Flutter 工程模型的依赖方式
- 更稳定的资源归属
- 更低的后续扩展和维护成本

从长期看，`packages/<game_id>/ + funbox_game_api + 自动生成主工程依赖与注册表`，是最符合 `闲趣盒子` “可拔插小游戏平台”定位的实现路线。
