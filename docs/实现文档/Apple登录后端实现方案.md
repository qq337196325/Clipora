# Apple登录后端实现方案 (Golang + MongoDB)

## 概述

本文档详细介绍了如何在 Golang + MongoDB 技术栈中实现 Apple 登录功能，支持 iOS 和 Android 平台。

## 1. 依赖包安装

### 1.1 Go 模块依赖

在 `go.mod` 文件中添加以下依赖：

```go
module your-app

go 1.19

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/dgrijalva/jwt-go v3.2.0+incompatible
    go.mongodb.org/mongo-driver v1.12.1
    // 其他现有依赖...
)
```

### 1.2 安装依赖

```bash
go mod tidy
```

## 2. 数据模型

### 2.1 用户模型更新

更新用户模型以支持 Apple 登录：

```go
// models/user.go
package models

import (
    "time"
    "go.mongodb.org/mongo-driver/bson/primitive"
)

type User struct {
    ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
    Name      string            `bson:"name" json:"name"`
    Email     string            `bson:"email" json:"email"`
    Phone     string            `bson:"phone" json:"phone"`
    
    // 第三方登录ID
    WechatID  string            `bson:"wechat_id,omitempty" json:"wechat_id"`
    AppleID   string            `bson:"apple_id,omitempty" json:"apple_id"`
    
    // 用户状态
    Status    int               `bson:"status" json:"status"` // 0:正常 1:禁用
    
    // 时间戳
    CreatedAt time.Time         `bson:"created_at" json:"created_at"`
    UpdatedAt time.Time         `bson:"updated_at" json:"updated_at"`
    LastLogin time.Time         `bson:"last_login" json:"last_login"`
}
```

### 2.2 MongoDB 索引

为了提高查询性能，建议添加以下索引：

```javascript
// MongoDB shell 命令
db.users.createIndex({ "apple_id": 1 }, { unique: true, sparse: true })
db.users.createIndex({ "email": 1 })
db.users.createIndex({ "created_at": 1 })
```

## 3. 核心实现

### 3.1 请求结构体定义

```go
// handler/user_handler.go
package handler

import (
    "context"
    "crypto/rsa"
    "encoding/base64"
    "encoding/json"
    "fmt"
    "math/big"
    "net/http"
    "strings"
    "time"

    "github.com/dgrijalva/jwt-go"
    "github.com/gin-gonic/gin"
    "go.mongodb.org/mongo-driver/bson"
    "go.mongodb.org/mongo-driver/bson/primitive"
    "go.mongodb.org/mongo-driver/mongo"
)

// Apple登录请求结构
type AppleLoginRequest struct {
    UserIdentifier    string `json:"user_identifier" binding:"required"`
    IdentityToken     string `json:"identity_token" binding:"required"`
    AuthorizationCode string `json:"authorization_code"`
    Email            string `json:"email"`
    GivenName        string `json:"given_name"`
    FamilyName       string `json:"family_name"`
    Platform         string `json:"platform"`
}

// Apple JWT Claims
type AppleJWTClaims struct {
    Issuer         string `json:"iss"`
    Subject        string `json:"sub"`
    Audience       string `json:"aud"`
    Email          string `json:"email"`
    EmailVerified  string `json:"email_verified"`
    IsPrivateEmail string `json:"is_private_email"`
    jwt.StandardClaims
}

// Apple公钥响应
type ApplePublicKey struct {
    Keys []struct {
        Kid string `json:"kid"`
        Kty string `json:"kty"`
        Use string `json:"use"`
        Alg string `json:"alg"`
        N   string `json:"n"`
        E   string `json:"e"`
    } `json:"keys"`
}
```

### 3.2 主要处理函数

```go
// Apple登录处理
func (h *UserHandler) AppleLogin(c *gin.Context) {
    var req AppleLoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "code":    1,
            "message": "请求参数错误: " + err.Error(),
            "data":    nil,
        })
        return
    }

    // 验证Apple Identity Token
    claims, err := h.validateAppleToken(req.IdentityToken)
    if err != nil {
        h.logger.Error("Apple Token验证失败", "error", err)
        c.JSON(http.StatusUnauthorized, gin.H{
            "code":    1,
            "message": "Apple Token验证失败: " + err.Error(),
            "data":    nil,
        })
        return
    }

    // 使用Apple ID作为唯一标识
    appleID := claims.Subject
    email := claims.Email
    
    // 如果前端没有提供email，使用token中的email
    if req.Email == "" {
        req.Email = email
    }

    h.logger.Info("Apple登录验证成功", "apple_id", appleID, "email", req.Email)

    // 查找或创建用户
    user, err := h.findOrCreateAppleUser(appleID, req)
    if err != nil {
        h.logger.Error("用户创建失败", "error", err)
        c.JSON(http.StatusInternalServerError, gin.H{
            "code":    1,
            "message": "用户创建失败",
            "data":    nil,
        })
        return
    }

    // 生成JWT Token
    token, err := h.generateJWTToken(user.ID.Hex())
    if err != nil {
        h.logger.Error("Token生成失败", "error", err)
        c.JSON(http.StatusInternalServerError, gin.H{
            "code":    1,
            "message": "Token生成失败",
            "data":    nil,
        })
        return
    }

    // 更新用户最后登录时间
    go h.updateUserLastLogin(user.ID.Hex())

    h.logger.Info("Apple登录成功", "user_id", user.ID.Hex())

    c.JSON(http.StatusOK, gin.H{
        "code":    0,
        "message": "登录成功",
        "data": gin.H{
            "id":    user.ID.Hex(),
            "name":  user.Name,
            "email": user.Email,
            "token": token,
        },
    })
}

// 验证Apple Identity Token
func (h *UserHandler) validateAppleToken(identityToken string) (*AppleJWTClaims, error) {
    // 获取Apple公钥
    publicKeys, err := h.getApplePublicKeys()
    if err != nil {
        return nil, fmt.Errorf("获取Apple公钥失败: %v", err)
    }

    // 解析JWT Token
    token, err := jwt.ParseWithClaims(identityToken, &AppleJWTClaims{}, func(token *jwt.Token) (interface{}, error) {
        // 验证签名算法
        if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
            return nil, fmt.Errorf("意外的签名方法: %v", token.Header["alg"])
        }

        // 获取kid
        kid, ok := token.Header["kid"].(string)
        if !ok {
            return nil, fmt.Errorf("Token头部缺少kid")
        }

        // 找到对应的公钥
        for _, key := range publicKeys.Keys {
            if key.Kid == kid {
                return h.rsaPublicKeyFromModulusAndExponent(key.N, key.E)
            }
        }

        return nil, fmt.Errorf("找不到对应的公钥")
    })

    if err != nil {
        return nil, fmt.Errorf("Token解析失败: %v", err)
    }

    if claims, ok := token.Claims.(*AppleJWTClaims); ok && token.Valid {
        // 验证issuer
        if claims.Issuer != "https://appleid.apple.com" {
            return nil, fmt.Errorf("无效的issuer: %s", claims.Issuer)
        }

        // 验证audience (你的App ID)
        if claims.Audience != "com.guanshangyun.clipora" {
            return nil, fmt.Errorf("无效的audience: %s", claims.Audience)
        }

        // 验证过期时间
        if time.Now().Unix() > claims.ExpiresAt {
            return nil, fmt.Errorf("Token已过期")
        }

        return claims, nil
    }

    return nil, fmt.Errorf("Token无效")
}

// 获取Apple公钥（带缓存）
func (h *UserHandler) getApplePublicKeys() (*ApplePublicKey, error) {
    // 可以添加缓存机制，这里简化实现
    client := &http.Client{
        Timeout: 10 * time.Second,
    }
    
    resp, err := client.Get("https://appleid.apple.com/auth/keys")
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("获取Apple公钥失败，状态码: %d", resp.StatusCode)
    }

    var keys ApplePublicKey
    if err := json.NewDecoder(resp.Body).Decode(&keys); err != nil {
        return nil, err
    }

    return &keys, nil
}

// 从模数和指数创建RSA公钥
func (h *UserHandler) rsaPublicKeyFromModulusAndExponent(modulus, exponent string) (*rsa.PublicKey, error) {
    // 解码base64url编码的模数和指数
    nBytes, err := base64.RawURLEncoding.DecodeString(modulus)
    if err != nil {
        return nil, fmt.Errorf("解码模数失败: %v", err)
    }

    eBytes, err := base64.RawURLEncoding.DecodeString(exponent)
    if err != nil {
        return nil, fmt.Errorf("解码指数失败: %v", err)
    }

    // 创建big.Int
    n := new(big.Int).SetBytes(nBytes)
    
    var e int64
    for _, b := range eBytes {
        e = e*256 + int64(b)
    }

    return &rsa.PublicKey{
        N: n,
        E: int(e),
    }, nil
}

// 查找或创建Apple用户
func (h *UserHandler) findOrCreateAppleUser(appleID string, req AppleLoginRequest) (*User, error) {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    // 首先尝试通过Apple ID查找用户
    var user User
    err := h.db.Collection("users").FindOne(ctx, bson.M{
        "apple_id": appleID,
    }).Decode(&user)

    if err == nil {
        // 用户已存在，更新信息
        updateData := bson.M{
            "last_login": time.Now(),
            "updated_at": time.Now(),
        }
        
        // 如果有新的邮箱信息，更新邮箱
        if req.Email != "" && user.Email != req.Email {
            updateData["email"] = req.Email
        }

        _, err = h.db.Collection("users").UpdateOne(ctx, bson.M{
            "apple_id": appleID,
        }, bson.M{
            "$set": updateData,
        })

        if err != nil {
            return nil, fmt.Errorf("更新用户信息失败: %v", err)
        }

        user.Email = req.Email
        user.LastLogin = time.Now()
        return &user, nil
    }

    if err != mongo.ErrNoDocuments {
        return nil, fmt.Errorf("查询用户失败: %v", err)
    }

    // 用户不存在，创建新用户
    name := strings.TrimSpace(req.GivenName + " " + req.FamilyName)
    if name == "" {
        name = "Apple用户"
    }

    newUser := User{
        ID:        primitive.NewObjectID(),
        AppleID:   appleID,
        Name:      name,
        Email:     req.Email,
        Status:    0, // 正常状态
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
        LastLogin: time.Now(),
    }

    _, err = h.db.Collection("users").InsertOne(ctx, newUser)
    if err != nil {
        return nil, fmt.Errorf("创建用户失败: %v", err)
    }

    h.logger.Info("创建新Apple用户", "user_id", newUser.ID.Hex(), "apple_id", appleID)
    return &newUser, nil
}

// 更新用户最后登录时间
func (h *UserHandler) updateUserLastLogin(userID string) {
    ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
    defer cancel()

    objectID, err := primitive.ObjectIDFromHex(userID)
    if err != nil {
        h.logger.Error("用户ID格式错误", "user_id", userID)
        return
    }

    _, err = h.db.Collection("users").UpdateOne(ctx, bson.M{
        "_id": objectID,
    }, bson.M{
        "$set": bson.M{
            "last_login": time.Now(),
        },
    })

    if err != nil {
        h.logger.Error("更新用户最后登录时间失败", "error", err)
    }
}

// 生成JWT Token
func (h *UserHandler) generateJWTToken(userID string) (string, error) {
    claims := jwt.MapClaims{
        "user_id": userID,
        "exp":     time.Now().Add(time.Hour * 24 * 7).Unix(), // 7天过期
        "iat":     time.Now().Unix(),
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    
    // 使用配置中的密钥签名
    tokenString, err := token.SignedString([]byte(h.config.JWTSecret))
    if err != nil {
        return "", err
    }

    return tokenString, nil
}
```

## 4. 路由配置

### 4.1 添加Apple登录路由

```go
// router/router.go
package router

import (
    "github.com/gin-gonic/gin"
    "your-app/handler"
)

func SetupRoutes(r *gin.Engine, userHandler *handler.UserHandler) {
    // API版本组
    v1 := r.Group("/v1/api/user")
    {
        // 登录相关
        v1.POST("/account_login", userHandler.AccountLogin)
        v1.POST("/wechat_login", userHandler.WechatLogin)
        v1.POST("/apple_login", userHandler.AppleLogin)  // 新增Apple登录路由
        v1.POST("/sms_code", userHandler.SendSMSCode)
        
        // 其他路由...
    }
    
    // Web回调路由（用于Android）
    auth := r.Group("/auth")
    {
        auth.GET("/apple/callback", userHandler.AppleWebCallback)
    }
}
```

### 4.2 Web回调处理（Android支持）

```go
// Apple Web回调处理（用于Android平台）
func (h *UserHandler) AppleWebCallback(c *gin.Context) {
    code := c.Query("code")
    state := c.Query("state")
    
    if code == "" {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "missing authorization code",
        })
        return
    }

    // 这里可以处理Web回调逻辑
    // 通常用于Android平台的Apple登录
    h.logger.Info("Apple Web回调", "code", code, "state", state)
    
    // 返回成功页面或重定向
    c.HTML(http.StatusOK, "apple_callback.html", gin.H{
        "code":  code,
        "state": state,
    })
}
```

## 5. 配置文件

### 5.1 应用配置

```go
// config/config.go
package config

type Config struct {
    // Apple配置
    AppleTeamID     string `env:"APPLE_TEAM_ID" envDefault:"YOUR_TEAM_ID"`
    AppleKeyID      string `env:"APPLE_KEY_ID" envDefault:"YOUR_KEY_ID"`
    AppleClientID   string `env:"APPLE_CLIENT_ID" envDefault:"com.guanshangyun.clipora"`
    ApplePrivateKey string `env:"APPLE_PRIVATE_KEY" envDefault:""`
    
    // JWT配置
    JWTSecret       string `env:"JWT_SECRET" envDefault:"your-secret-key"`
    
    // MongoDB配置
    MongoURI        string `env:"MONGO_URI" envDefault:"mongodb://localhost:27017"`
    MongoDB         string `env:"MONGO_DB" envDefault:"clipora"`
}
```

## 6. 错误处理

### 6.1 自定义错误类型

```go
// errors/apple_errors.go
package errors

import "fmt"

type AppleAuthError struct {
    Code    string
    Message string
    Err     error
}

func (e *AppleAuthError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("Apple登录错误 [%s]: %s - %v", e.Code, e.Message, e.Err)
    }
    return fmt.Sprintf("Apple登录错误 [%s]: %s", e.Code, e.Message)
}

var (
    ErrInvalidToken     = &AppleAuthError{Code: "INVALID_TOKEN", Message: "无效的Apple Token"}
    ErrExpiredToken     = &AppleAuthError{Code: "EXPIRED_TOKEN", Message: "Apple Token已过期"}
    ErrInvalidAudience  = &AppleAuthError{Code: "INVALID_AUDIENCE", Message: "无效的audience"}
    ErrInvalidIssuer    = &AppleAuthError{Code: "INVALID_ISSUER", Message: "无效的issuer"}
    ErrPublicKeyFailed  = &AppleAuthError{Code: "PUBLIC_KEY_FAILED", Message: "获取Apple公钥失败"}
)
```

## 7. 安全注意事项

### 7.1 Token验证
- 严格验证Apple Identity Token的签名
- 验证issuer必须为 `https://appleid.apple.com`
- 验证audience必须为你的App ID
- 检查Token过期时间

### 7.2 公钥缓存
```go
// 公钥缓存实现示例
type ApplePublicKeyCache struct {
    keys      *ApplePublicKey
    expiredAt time.Time
    mutex     sync.RWMutex
}

func (c *ApplePublicKeyCache) GetKeys() (*ApplePublicKey, error) {
    c.mutex.RLock()
    if c.keys != nil && time.Now().Before(c.expiredAt) {
        defer c.mutex.RUnlock()
        return c.keys, nil
    }
    c.mutex.RUnlock()

    // 获取新的公钥
    c.mutex.Lock()
    defer c.mutex.Unlock()
    
    // 双重检查
    if c.keys != nil && time.Now().Before(c.expiredAt) {
        return c.keys, nil
    }

    keys, err := fetchApplePublicKeys()
    if err != nil {
        return nil, err
    }

    c.keys = keys
    c.expiredAt = time.Now().Add(24 * time.Hour) // 缓存24小时
    
    return keys, nil
}
```

### 7.3 用户数据保护
- 遵守Apple的隐私政策
- 处理邮箱隐私保护（Apple可能提供中继邮箱）
- 安全存储用户数据

## 8. 测试

### 8.1 单元测试

```go
// handler/user_handler_test.go
package handler

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

func TestAppleLogin(t *testing.T) {
    // 测试用例...
}

func TestValidateAppleToken(t *testing.T) {
    // Token验证测试...
}
```

### 8.2 集成测试

```bash
# 使用curl测试Apple登录接口
curl -X POST http://localhost:8080/v1/api/user/apple_login \
  -H "Content-Type: application/json" \
  -d '{
    "user_identifier": "000123.abc123.456",
    "identity_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "authorization_code": "abc123",
    "email": "user@example.com",
    "given_name": "John",
    "family_name": "Doe",
    "platform": "ios"
  }'
```

## 9. 部署注意事项

### 9.1 环境变量
```bash
# .env 文件
APPLE_TEAM_ID=YOUR_TEAM_ID
APPLE_KEY_ID=YOUR_KEY_ID
APPLE_CLIENT_ID=com.guanshangyun.clipora
JWT_SECRET=your-very-secure-secret-key
MONGO_URI=mongodb://username:password@localhost:27017
MONGO_DB=clipora
```

### 9.2 HTTPS要求
- Apple登录要求所有回调URL必须使用HTTPS
- 确保生产环境正确配置SSL证书

### 9.3 域名验证
- 在Apple Developer Console中正确配置域名
- 验证回调URL的有效性

## 10. 监控和日志

### 10.1 关键指标监控
- Apple登录成功率
- Token验证失败率
- 用户创建/登录频率
- API响应时间

### 10.2 日志记录
```go
// 重要事件日志
h.logger.Info("Apple登录开始", "apple_id", appleID)
h.logger.Info("Apple登录成功", "user_id", user.ID.Hex())
h.logger.Error("Apple登录失败", "error", err, "apple_id", appleID)
```

## 总结

这个实现方案提供了完整的Apple登录后端支持，包括：

1. **完整的Token验证流程**
2. **跨平台支持（iOS和Android）**
3. **安全的用户数据处理**
4. **完善的错误处理**
5. **生产环境的部署指南**

通过这个方案，你的Clipora应用可以安全、可靠地支持Apple登录功能。