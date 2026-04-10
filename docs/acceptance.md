# Agent24 验收文档

> 功能验收清单 + 测试方法，按模块组织。

## 1. 安装 (`install.sh`)

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 1.1 | Skills 复制到 `~/.claude/skills/` | `ls ~/.claude/skills/{evolve,evaluate,setup,org-sync}/SKILL.md` | ☐ |
| 1.2 | agent-config.yaml 模板安装 | `test -f ~/.claude/agent-config.yaml` | ☐ |
| 1.3 | org 目录创建 | `test -d ~/.claude/org/` | ☐ |
| 1.4 | 已有 config 不被覆盖 | 修改 config → 重新 install → 内容不变 | ☐ |
| 1.5 | 已有 skill 备份到 backups/ | `ls ~/.claude/backups/agent24-*/skills/` | ☐ |
| 1.6 | 重复安装幂等 | 连续运行 2 次，无报错，无重复 | ☐ |

## 2. 交互初始化 (`/setup`)

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 2.1 | 分步问答（不一次问完） | 运行 `/setup`，观察分组提问 | ☐ |
| 2.2 | identity.md 生成 (L0) | `cat ~/.claude/memory/identity.md`，<100 token | ☐ |
| 2.3 | user memory 文件含 front-matter | 检查 `user-role.md` 有 name/description/type/created/importance | ☐ |
| 2.4 | MEMORY.md 索引更新 | `grep user-role ~/.claude/memory/MEMORY.md` | ☐ |
| 2.5 | org blueprint 创建 (团队模式) | `cat ~/.claude/org/blueprint.md`，<2000 token | ☐ |
| 2.6 | 共享 repo 设置 | 回答有共享 repo → 自动 `/org-sync repo {url}` | ☐ |
| 2.7 | 已有配置检测 + 跳过 | 二次运行 `/setup`，跳过已有部分 | ☐ |
| 2.8 | 项目级 memory 创建 | `cat .claude/memory/project-overview.md` | ☐ |

## 3. 自进化循环 (`/evolve`)

### 3.1 Phase 0: 分层记忆加载

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.1.1 | L0 加载 identity.md | 无 identity.md 时不报错，有时自动加载 | ☐ |
| 3.1.2 | L1 加载 essential.md + blueprint | 创建 essential.md → /evolve → 验证被读取 | ☐ |
| 3.1.3 | L2 选择性加载 | MEMORY.md 有 10 条，只读取与任务相关的 | ☐ |
| 3.1.4 | L3 不自动触发 | 正常任务不触发深度搜索 | ☐ |

### 3.2 Phase 1-2: 计划 + 执行

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.2.1 | 不问问题直接执行 | `/evolve` 不中途询问 | ☐ |
| 3.2.2 | 输出计划后立即执行 | 观察 plan → execute 无停顿 | ☐ |
| 3.2.3 | 错误时适应 | 给一个会出错的任务，观察 fail-fast-adapt | ☐ |

### 3.3 Phase 3: 评估

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.3.1 | Stage 1 correctness gate | 设 gate=3，故意做错 → overall ≤ 2 | ☐ |
| 3.3.2 | staged=true 早退 | correctness < gate → 跳过 Stage 2 | ☐ |
| 3.3.3 | staged=false 全评 | 设 staged: false → correctness < gate 仍评全部 | ☐ |
| 3.3.4 | result 标签正确 | success/partial/failed 与分数对应 | ☐ |

### 3.4 Phase 3 Stage 4: 外部评估

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.4.1 | evaluator=self 无变化 | 默认配置不触发外部评估 | ☐ |
| 3.4.2 | evaluator=codex 调用 MCP | 设 codex → 观察 Codex 被调用 | ☐ |
| 3.4.3 | Codex 分数为最终分数 | 比较 self_score vs score (score=external) | ☐ |
| 3.4.4 | evaluator=agent-speaker 发消息 | 设 agent-speaker → 观察消息发送 | ☐ |
| 3.4.5 | agent-speaker 超时回退 | 无响应 → 回退到自评 + 警告 | ☐ |
| 3.4.6 | evaluator=dual 双重评估 | 两个外部分数取平均 | ☐ |
| 3.4.7 | self_score 始终记录 | 任何模式下 archive 都有 self_score | ☐ |

### 3.5 Phase 4: 改进

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.5.1 | 高分跳过 memory | score=5 + 无新知识 → 不写 memory | ☐ |
| 3.5.2 | 低分记录失败 | score < 3 → 写失败 memory | ☐ |
| 3.5.3 | config success_rate 更新 | 运行 2 次 → 检查 uses 和 success_rate 变化 | ☐ |
| 3.5.4 | results.log 追加 YAML | `cat .claude/results.log` 有结构化条目 | ☐ |
| 3.5.5 | parent 血统链接 | 同 task_type 两次 → 第二次有 parent | ☐ |
| 3.5.6 | essential.md 更新 | 写了 importance ≥ 4 的 memory → essential 更新 | ☐ |
| 3.5.7 | archive 含 evaluator 字段 | `grep evaluator .claude/results.log` | ☐ |

### 3.6 Phase 5: 报告

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 3.6.1 | 标准报告格式 | 包含 Task/Result/Score/Strategy/Learned | ☐ |
| 3.6.2 | 外部评估对比表 | evaluator ≠ self 时显示 Self vs External 对比 | ☐ |

## 4. 独立评估 (`/evaluate`)

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 4.1 | 评估文件 | `/evaluate src/main.py` | ☐ |
| 4.2 | 评估 last commit | `/evaluate last commit` | ☐ |
| 4.3 | 评估 PR | `/evaluate 42`（需 gh CLI） | ☐ |
| 4.4 | 无目标自动检测 | `/evaluate` → 自动选择 staged/unstaged/last commit | ☐ |
| 4.5 | correctness gate 生效 | correctness < 3 → overall ≤ 2 | ☐ |
| 4.6 | 6 维度评分表 | 输出包含完整维度表 | ☐ |
| 4.7 | 历史对比 | 有 memory 时显示趋势 | ☐ |

## 5. 组织上下文 (`/org-sync`)

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 5.1 | /org-sync init 创建蓝图 | 运行后 `cat ~/.claude/org/blueprint.md` | ☐ |
| 5.2 | /org-sync 显示上下文 | 显示蓝图 + 当前组件 + 上下游 | ☐ |
| 5.3 | /org-sync add 添加组件 | `grep new-component ~/.claude/org/components.yaml` | ☐ |
| 5.4 | /org-sync update 刷新状态 | `cat ~/.claude/org/status.md` 有最近 commit | ☐ |
| 5.5 | /org-sync repo 设置 git | `git -C ~/.claude/org remote -v` 显示 repo URL | ☐ |
| 5.6 | /org-sync pull 拉取 | 从共享 repo 拉取最新 | ☐ |
| 5.7 | /org-sync push 推送 | 本地变更推送到共享 repo | ☐ |
| 5.8 | local_path 安全校验 | 含 `$` 或反引号的路径被拒绝 | ☐ |
| 5.9 | blueprint < 2000 token | `wc -w ~/.claude/org/blueprint.md` < 1500 词 | ☐ |

## 6. 记忆系统

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 6.1 | front-matter 完整 | 每个 memory 文件有 name/description/type | ☐ |
| 6.2 | temporal 字段 | 有 created/valid_from/valid_to/importance | ☐ |
| 6.3 | MEMORY.md 索引一致 | 索引条目 = 实际文件数 | ☐ |
| 6.4 | essential.md 自动生成 | importance ≥ 4 的 top 10，< 500 token | ☐ |
| 6.5 | memory_scope: auto | 有 .claude/ 时写项目级，否则写全局 | ☐ |
| 6.6 | 文件名规范 | 小写 + 连字符，无空格/特殊字符 | ☐ |

## 7. Auto-Save Hooks

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 7.1 | Stop hook 间隔触发 | 15 条消息后 stop → 提示保存 memory | ☐ |
| 7.2 | Stop hook 重入保护 | 保存后再 stop → 不重复触发 | ☐ |
| 7.3 | PreCompact hook 阻塞一次 | 上下文压缩前 → 提示紧急保存 | ☐ |
| 7.4 | PreCompact session 隔离 | 不同 session 互不影响 | ☐ |
| 7.5 | 无 python3 时降级 | 没有 python3 → 警告但不崩溃 | ☐ |
| 7.6 | SAVE_INTERVAL 可配置 | `export AGENT24_SAVE_INTERVAL=5` → 5 条触发 | ☐ |

## 8. Agent 通信 (agent-speaker MCP)

| # | 验收项 | 测试方法 | 状态 |
|---|--------|---------|------|
| 8.1 | MCP server 启动 | `agent-speaker mcp` 输出 JSON-RPC | ☐ |
| 8.2 | tools/list 返回 11 个工具 | 6 nak + 5 agent 工具 | ☐ |
| 8.3 | agent_init_identity 生成密钥 | `cat ~/.agent-speaker/identity.json` | ☐ |
| 8.4 | agent_send_message 发送 | 发送后返回 event ID + relay 确认 | ☐ |
| 8.5 | agent_query_messages 查询 | 查询返回结构化事件列表 | ☐ |
| 8.6 | agent_timeline 时间线 | 显示最近 agent 消息 | ☐ |
| 8.7 | agent_manage_relays 列表 | 返回默认 relay 列表 | ☐ |

## 9. 端到端场景

| # | 场景 | 步骤 | 状态 |
|---|------|------|------|
| 9.1 | 新用户首次使用 | clone → install.sh → /setup → /evolve task | ☐ |
| 9.2 | 团队新成员加入 | install.sh → /setup (选共享 repo) → /org-sync pull | ☐ |
| 9.3 | 跨 session 记忆恢复 | /evolve task1 → 关闭 → 新 session → /evolve task2 → 验证 memory 被读取 | ☐ |
| 9.4 | 外部评估流程 | 设 evaluator: codex → /evolve → 验证 Codex 被调用 + 分数对比表 | ☐ |
| 9.5 | 多项目切换 | 项目 A /evolve → 项目 B /evolve → 验证全局 memory 共享、项目 memory 隔离 | ☐ |
| 9.6 | 进化链追踪 | 同类型任务跑 3 次 → results.log 有 parent 链 + success_rate 变化 | ☐ |

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.1 | 2026-04-09 | 初始 Skills: evolve, evaluate, org-sync |
| v0.2 | 2026-04-10 | MemPalace 借鉴: 分层记忆, temporal validity, auto-save hooks |
| v0.3 | 2026-04-10 | /init → /setup 改名, 外部评估系统, agent-speaker MCP |
