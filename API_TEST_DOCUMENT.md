# MrDoc API Token 兼容性测试文档

## 测试概述

测试目标:验证修复后的 API 接口支持从 JSON body 中获取 token,同时保持对 GET 参数的向后兼容性。

**测试环境**:
- 本地开发环境: http://127.0.0.1:8088
- Token: `d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7`
- 测试项目ID: 1
- 测试文档ID: 10

**修复的接口**:
1. `modify_doc` - 修改文档
2. `create_doc` - 创建文档
3. `upload_img` - 上传图片
4. `delete_doc` - 删除文档

---

## 测试用例设计

每个接口需要测试 3 种场景:

### 场景 1: Token 仅在 GET 参数中 (向后兼容)
```
GET /api/xxx?token=xxx
Content-Type: application/json
Body: {...}
```

### 场景 2: Token 仅在 JSON body 中 (新功能)
```
POST /api/xxx
Content-Type: application/json
Body: {"token": "xxx", ...}
```

### 场景 3: Token 同时在 GET 和 JSON body 中 (优先 GET)
```
POST /api/xxx?token=valid_token
Content-Type: application/json
Body: {"token": "invalid_token", ...}
```
**预期**: 应使用 GET 参数中的 valid_token

---

## 测试脚本

### 1. modify_doc 接口测试

#### 场景 1: Token 在 GET 参数
```bash
curl -X POST "http://127.0.0.1:8088/api/modify_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "pid": 1,
    "did": 10,
    "title": "测试标题-GET参数",
    "doc": "测试内容-通过GET参数传递token"
  }'
```

#### 场景 2: Token 在 JSON body
```bash
curl -X POST "http://127.0.0.1:8088/api/modify_doc/" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7",
    "pid": 1,
    "did": 10,
    "title": "测试标题-JSON body",
    "doc": "测试内容-通过JSON body传递token"
  }'
```

#### 场景 3: Token 优先级测试 (GET > JSON)
```bash
curl -X POST "http://127.0.0.1:8088/api/modify_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "invalid_token_should_be_ignored",
    "pid": 1,
    "did": 10,
    "title": "测试标题-优先级",
    "doc": "测试内容-验证GET参数优先级"
  }'
```

---

### 2. create_doc 接口测试

#### 场景 1: Token 在 GET 参数
```bash
curl -X POST "http://127.0.0.1:8088/api/create_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "pid": 1,
    "title": "新建文档-GET参数",
    "doc": "文档内容-通过GET参数传递token",
    "parent_doc": 0,
    "editor_mode": 1
  }'
```

#### 场景 2: Token 在 JSON body
```bash
curl -X POST "http://127.0.0.1:8088/api/create_doc/" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7",
    "pid": 1,
    "title": "新建文档-JSON body",
    "doc": "文档内容-通过JSON body传递token",
    "parent_doc": 0,
    "editor_mode": 1
  }'
```

#### 场景 3: Token 优先级测试
```bash
curl -X POST "http://127.0.0.1:8088/api/create_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "invalid_token_should_be_ignored",
    "pid": 1,
    "title": "新建文档-优先级",
    "doc": "文档内容-验证GET参数优先级",
    "parent_doc": 0,
    "editor_mode": 1
  }'
```

---

### 3. upload_img 接口测试

#### 场景 1: Token 在 GET 参数 (Base64图片)
```bash
curl -X POST "http://127.0.0.1:8088/api/upload_img/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "base64": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
  }'
```

#### 场景 2: Token 在 JSON body (Base64图片)
```bash
curl -X POST "http://127.0.0.1:8088/api/upload_img/" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7",
    "base64": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
  }'
```

#### 场景 3: Token 优先级测试
```bash
curl -X POST "http://127.0.0.1:8088/api/upload_img/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "invalid_token_should_be_ignored",
    "base64": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
  }'
```

---

### 4. delete_doc 接口测试

#### 场景 1: Token 在 GET 参数
```bash
curl -X POST "http://127.0.0.1:8088/api/delete_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "did": 100
  }'
```

#### 场景 2: Token 在 JSON body
```bash
curl -X POST "http://127.0.0.1:8088/api/delete_doc/" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7",
    "did": 101
  }'
```

#### 场景 3: Token 优先级测试
```bash
curl -X POST "http://127.0.0.1:8088/api/delete_doc/?token=d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "invalid_token_should_be_ignored",
    "did": 102
  }'
```

---

## 预期结果

### 成功响应
```json
{
  "status": true,
  "data": "ok"  // 或具体的返回数据
}
```

### 失败响应 (Token无效)
```json
{
  "status": false,
  "data": "token无效"
}
```

---

## 验证检查清单

对于每个接口,验证以下内容:

- [ ] **场景1**: GET 参数中的 token 能够正常工作
- [ ] **场景2**: JSON body 中的 token 能够正常工作
- [ ] **场景3**: GET 参数优先于 JSON body
- [ ] **错误处理**: 无效 token 返回正确的错误信息
- [ ] **向后兼容**: 原有调用方式不受影响

---

## 测试注意事项

1. **文档ID准备**: 测试前需要确保文档 ID 存在
2. **创建文档测试**: 每次执行会创建新文档,注意数据库清理
3. **删除文档测试**: 使用不存在的文档ID,避免误删重要数据
4. **图片上传测试**: 使用最小的 Base64 编码测试图片 (1x1像素)
5. **权限验证**: 确保 token 对应的用户拥有相应的操作权限

---

## 快速测试脚本

创建一键测试脚本 `test_api.sh`:

```bash
#!/bin/bash

BASE_URL="http://127.0.0.1:8088"
TOKEN="d663d4b17445e7d58417791506b5c6dce04773e8625c8563930449f7"

echo "=========================================="
echo "MrDoc API Token 兼容性测试"
echo "=========================================="
echo ""

# 测试 modify_doc - JSON body 方式
echo "1. 测试 modify_doc (Token in JSON body):"
curl -s -X POST "${BASE_URL}/api/modify_doc/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN}\",
    \"pid\": 1,
    \"did\": 10,
    \"title\": \"测试修改-JSON\",
    \"doc\": \"测试内容\"
  }" | python3 -m json.tool
echo ""

# 测试 create_doc - JSON body 方式
echo "2. 测试 create_doc (Token in JSON body):"
curl -s -X POST "${BASE_URL}/api/create_doc/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN}\",
    \"pid\": 1,
    \"title\": \"新建测试文档\",
    \"doc\": \"测试内容\",
    \"editor_mode\": 1
  }" | python3 -m json.tool
echo ""

# 测试 upload_img - JSON body 方式
echo "3. 测试 upload_img (Token in JSON body):"
curl -s -X POST "${BASE_URL}/api/upload_img/" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"${TOKEN}\",
    \"base64\": \"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=\"
  }" | python3 -m json.tool
echo ""

# 测试 check_token
echo "4. 测试 check_token (验证token有效性):"
curl -s "${BASE_URL}/api/check_token/?token=${TOKEN}" | python3 -m json.tool
echo ""

echo "=========================================="
echo "测试完成"
echo "=========================================="
```

保存后执行:
```bash
chmod +x test_api.sh
./test_api.sh
```

---

## 回归测试

确保修改不影响其他接口:

### 读操作接口 (应继续正常工作)
```bash
# get_doc
curl "http://127.0.0.1:8088/api/get_doc/?token=${TOKEN}&did=10"

# get_docs
curl "http://127.0.0.1:8088/api/get_docs/?token=${TOKEN}&pid=1"

# get_projects
curl "http://127.0.0.1:8088/api/get_projects/?token=${TOKEN}"

# get_level_docs
curl "http://127.0.0.1:8088/api/get_level_docs/?token=${TOKEN}&pid=1"
```

---

## 部署前检查清单

- [ ] 所有本地测试通过
- [ ] 向后兼容性验证通过
- [ ] Token 优先级逻辑正确
- [ ] 错误处理测试通过
- [ ] 代码审查完成
- [ ] 用户验收测试通过
- [ ] 准备回滚方案

---

## 附录: 修复说明

### 修复前的问题
```python
# 只能从 GET 参数获取 token
token = request.GET.get('token', '')
if 'json' in content_type:
    json_data = json.loads(request.body)
    # token 未从 json_data 中提取
```

### 修复后的实现
```python
# 优先从 GET 参数获取,如果为空则从 JSON body 获取
token = request.GET.get('token', '')
if 'json' in content_type:
    json_data = json.loads(request.body)
    if not token:  # GET 参数为空时才使用 JSON body
        token = json_data.get('token', '')
```

### 兼容性保证
- ✅ 原有的 GET 参数调用方式 100% 兼容
- ✅ 新增 JSON body token 支持
- ✅ GET 参数优先级高于 JSON body
- ✅ 无破坏性变更
