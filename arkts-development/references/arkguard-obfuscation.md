# ArkGuard 代码混淆指南

ArkGuard 是 HarmonyOS 官方推荐的代码混淆工具，用于提升应用安全性，防止逆向分析。

## 环境要求

- **DevEco Studio**: 5.0.3.600 及以上版本
- **项目模型**: 仅支持 Stage 模型
- **生效模式**: 仅在 Release 模式下生效

## 开启混淆

在模块的 `build-profile.json5` 中配置：

```json
{
  "arkOptions": {
    "obfuscation": {
      "ruleOptions": {
        "enable": true,
        "files": ["./obfuscation-rules.txt"]
      },
      "consumerFiles": ["./consumer-rules.txt"]
    }
  }
}
```

## 混淆规则配置

在项目根目录创建 `obfuscation-rules.txt`：

```text
# 开启属性混淆
-enable-property-obfuscation

# 开启顶层作用域名称混淆
-enable-toplevel-obfuscation

# 开启文件名混淆
-enable-filename-obfuscation

# 开启导入导出名称混淆
-enable-export-obfuscation
```

## 白名单配置

某些名称不能混淆（如动态属性名、API 字段、数据库字段等）：

```text
# 保留属性名
-keep-property-name apiKey
-keep-property-name userId
-keep-property-name responseData

# 保留全局名称
-keep-global-name AppConfig

# 保留文件名
-keep-file-name MainPage
-keep-file-name LoginPage
```

## 配置文件说明

| 配置文件 | 作用 | 可修改 | 影响范围 |
|---------|------|:------:|---------|
| `obfuscation-rules.txt` | 本模块编译时的混淆规则 | ✓ | 本模块 |
| `consumer-rules.txt` | 本模块被依赖时的混淆规则（建议仅配置保留项） | ✓ | 依赖此模块的模块 |
| `obfuscation.txt` | HAR/HSP 构建产物，自动生成 | ✗ | 依赖模块 |

## 常用混淆选项

| 选项 | 说明 |
|------|------|
| `-enable-property-obfuscation` | 混淆对象属性名 |
| `-enable-toplevel-obfuscation` | 混淆顶层作用域的变量和函数名 |
| `-enable-filename-obfuscation` | 混淆文件名 |
| `-enable-export-obfuscation` | 混淆导入导出的名称 |
| `-disable-obfuscation` | 临时禁用混淆（用于调试） |

## 白名单选项

| 选项 | 说明 |
|------|------|
| `-keep-property-name <name>` | 保留指定属性名不被混淆 |
| `-keep-global-name <name>` | 保留指定全局名称不被混淆 |
| `-keep-file-name <name>` | 保留指定文件名不被混淆 |

## 问题排查

### 排查步骤

1. **确认是否与混淆相关**: 临时添加 `-disable-obfuscation` 禁用混淆，验证问题是否消失
2. **定位问题字段**: 根据崩溃日志定位被混淆的关键字段
3. **添加白名单**: 将问题字段加入 `-keep-property-name` 白名单

### 常见需要保留的场景

- **网络请求**: 接口传参字段名、响应数据字段名
- **数据库操作**: 表字段名
- **系统 API**: 系统回调参数
- **三方库接口**: 三方库要求的字段名

### 示例：网络请求字段保留

```text
# API 请求/响应字段
-keep-property-name code
-keep-property-name message
-keep-property-name data
-keep-property-name token
-keep-property-name userId
```

## 验证混淆效果

1. 切换到 **Release** 模式编译
2. 检查构建产物
3. 使用反编译工具验证类名/方法名/属性名是否已混淆
4. 测试应用功能是否正常

## 参考

- [华为官方文档 - ArkGuard](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-arkguard)
