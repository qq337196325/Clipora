# WebRTC 连接失败快速诊断清单

## 🚨 问题现象
- WebRTC连接状态显示"连接失败"
- 无法建立点对点连接

## ✅ 快速检查清单

### 1. 客户端检查（2分钟）

- [ ] **信令服务器连接**
  - 点击"连接信令服务器"
  - 状态是否显示"已连接"？
  - 如果失败，检查网络连接

- [ ] **房间功能测试**
  - 能否成功加入房间？
  - 能否看到其他用户？
  - 两台设备是否在同一房间？

- [ ] **STUN服务器测试**
  - 点击"测试STUN"按钮
  - 是否显示"STUN服务器可达"？
  - 超时时间：5秒

- [ ] **TURN服务器测试**
  - 点击"测试TURN"按钮
  - 是否显示"TURN服务器可达"？
  - 超时时间：8秒

### 2. 服务器端检查（5分钟）

- [ ] **信令服务器状态**
  ```bash
  curl -I http://111.230.32.118:8000/docs
  # 期望返回: HTTP/1.1 200 OK
  ```

- [ ] **STUN服务器测试**
  ```bash
  telnet coturn.clipora.cc 23388
  # 期望: 连接成功
  ```

- [ ] **TURN服务器状态**
  ```bash
  systemctl status coturn
  # 期望: active (running)
  ```

- [ ] **端口开放检查**
  ```bash
  netstat -tlnp | grep -E "(8000|23388)"
  # 期望: 看到监听端口
  ```

### 3. 网络环境检查（3分钟）

- [ ] **基础连通性**
  ```bash
  ping 111.230.32.118
  ping coturn.clipora.cc
  ```

- [ ] **防火墙检查**
  - 服务器防火墙是否开放8000和23388端口？
  - 客户端网络是否有限制？

- [ ] **NAT类型检查**
  - 是否在企业网络内？
  - 是否使用了代理服务器？

## 🔍 常见问题和解决方案

### 问题1: STUN测试超时
```
现象: 点击"测试STUN"后显示超时
原因: STUN服务器不可达
解决: 
1. 检查 coturn.clipora.cc 是否可ping通
2. 检查23388端口是否开放
3. 检查coturn服务是否运行
```

### 问题2: TURN测试失败
```
现象: 点击"测试TURN"后无relay候选者
原因: TURN服务器认证失败或配置错误
解决:
1. 检查用户名密码: clipora/clipora123
2. 查看coturn日志: tail -f /var/log/coturn/turn.log
3. 检查turnserver.conf配置
```

### 问题3: 信令服务器连接失败
```
现象: 无法连接到信令服务器
原因: 服务器未运行或网络不通
解决:
1. 检查服务器状态: systemctl status webrtc-signaling
2. 检查端口监听: netstat -tlnp | grep 8000
3. 检查防火墙: ufw status
```

### 问题4: ICE候选者收集失败
```
现象: 日志显示ICE收集状态为failed
原因: 无法收集到有效的网络候选者
解决:
1. 确保STUN/TURN服务器正常
2. 检查网络NAT类型
3. 尝试使用不同的网络环境
```

## 🛠️ 服务器端快速修复

### 重启信令服务器
```bash
# 如果使用systemd
systemctl restart webrtc-signaling

# 如果使用直接运行
pkill -f "uvicorn app.main:app"
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
```

### 重启TURN服务器
```bash
systemctl restart coturn
systemctl status coturn
```

### 检查日志
```bash
# 信令服务器日志
journalctl -u webrtc-signaling -f

# TURN服务器日志
tail -f /var/log/coturn/turn.log
```

## 📊 诊断结果判断

### ✅ 正常情况
- 信令服务器连接成功
- STUN测试显示"服务器可达"
- TURN测试显示"收到relay候选者"
- WebRTC连接状态为"已连接"

### ❌ 异常情况
- 任何一个测试失败
- 连接状态显示"失败"
- 日志中有错误信息

## 🎯 优先级排查顺序

1. **高优先级**: 信令服务器连接
2. **中优先级**: STUN服务器测试
3. **中优先级**: TURN服务器测试
4. **低优先级**: 网络环境优化

## 📞 获取技术支持

如果按照清单检查后问题仍然存在，请提供：

1. **客户端日志截图**（包含完整的连接过程）
2. **服务器状态信息**
   ```bash
   systemctl status coturn
   systemctl status webrtc-signaling
   netstat -tlnp | grep -E "(8000|23388)"
   ```
3. **网络环境描述**
   - 客户端网络类型（WiFi/移动网络/企业网络）
   - 是否使用代理
   - 防火墙配置

---

**预计诊断时间**: 10-15分钟  
**成功率**: 90%以上的问题可通过此清单解决