# 语言
所有交互使用中文
- 任何时候都不要自动commit代码

# 目录结构
code：代码
design: 界面设计
docs：文档


# 文件要求
`docs/` 只放文档，不放图片、切图或临时导出文件。

## 文档分层
- 平台级、跨游戏、规范类文档放在 `docs/` 根目录
- 游戏专属文档统一放在 `docs/games/`
- 临时计划、里程碑或阶段性方案可以保留日期前缀放到 `docs/plans/`下，其他文档尽量不用日期前缀

## 命名规则
- 所有 Markdown 文件统一使用 `kebab-case`，禁止下划线
- 游戏文档优先使用下面两类命名：
  - `docs/games/<slug>-platform-design.md`
  - `docs/games/<slug>-ui-design.md`
- 规则、规范、说明类文档优先使用短名称，例如 `game-ui-style-requirements.md`

## 资源位置
- 游戏图标、切图等资源放到对应游戏包目录下
- `design/` 仅用于界面设计参考图，不作为最终资源仓库

# 设计要求
界面设计需要遵循 `docs/game-ui-style-requirements.md`
