# TopTodo

TopTodo 是一个轻量的 macOS 顶部待办应用：主窗口用来管理计划，菜单栏小窗用来快速查看和勾选今天的任务。

这个项目适合想要一个“打开就看到今天要做什么”的桌面工具的人。它不是复杂的项目管理系统，而是一个偏轻量、偏日常、偏执行导向的计划面板。

## 功能

- 主窗口查看指定日期的计划
- 支持一次性、每天、工作日、自定义星期重复
- 勾选当天完成状态
- 自动统计周/月完成进展
- 菜单栏小窗快速查看今天待办
- 主窗口支持背景图、背景遮罩透明度、浅色/深色/跟随系统
- 菜单栏小窗支持单独更换背景图

## 技术栈

- Swift
- SwiftUI
- Swift Package Manager
- macOS 14+

## 项目结构

```text
App/        应用入口
Models/     计划、重复规则、外观偏好等数据模型
Stores/     持久化与状态管理
Support/    主题、格式化、图片选择、日期辅助
Views/      主窗口、菜单栏面板、表单与行组件
script/     构建、启动、安装脚本
```

## 本地运行

直接运行：

```bash
/Users/???/Documents/TopToDo/TopTodo.command
```

或者在项目目录执行：

```bash
./script/build_and_run.sh
```

## 安装到应用程序目录

```bash
/Users/???/Documents/TopToDo/安装\ TopTodo.command
```

脚本会自动构建 `TopTodo.app`，并安装到：

- `/Applications/TopTodo.app`
- 如果没有写权限，则安装到 `~/Applications/TopTodo.app`

## 开发说明

- 数据保存在用户的 `Application Support/TopTodo` 目录下
- 菜单栏与主窗口共用同一份计划数据
- 构建脚本对 SwiftPM 的缓存异常做了自动重试处理，尽量减少 `unknown build description` 这类问题

## 后续可以继续做的方向

- 计划编辑与修改
- 任务排序和分组
- iCloud / 导出导入
- 自定义提醒
- 更多背景显示模式

## License

MIT license 人人几乎都能用，包括商用；只要保留原作者版权声明。
