# Agent24 使用范围

## 核心问题：必须在这个仓库下跑吗？

**不是。** Agent24 是全局安装的 Claude Code Skills。

## 安装

```bash
git clone https://github.com/jhfnetboy/Agent24.git
cd Agent24
bash install.sh
```

安装后的文件布局：

```
~/.claude/
├── skills/                    ← 技能（全局可用）
│   ├── evolve/SKILL.md        ← /evolve 自进化循环
│   ├── evaluate/SKILL.md      ← /evaluate 独立评估
│   ├── setup/SKILL.md         ← /setup 交互初始化
│   └── org-sync/SKILL.md      ← /org-sync 组织上下文
├── memory/                    ← 全局记忆
│   ├── identity.md            ← L0: 用户身份
│   ├── essential.md           ← L1: 关键事实摘要
│   ├── MEMORY.md              ← 索引
│   └── *.md                   ← 策略/反馈/参考记忆
├── org/                       ← 组织上下文（可 git 同步）
│   ├── blueprint.md
│   └── components.yaml
├── agent-config.yaml          ← Agent 配置（自动进化）
└── hook_state/                ← Hook 状态文件
```

## 使用方式

```bash
# 在任意项目目录
cd ~/Dev/any-project
claude
> /setup                    # 首次：交互式初始化
> /evolve fix the auth bug  # 自进化任务
> /evaluate                 # 评估最近工作
> /org-sync                 # 查看组织上下文
```

## 全局 + 项目级混合

```
~/.claude/memory/              ← 全局：跨项目通用策略
~/Dev/project-a/.claude/memory/  ← 项目级：专属知识
```

- **全局 memory**: 通用策略、用户偏好、组织上下文
- **项目 memory**: 项目架构、已知问题、本地约定
- **加载优先级**: /evolve Phase 0 同时读两处，项目级优先
- **写入规则**: `memory_scope: auto`（有 .claude/ 写项目级，否则写全局）

## 这个仓库的角色

autoagent 仓库是 **Agent24 的开发仓库**：

| 角色 | 说明 |
|------|------|
| 源码 | Skills、hooks、config 的源码 |
| 安装器 | `install.sh` 复制到 `~/.claude/` |
| 文档 | 设计文档、验收文档、调研 |
| 原始 AutoAgent | agent.py / agent-claude.py 保留，API Key 模式可用 |
| vendor | HyperAgents、MemPalace 等参考实现 |
