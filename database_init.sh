#!/bin/bash
# Keylol Flutter 数据库初始化脚本
# 用于初始化 SQLite 数据库表结构

echo "=========================================="
echo "Keylol Flutter 数据库初始化脚本"
echo "=========================================="
echo ""

# 数据库版本
DB_VERSION=1

# 浏览历史表 DDL
HISTORY_DDL="
CREATE TABLE history (
  tid TEXT PRIMARY KEY,
  fid TEXT,
  author_id TEXT,
  author TEXT,
  subject TEXT,
  dateline TEXT,
  date TEXT
);"

# 收藏表 DDL
FAVORITE_DDL="
CREATE TABLE favorite (
  fav_id TEXT PRIMARY KEY,
  uid TEXT,
  id TEXT,
  id_type TEXT,
  space_uid TEXT,
  title TEXT,
  description TEXT,
  dateline TEXT,
  icon TEXT,
  url TEXT,
  author TEXT
);"

echo "数据库版本: $DB_VERSION"
echo ""

echo "表结构说明:"
echo "1. history - 浏览历史记录表"
echo "   - tid: 帖子ID (主键)"
echo "   - fid: 版块ID"
echo "   - author_id: 作者ID"
echo "   - author: 作者名称"
echo "   - subject: 帖子标题"
echo "   - dateline: 发帖时间"
echo "   - date: 浏览时间"
echo ""

echo "2. favorite - 收藏帖子表"
echo "   - fav_id: 收藏ID (主键)"
echo "   - uid: 用户ID"
echo "   - id: 帖子ID"
echo "   - id_type: 类型"
echo "   - space_uid: 空间用户ID"
echo "   - title: 标题"
echo "   - description: 描述"
echo "   - dateline: 收藏时间"
echo "   - icon: 图标"
echo "   - url: 链接"
echo "   - author: 作者"
echo ""

echo "=========================================="
echo "初始化 SQL 语句"
echo "=========================================="
echo ""

echo "-- 浏览历史表"
echo "$HISTORY_DDL"
echo ""

echo "-- 收藏帖子表"
echo "$FAVORITE_DDL"
echo ""

echo "=========================================="
echo "初始化完成"
echo "=========================================="
echo ""
echo "提示: 在 Flutter 应用中,这些 DDL 会自动执行"
echo "位置: lib/repository/database_service.dart"
echo ""
echo "Web 平台使用内存数据库 (数据不持久化)"
echo "移动平台使用文件数据库 (数据持久化)"
