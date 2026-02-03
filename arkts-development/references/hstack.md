# 堆栈解析工具 (hstack)

hstack 是用于将 Release 应用混淆后的 crash 堆栈解析为源码对应堆栈的工具，支持 Windows、Mac、Linux 三个平台。

## 命令格式

```bash
hstack [options]
```

## 命令参数

| 参数 | 说明 |
|------|------|
| `-i, --input` | 指定 crash 文件归档目录 |
| `-c, --crash` | 指定一条 crash 堆栈 |
| `-o, --output` | 指定解析结果输出目录（使用 `-c` 时指定输出文件） |
| `-s, --sourcemapDir` | 指定 sourcemap 文件归档目录 |
| `--so, --soDir` | 指定 shared object (.so) 文件归档目录 |
| `-n, --nameObfuscation` | 指定 nameCache 文件归档目录 |
| `-v, --version` | 查看版本 |
| `-h, --help` | 查询帮助 |

## 参数约束

- crash 文件目录 (`-i`) 与 crash 堆栈 (`-c`) **必须且只能提供一项**
- sourcemap (`-s`) 与 shared object (`--so`) 目录**至少提供一项**
- 如需还原混淆的方法名，需**同时提供** sourcemap 和 nameCache 文件
- 路径参数不支持特殊字符：`` `~!@#$^&*=|{};,\s\[\]<>? ``

## 环境配置

1. 将 Command Line Tools 的 `bin` 目录配置到 PATH 环境变量
2. 配置 Node.js 到环境变量
3. 解析 C++ 异常需配置 SDK 的 `native\llvm\bin` 目录到环境变量 `ADDR2LINE_PATH`

## 使用示例

### 解析 crash 文件目录

```bash
# 完整解析命令
hstack -i crashDir -o outputDir -s sourcemapDir --so soDir -n nameCacheDir

# 仅使用 sourcemap 解析 (ArkTS)
hstack -i crashDir -o outputDir -s sourcemapDir

# 仅使用 so 文件解析 (C++)
hstack -i crashDir -o outputDir --so soDir

# 包含方法名还原
hstack -i crashDir -o outputDir -s sourcemapDir -n nameCacheDir
```

### 解析单条堆栈

```bash
# 输出到控制台
hstack -c "at har (entry|har|1.0.0|src/main/ets/pages/Index.ts:58:58)" -s sourcemapDir

# 输出到文件
hstack -c "at har (entry|har|1.0.0|src/main/ets/pages/Index.ts:58:58)" -s sourcemapDir -o result.txt
```

## 输出说明

- 解析结果输出到 `-o` 指定目录，文件以原始 crash 文件名加 `_` 前缀命名
- 不指定 `-o` 时：
  - 使用 `-i` 输入：输出到 crashDir 目录
  - 使用 `-c` 输入：直接输出到控制台

## 文件获取

### Sourcemap 文件

构建产物中的 sourcemap 文件，包含：
- 路径信息映射
- 行列号映射 (mappings 字段)
- package-info 信息

### NameCache 文件

构建产物中的 nameCache 文件，包含：
- `IdentifierCache`: 标识符混淆映射
- `MemberMethodCache`: 成员方法混淆映射，格式为 `"源码方法名:起始行:结束行": "混淆后方法名"`

### Shared Object (.so) 文件

构建 Release 应用时，默认 so 文件不包含符号表。如需生成包含符号表的 so 文件，在模块 `build-profile.json5` 中配置：

```json5
{
  "buildOption": {
    "externalNativeOptions": {
      "arguments": "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    }
  }
}
```

## 堆栈解析原理

### Crash 堆栈格式

```
at har (entry|har|1.0.0|src/main/ets/components/mainpage/MainPage.js:58:58)
at i (entry|entry|1.0.0|src/main/ets/pages/Index.ts:71:71)
```

路径格式：`引用方packageName|被引用方packageName|version|源码相对路径`

### 解析步骤

1. **根据路径信息找到 sourcemap**
   - 从路径 `entry|har|1.0.0|src/main/ets/...` 在 entry 模块 sourcemap 中查找对应字段

2. **利用 sourcemap 还原路径和行列号**
   - 根据 `sources` 和 `mappings` 字段解析
   - 如包含 `package-info`，可进行二次解析获取更准确的源码位置

3. **利用 nameCache 还原方法名**
   - 查找混淆后方法名对应的所有条目
   - 根据还原后的行号范围匹配正确的源码方法名

### 解析示例

原始堆栈：
```
at i (entry|entry|1.0.0|src/main/ets/pages/Index.ts:71:71)
```

还原后：
```
at callHarFunction (entry/src/main/ets/pages/Index.ets:25:3)
```

## CI/CD 集成

```bash
# 自动化解析脚本示例
hstack \
  -i ./crash-logs \
  -o ./parsed-logs \
  -s ./build/sourcemap \
  --so ./build/libs \
  -n ./build/nameCache
```

## 常见问题

1. **方法名未还原**: 确保同时提供 `-s` 和 `-n` 参数
2. **C++ 堆栈未解析**: 检查 `ADDR2LINE_PATH` 环境变量配置
3. **so 文件无符号表**: 配置 `RelWithDebInfo` 构建选项
