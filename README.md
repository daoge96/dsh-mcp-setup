# DSH MCP 装载套件

在 **DeepSeek Harness（DSH / DSH Desktop）** 中装载一组 MCP 服务器。**密钥走环境变量，明文不入仓库。**

## 包含的 MCP 服务器

| serverName | 用途 | 传输 | 密钥环境变量 |
| --- | --- | --- | --- |
| `tavily` | 联网搜索 | streamable-http | `TAVILY_API_KEY` |
| `exa` | exa 搜索 | streamable-http | `EXA_API_KEY` |
| `github` | GitHub 读写 | streamable-http | `GITHUB_TOKEN` |
| `deepwiki` | 仓库文档问答 | streamable-http | 免 token |
| `papers` | 论文搜索（latex-tools） | streamable-http | 免 token |
| `sequential-thinking` | 结构化分步推理 | stdio | 免 token（**强制启用**） |

## 为什么密钥不写成明文

GitHub 的**远程 MCP 服务**会对**公开仓库**的每次工具调用输入做 secret scanning + push protection：一旦命中 `ghp_…` 这类高置信密钥，调用会被**默认阻止**并返回：

```
Secret Scanning has rejected the input for this tool call. In order to continue, remove the secret.
```

即「内容里带明文密钥的文件，通过 MCP 写不进去」。两条绕过办法（本仓库没用）：

1. 打开它给出的 `…/security/secret-scanning/unblock-secret/…` 链接点允许，再在 3 小时内重推；
2. 把仓库设为 **private**（未开 GHAS 的私有库不在 MCP 扫描范围内）。

所以本仓库统一用 `!!js process.env.*` 引用，克隆即用、零泄露。

## 快速开始

### 方式一：直接复制

把 [`cordis.patch.yml`](./cordis.patch.yml) 内容**整段追加**到：

```
$DSH_HOME/profiles/web/cordis.patch.yml
```

（`DSH_HOME` 默认 `~/.dsh`；只改 `cordis.patch.yml`，别改自动生成的 `cordis.yml`。）

### 方式二：一键脚本

macOS / Linux：

```bash
git clone https://github.com/daoge96/dsh-mcp-setup.git
cd dsh-mcp-setup && bash scripts/install.sh
```

Windows：

```powershell
git clone https://github.com/daoge96/dsh-mcp-setup.git
cd dsh-mcp-setup
.\scripts\install.ps1
```

脚本幂等、自动备份。

### 方式三：用 `dsh-mcp-connector` 导入 JSON

装连接器插件后 →「🧩 MCP连接器 → ＋ 添加连接 → 导入 JSON」→ 粘贴 [`mcpServers.example.json`](./mcpServers.example.json)（该路线的 key 直接在 JSON 里写明文，由插件本机保存）。

## 设置环境变量（关键）

配置用 `!!js` 读取**进程环境变量**：

```yaml
headers:
  Authorization: !!js '`Bearer ${process.env.GITHUB_TOKEN}`'
```

```bash
# macOS / Linux（当前 shell）
export TAVILY_API_KEY=...  EXA_API_KEY=...  GITHUB_TOKEN=...
```

⚠️ **DSH Desktop 是 GUI 应用**：从 Finder / 开始菜单启动时，可能**读不到 shell rc 里 export 的变量**。

- Windows：设成「用户环境变量」后重启应用最稳。
- macOS：用 `launchctl setenv GITHUB_TOKEN ...`（重启应用生效），或干脆从终端 `open -a "DSH Desktop"` 启动。

## 强制启用 sequential-thinking

- 该行默认挂载、`reconnect` 常开；`npx` 需本机 Node ≥ 20。
- 想「连不上就拒绝启动」，把该行 `failOnStartupError` 改成 `true`。

## 排错

1. 同一 `serverName` **别重复挂载**（手写行 + 管理插件二选一）。
2. DSH **只桥接 tools**，MCP 的 Resources / Prompts 不消费。
3. 工具名为 `mcp__<serverName>__<tool>`；改完**完全退出并重启**桌面端。
4. `github` 若报 401：确认 `GITHUB_TOKEN` 已注入进程（见上），必要时把 header 的 `Bearer ` 去掉只留 token 再试。

## 卸载

删除 `cordis.patch.yml` 中 `# >>> dsh-mcp-setup <<<` 标记之间的内容后重启。

## License

MIT
