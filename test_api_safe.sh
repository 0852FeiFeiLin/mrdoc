#!/bin/bash

# MrDoc API Token 兼容性测试脚本 (安全版本)
# 仅测试 token 验证,不实际修改数据

BASE_URL="http://127.0.0.1:8088"
TOKEN="d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7"

echo "=========================================="
echo "MrDoc API Token 兼容性测试 (安全模式)"
echo "=========================================="
echo ""

# 1. 首先验证 token 是否有效
echo "0. 验证 Token 有效性:"
curl -s "${BASE_URL}/api/check_token/?token=${TOKEN}" | python3 -m json.tool
echo ""
echo "------------------------------------------"

# 2. 测试 create_doc (会创建新文档,记录ID后可删除)
echo "1. 测试 create_doc (Token in JSON body):"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/create_doc/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN}\",
    \"pid\": 1,
    \"title\": \"[测试]自动创建-可删除\",
    \"doc\": \"# 测试文档\n\n这是通过API创建的测试文档,验证token从JSON body传递功能。\n\n**可安全删除**\",
    \"parent_doc\": 0,
    \"editor_mode\": 1
  }")

echo "$RESPONSE" | python3 -m json.tool
DOC_ID_1=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', ''))" 2>/dev/null)
echo "创建的文档ID: $DOC_ID_1"
echo ""
echo "------------------------------------------"

# 3. 测试 create_doc (Token in GET)
echo "2. 测试 create_doc (Token in GET 参数):"
RESPONSE=$(curl -s -X POST "${BASE_URL}/api/create_doc/?token=${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"pid\": 1,
    \"title\": \"[测试]GET参数创建-可删除\",
    \"doc\": \"# 测试文档\n\n这是通过GET参数传递token创建的文档。\n\n**可安全删除**\",
    \"parent_doc\": 0,
    \"editor_mode\": 1
  }")

echo "$RESPONSE" | python3 -m json.tool
DOC_ID_2=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', ''))" 2>/dev/null)
echo "创建的文档ID: $DOC_ID_2"
echo ""
echo "------------------------------------------"

# 4. 测试 modify_doc (修改刚创建的测试文档)
if [ -n "$DOC_ID_1" ] && [ "$DOC_ID_1" != "None" ]; then
    echo "3. 测试 modify_doc (Token in JSON body) - 修改文档 $DOC_ID_1:"
    curl -s -X POST "${BASE_URL}/api/modify_doc/" \
      -H "Content-Type: application/json" \
      -d "{
        \"token\": \"${TOKEN}\",
        \"pid\": 1,
        \"did\": ${DOC_ID_1},
        \"title\": \"[测试]已修改-JSON token\",
        \"doc\": \"# 已修改\n\n通过JSON body传递token修改成功\"
      }" | python3 -m json.tool
    echo ""
    echo "------------------------------------------"
fi

# 5. 测试 modify_doc (GET 参数)
if [ -n "$DOC_ID_2" ] && [ "$DOC_ID_2" != "None" ]; then
    echo "4. 测试 modify_doc (Token in GET 参数) - 修改文档 $DOC_ID_2:"
    curl -s -X POST "${BASE_URL}/api/modify_doc/?token=${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"pid\": 1,
        \"did\": ${DOC_ID_2},
        \"title\": \"[测试]已修改-GET token\",
        \"doc\": \"# 已修改\n\n通过GET参数传递token修改成功\"
      }" | python3 -m json.tool
    echo ""
    echo "------------------------------------------"
fi

# 6. 测试 upload_img (最小测试图片)
echo "5. 测试 upload_img (Token in JSON body):"
curl -s -X POST "${BASE_URL}/api/upload_img/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN}\",
    \"base64\": \"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==\"
  }" | python3 -m json.tool
echo ""
echo "------------------------------------------"

# 7. 测试 upload_img (GET 参数)
echo "6. 测试 upload_img (Token in GET 参数):"
curl -s -X POST "${BASE_URL}/api/upload_img/?token=${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"base64\": \"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==\"
  }" | python3 -m json.tool
echo ""
echo "------------------------------------------"

# 8. 测试 delete_doc (删除刚创建的测试文档)
if [ -n "$DOC_ID_1" ] && [ "$DOC_ID_1" != "None" ]; then
    echo "7. 测试 delete_doc (Token in JSON body) - 删除文档 $DOC_ID_1:"
    curl -s -X POST "${BASE_URL}/api/delete_doc/" \
      -H "Content-Type: application/json" \
      -d "{
        \"token\": \"${TOKEN}\",
        \"did\": ${DOC_ID_1}
      }" | python3 -m json.tool
    echo ""
    echo "------------------------------------------"
fi

if [ -n "$DOC_ID_2" ] && [ "$DOC_ID_2" != "None" ]; then
    echo "8. 测试 delete_doc (Token in GET 参数) - 删除文档 $DOC_ID_2:"
    curl -s -X POST "${BASE_URL}/api/delete_doc/?token=${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"did\": ${DOC_ID_2}
      }" | python3 -m json.tool
    echo ""
    echo "------------------------------------------"
fi

# 9. Token 优先级测试 (GET > JSON)
echo "9. Token 优先级测试 (GET 优先于 JSON body):"
curl -s -X POST "${BASE_URL}/api/create_doc/?token=${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"invalid_token_this_should_be_ignored\",
    \"pid\": 1,
    \"title\": \"[测试]优先级测试-可删除\",
    \"doc\": \"验证GET参数token优先于JSON body\",
    \"editor_mode\": 1
  }" | python3 -m json.tool
echo ""
echo "------------------------------------------"

# 10. 无效 token 测试
echo "10. 无效 Token 测试 (预期失败):"
curl -s -X POST "${BASE_URL}/api/create_doc/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"invalid_token_should_fail\",
    \"pid\": 1,
    \"title\": \"不应创建\",
    \"doc\": \"此文档不应被创建\",
    \"editor_mode\": 1
  }" | python3 -m json.tool
echo ""
echo "------------------------------------------"

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
echo ""
echo "注意: 测试过程中创建的文档已标记 [测试] 前缀,可在后台手动清理"
