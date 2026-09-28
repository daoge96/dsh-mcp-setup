# DSH MCP 装载套件

在 **DeepSeek Harness（DSH / DSH Desktop）** 中一键装载一组 MCP 服务器的配置与说明。

> **设计原则：明文密钥不入库。** 仓库里的配置只写占位符 / 环境变量引用，真实 token 由你本机的环境提供。

## 包含的 MCP 服务器

| serverName | 用途 | 传输 | 密钥环境变量 | 备注 |
| --- | --- | --- | --- | --- |
| `tavily` | 联网搜索 | streamable-http | `TAVILY_API_KEY` | |
| `exa` | exa 搜索 | streamable-http | `EXA_API_KEY` | |
| `github` | GitHub 读写 | streamable-http | `GITHUB_TOKEN` | 需 PAT |
| `deepwiki` | 仓库文档问答 | streamable-http | — | 免 token |
| `papers` | 论文搜索（latex-tools） | streamable-http | — | |
| `sequential-thinking` | 结构化分步推理 | stdio | — | **强制启用** |

`sequential-thinking` 通过 `npx` 启动本地 stdio 子进程，默认挂载且开启自动重连；require Node.js ≥ 20。

## 前置要求

- 已安装 DSH Desktop，或可运行 `dsh web`（本套件使用桌面端默认 profile：`web`）。
- Node.js ≥ 20（`sequential-thinking` 的 `npx` 需要）。
- 能编辑 `$DSH_HOME/profiles/web/cordis.patch.yml`（`DSH_HOME` 默认 `~/.dsh`）。

## 快速开始

### 路线 A：一键脚本（推荐）

macOS / Linux：

```bash
git clone https://github.com/daoge96/dsh-mcp-setup.git
cd dsh-mcp-setup
bash scripts/install.sh
```

Windows PowerShell：

```powershell
git clone https://github.com/daoge96/dsh-mcp-setup.git
cd dsh-mcp-setup
.\scripts\install.ps1
```

脚本会把 `cordis.patch.yml` 追加进你的 profile（带标记、可重复执行、自动备份），随后你只需：

1. 设置环境变量（见下节）；
2. **完全退出并重启 DSH Desktop**。

### 路线 B：手动 patch

把 [`cordis.patch.yml`](./cordis.patch.yml) 的内容追加到 `$DSH_HOME/profiles/web/cordis.patch.yml`，保存后重启。

> 注意：只改 `cordis.patch.yml`（用户覆盖层），**不要**改自动生成的 `cordis.yml`。

### 路线 C：借助 `dsh-mcp-connector` 插件导入 JSON

装了 MCP 连接器插件后，左侧「🧩 MCP连接器 → ＋ 添加连接 → 导入 JSON」，粘贴 [`mcpServers.example.json`](./mcpServers.example.json)，把 `REPLACE_*` 换成真值即可（此路线不走环境变量，密钥由插件本机保存）。

## 环境变量

参考 [`.env.example`](./.env.example)（`.env` 已被 gitignore）：

```bash
export TAVILY_API_KEY=tvly-xxxxxxxx
export EXA_API_KEY=xxxxxxxx
export GITHUB_TOKEN=ghp_xxxxxxxx
```

配置里用 `!!js` 表达式引用，**真值永远不写进仓库文件**：

```yaml
headers:
  Authorization: !!js '`Bearer ${process.env.TAVILY_API_KEY}`'
```

Windows 设置（当前会话）：`$env:TAVILY_API_KEY="..."`。若要长期生效，建议写进 DSH 的凭据文件 `~/.dsh/.credentials.yaml`（0600 权限、不回显）或用系统环境变量。

## 强制启用 sequential-thinking

- 它在 `cordis.patch.yml` 中作为普通行挂载，**默认就是启用状态**；`reconnect` 默认开启、指数退避。
- 如果你希望「连不上就不让 DSH 起」，把该行的 `failOnStartupError` 设为 `true`（见 `cordis.patch.yml` 注释）。
- 若走路线 C（连接器），`sequential-thinking` 是 `stdio` 卡片，需要本机 PATH 中有 `npx`。

## 校验

- 重启后，在会话里让模型调用「sequential thinking」相关工具；或让 DSH 列出 `mcp__sequential-thinking__*`。
- 工具统一命名为 `mcp__<serverName>__<tool>`。
- 常见失败：`npx` 不在 DSH 进程 PATH；`GITHUB_TOKEN` 无效（GitHub 端点要求 `Authorization: Bearer <PAT>`）。

## 排错要点

1. **不要重复挂载**：同一 `serverName` 既手写 patch 行、又用管理插件挂载会工具冲突。
2. **只桥接 tools**：MCP 的 Resources / Prompts 在 DSH 里不被消费。
3. **改完必须重启**桌面端（`dsh web` 有 HMR，桌面端建议完全退出再开）。

## 卸载

删除 `cordis.patch.yml` 中 `# >>> dsh-mcp-setup <<<` 标记之间的内容后重启即可（脚本重复执行会自动替换该段）。

## 安全说明

- 仓库内只有 URL、serverName、环境变量名与占位符，**没有任何明文 token**。
- `HEAD` 上同时给了 patch 与示例 JSON 两种形态，二者等价，按你选用的路线取其一。

## License

MIT
