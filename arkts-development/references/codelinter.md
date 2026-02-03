# CodeLinter 代码检查工具

codelinter 是 HarmonyOS 的代码检查与修复工具，可集成到门禁或 CI/CD 环境中。

## 命令格式

```bash
codelinter [options] [dir]
```

- `options`: 可选配置参数
- `dir`: 待检查的工程根目录（可选，默认为当前目录）

## 命令参数

| 参数 | 说明 |
|------|------|
| `--config, -c <filepath>` | 指定规则配置文件 (code-linter.json5) |
| `--fix` | 检查同时执行自动修复 |
| `--format, -f <format>` | 输出格式: `default`/`json`/`xml`/`html` |
| `--output, -o <filepath>` | 指定结果保存位置（不在命令行显示） |
| `--version, -v` | 查看版本 |
| `--product, -p <productName>` | 指定生效的 product |
| `--incremental, -i` | 仅检查 Git 增量文件（新增/修改/重命名） |
| `--help, -h` | 查询帮助 |
| `--exit-on, -e <levels>` | 指定返回非零退出码的告警级别 |

## 基本用法

### 在工程根目录下执行

```bash
# 使用默认规则检查当前工程
codelinter

# 指定规则配置文件
codelinter -c ./code-linter.json5

# 检查并自动修复
codelinter -c ./code-linter.json5 --fix
```

### 在非工程目录下执行

```bash
# 检查指定工程目录
codelinter /path/to/project

# 检查多个目录或文件
codelinter dir1 dir2 file1.ets

# 指定规则文件和工程目录
codelinter -c /path/to/code-linter.json5 /path/to/project

# 检查并修复指定工程
codelinter -c ./code-linter.json5 /path/to/project --fix
```

## 输出格式

```bash
# 默认文本格式输出到命令行
codelinter /path/to/project

# JSON 格式输出
codelinter /path/to/project -f json

# HTML 格式保存到文件
codelinter /path/to/project -f html -o ./report.html

# XML 格式保存到文件
codelinter /path/to/project -f xml -o ./report.xml
```

## 增量检查

对 Git 工程中的增量文件执行检查（仅检查新增、修改、重命名的文件）：

```bash
codelinter -i
codelinter --incremental
```

## 指定 Product

当工程存在多个 product 时，指定生效的 product：

```bash
codelinter -p free /path/to/project
codelinter --product default
```

## 退出码 (--exit-on)

用于 CI/CD 中根据告警级别控制流程。告警级别：`error`、`warn`、`suggestion`

退出码计算方式（3位二进制数，从高到低表示 error, warn, suggestion）：

| 配置 | 检查结果包含 | 二进制 | 退出码 |
|------|-------------|--------|--------|
| `--exit-on error` | error, warn, suggestion | 100 | 4 |
| `--exit-on error` | warn, suggestion | 000 | 0 |
| `--exit-on error,warn` | error, warn | 110 | 6 |
| `--exit-on error,warn,suggestion` | error | 100 | 4 |
| `--exit-on error,warn,suggestion` | error, warn, suggestion | 111 | 7 |

```bash
# 仅 error 级别返回非零退出码
codelinter --exit-on error

# error 和 warn 级别返回非零退出码
codelinter --exit-on error,warn

# 所有级别都返回非零退出码
codelinter --exit-on error,warn,suggestion
```

## CI/CD 集成示例

```bash
# 完整的 CI 检查流程
codelinter -c ./code-linter.json5 \
  -f json \
  -o ./codelinter-report.json \
  --exit-on error,warn

# 增量检查（仅检查变更文件）
codelinter -i -c ./code-linter.json5 --exit-on error

# 检查并自动修复，生成 HTML 报告
codelinter -c ./code-linter.json5 \
  --fix \
  -f html \
  -o ./codelinter-report.html
```

## 规则配置文件 (code-linter.json5)

默认规则清单可在检查完成后，根据命令行提示查看生成的 `code-linter.json5` 文件。

示例配置：

```json5
{
  "files": [
    "**/*.ets",
    "**/*.ts"
  ],
  "ignore": [
    "**/node_modules/**",
    "**/oh_modules/**",
    "**/build/**"
  ],
  "ruleSet": ["plugin:@ohos/recommended"],
  "rules": {
    "@ohos/no-any": "error",
    "@ohos/no-console": "warn"
  }
}
```
