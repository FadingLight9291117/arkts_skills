# Hvigor 命令行构建工具 (hvigorw)

hvigorw 是 Hvigor 的 wrapper 包装工具，支持自动安装 Hvigor 构建工具和相关插件依赖，以及执行 Hvigor 构建命令。

## 命令格式

```bash
hvigorw [taskNames...] <options>
```

## 编译构建任务

| 任务 | 说明 |
|------|------|
| `clean` | 清理构建产物 build 目录 |
| `assembleHap` | 构建 Hap 应用 |
| `assembleApp` | 构建 App 应用 |
| `assembleHsp` | 构建 Hsp 包 |
| `assembleHar` | 构建 Har 包 |
| `collectCoverage` | 基于打点数据生成覆盖率统计报表 |

## 常用构建参数

| 参数 | 说明 |
|------|------|
| `-p buildMode={debug\|release}` | 指定构建模式。默认：Hap/Hsp/Har 为 debug，App 为 release |
| `-p debuggable=true/false` | 覆盖 buildOption 中的 debuggable 配置 |
| `-p product={ProductName}` | 指定 product 进行编译，默认为 default |
| `-p module={ModuleName}@{TargetName}` | 指定模块及 target 编译（需配合 `--mode module`） |
| `-p ohos-test-coverage={true\|false}` | 执行测试框架代码覆盖率插桩编译 |
| `-p parameterFile=param.json` | 设置 oh-package.json5 的参数配置文件 |

## 构建示例

```bash
# 清理构建产物
hvigorw clean

# Debug 模式构建 Hap
hvigorw assembleHap -p buildMode=debug

# Release 模式构建 App
hvigorw assembleApp -p buildMode=release

# 构建指定 product
hvigorw assembleHap -p product=free

# 构建指定模块
hvigorw assembleHap -p module=entry@default --mode module

# 构建多个模块
hvigorw assembleHar -p module=library1@default,library2@default --mode module
```

## 测试命令

### Instrument Test (设备测试)

```bash
hvigorw onDeviceTest -p module={moduleName} -p coverage={true|false} -p scope={suiteName}#{methodName}
```

- `module`: 执行测试的模块，缺省执行所有模块
- `coverage`: 是否生成覆盖率报告，默认 true
- `scope`: 测试范围，格式 `{suiteName}#{methodName}` 或 `{suiteName}`
- `ohos-debug-asan`: 是否启用 ASan 检测，默认 false (5.19.0+)

**输出路径:**
- 覆盖率报告: `<module-path>/.test/default/outputs/ohosTest/reports`
- 测试结果: `<project>/<module>/.test/default/intermediates/ohosTest/coverage_data/test_result.txt`

### Local Test (本地测试)

```bash
hvigorw test -p module={moduleName} -p coverage={true|false} -p scope={suiteName}#{methodName}
```

**输出路径:**
- 覆盖率报告: `<module-path>/.test/default/outputs/test/reports`
- 测试结果: `<project>/<module>/.test/default/intermediates/test/coverage_data/test_result.txt`

## 日志级别

| 参数 | 说明 |
|------|------|
| `-e, --error` | 设置日志级别为 error |
| `-w, --warn` | 设置日志级别为 warn |
| `-i, --info` | 设置日志级别为 info |
| `-d, --debug` | 设置日志级别为 debug |
| `--stacktrace` | 开启打印异常堆栈信息 |

## 构建分析 (Build Analyzer)

| 参数 | 说明 |
|------|------|
| `--analyze=normal` | 普通模式分析 |
| `--analyze=advanced` | 进阶模式，更详细的任务耗时数据 |
| `--analyze=ultrafine` | 超精细化模式，ArkTS 编译详细打点 (6.0.0+) |
| `--analyze=false` | 不启用构建分析 |
| `--config properties.hvigor.analyzeHtml=true` | 生成 HTML 可视化报告到 `.hvigor/report` |

## 守护进程 (Daemon)

| 参数 | 说明 |
|------|------|
| `--daemon` | 启用守护进程 |
| `--no-daemon` | 关闭守护进程（命令行模式推荐） |
| `--stop-daemon` | 关闭当前工程的守护进程 |
| `--stop-daemon-all` | 关闭所有工程的守护进程 |
| `--status-daemon` | 查询所有 Hvigor 守护进程信息 |
| `--max-old-space-size=12345` | 设置老生代内存大小 (MB) |
| `--max-semi-space-size=32` | 设置新生代半空间大小 (MB, 5.18.4+) |

## 性能与内存优化

| 参数 | 说明 |
|------|------|
| `--parallel` / `--no-parallel` | 开启/关闭并行构建（默认开启） |
| `--incremental` / `--no-incremental` | 开启/关闭增量构建（默认开启） |
| `--optimization-strategy=performance` | 性能优先模式，加快构建但占用更多内存 (5.19.2+) |
| `--optimization-strategy=memory` | 内存优先模式（默认）(5.19.2+) |

## 公共命令

| 任务 | 说明 |
|------|------|
| `tasks` | 打印工程各模块包含的任务信息 |
| `taskTree` | 打印工程各模块的任务依赖关系 |
| `prune` | 清除 30 天未使用的缓存并删除 pnpm 未引用包 |
| `buildInfo` | 打印 build-profile.json5 配置信息 (5.18.4+) |

### buildInfo 扩展参数

```bash
# 打印工程级配置
hvigorw buildInfo

# 打印指定模块配置
hvigorw buildInfo -p module=entry

# 包含 buildOption 配置
hvigorw buildInfo -p buildOption

# JSON 格式输出
hvigorw buildInfo -p json
```

## 其他参数

| 参数 | 说明 |
|------|------|
| `-h, --help` | 打印帮助信息 |
| `-v, --version` | 打印版本信息 |
| `-s, --sync` | 同步工程信息到 `./hvigor/outputs/sync/output.json` |
| `-m, --mode` | 指定执行目录级别 (如 `-m project`) |
| `--type-check` | 开启 hvigorfile.ts 类型检查 |
| `--watch` | 观察模式，用于预览和热加载 |
| `--node-home <string>` | 指定 Node.js 路径 |
| `--config, -c` | 指定 hvigor-config.json5 参数 |

## CI/CD 常用命令组合

```bash
# 完整的 Release 构建流程
hvigorw clean && hvigorw assembleApp -p buildMode=release --no-daemon

# 带构建分析的 Debug 构建
hvigorw assembleHap -p buildMode=debug --analyze=advanced --no-daemon

# 运行测试并生成覆盖率报告
hvigorw onDeviceTest -p coverage=true --no-daemon

# 内存受限环境构建
hvigorw assembleHap --optimization-strategy=memory --no-daemon

# 清理缓存
hvigorw prune
hvigorw --stop-daemon-all
```
