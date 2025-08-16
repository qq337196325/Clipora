# WebRTC 服务器诊断指南

## 问题现象

客户端显示"WebRTC连接：连接失败"，可能的原因分析：

## 1. 信令服务器问题

### 检查信令服务器状态

```bash
# 检查服务器是否运行
curl -I http://111.230.32.118:8000/docs

# 检查WebSocket端点
wscat -c ws://111.230.32.118:8000/webrtc/ws/test_user
```

### 信令服务器日志检查

```bash
# 查看服务器日志
tail -f /var/log/webrtc_signaling.log

# 或者如果使用systemd
journalctl -u webrtc-signaling -f
```

### 常见信令服务器问题

1. **端口被占用**
   ```bash
   netstat -tlnp | grep 8000
   ```

2. **防火墙阻止**
   ```bash
   # 开放端口
   ufw allow 8000
   # 或者
   iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
   ```

3. **服务器资源不足**
   ```bash
   htop
   df -h
   ```

## 2. STUN/TURN 服务器问题

### 检查 STUN 服务器

```bash
# 使用 stun 客户端测试
stunclient coturn.clipora.cc 23388

# 或者使用 telnet 测试端口
telnet coturn.clipora.cc 23388
```

### 检查 TURN 服务器

```bash
# 检查 coturn 服务状态
systemctl status coturn

# 查看 coturn 日志
tail -f /var/log/coturn/turn.log

# 测试 TURN 服务器认证
turnutils_uclient -T -u clipora -w clipora123 coturn.clipora.cc -p 23388
```

### TURN 服务器配置检查

检查 `/etc/turnserver.conf` 配置：

```bash
# 基本配置
listening-port=23388
external-ip=YOUR_SERVER_IP
realm=coturn.clipora.cc

# 认证配置
user=clipora:clipora123
lt-cred-mech

# 日志配置
log-file=/var/log/coturn/turn.log
verbose
```

### 常见 STUN/TURN 问题

1. **端口未开放**
   ```bash
   # 开放 STUN/TURN 端口
   ufw allow 23388
   ufw allow 49152:65535/udp  # TURN 数据端口范围
   ```

2. **认证失败**
   - 检查用户名密码是否正确
   - 检查 realm 配置
   - 查看认证日志

3. **网络配置问题**
   - 检查 external-ip 配置
   - 确认服务器有公网IP
   - 检查NAT配置

## 3. 网络连通性问题

### 客户端网络检查

```bash
# 测试到信令服务器的连接
ping 111.230.32.118
telnet 111.230.32.118 8000

# 测试到STUN/TURN服务器的连接
ping coturn.clipora.cc
telnet coturn.clipora.cc 23388
```

### 防火墙和NAT检查

1. **服务器端防火墙**
   ```bash
   # 检查防火墙规则
   iptables -L -n
   ufw status
   ```

2. **客户端网络环境**
   - 检查是否在企业网络内
   - 是否有代理服务器
   - 是否有严格的防火墙规则

## 4. 调试步骤

### 第一步：测试信令服务器

1. 在客户端点击"连接信令服务器"
2. 查看日志是否显示"已连接到信令服务器"
3. 如果失败，检查服务器状态和网络连通性

### 第二步：测试房间功能

1. 连接成功后，点击"加入房间"
2. 在另一台设备上加入同一房间
3. 查看是否能看到对方用户

### 第三步：测试STUN/TURN服务器

1. 点击"测试STUN"按钮
2. 查看日志中是否有"STUN服务器可达"
3. 点击"测试TURN"按钮
4. 查看是否有"TURN服务器可达"

### 第四步：测试WebRTC连接

1. 选择目标用户
2. 点击"建立WebRTC连接"
3. 观察详细的连接日志

## 5. 常见错误和解决方案

### 错误1：信令服务器连接失败
```
错误: 连接信令服务器失败
解决: 
1. 检查服务器是否运行
2. 检查网络连通性
3. 检查防火墙设置
```

### 错误2：ICE收集失败
```
错误: ICE收集状态: failed
解决:
1. 检查STUN服务器配置
2. 检查网络NAT类型
3. 启用TURN服务器
```

### 错误3：TURN认证失败
```
错误: TURN服务器测试超时
解决:
1. 检查用户名密码
2. 检查TURN服务器配置
3. 查看TURN服务器日志
```

### 错误4：WebRTC连接超时
```
错误: WebRTC连接状态: failed
解决:
1. 确保STUN/TURN服务器正常
2. 检查ICE候选者交换
3. 查看详细的连接日志
```

## 6. 服务器端监控

### 创建监控脚本

```bash
#!/bin/bash
# webrtc_monitor.sh

echo "=== WebRTC 服务器状态检查 ==="

# 检查信令服务器
echo "1. 信令服务器状态:"
curl -s -o /dev/null -w "%{http_code}" http://111.230.32.118:8000/docs
echo

# 检查TURN服务器
echo "2. TURN服务器状态:"
systemctl is-active coturn
echo

# 检查端口监听
echo "3. 端口监听状态:"
netstat -tlnp | grep -E "(8000|23388)"
echo

# 检查系统资源
echo "4. 系统资源:"
free -h
df -h /
echo

echo "=== 检查完成 ==="
```

### 设置定期检查

```bash
# 添加到crontab
crontab -e

# 每5分钟检查一次
*/5 * * * * /path/to/webrtc_monitor.sh >> /var/log/webrtc_monitor.log 2>&1
```

## 7. 客户端调试技巧

1. **查看详细日志**
   - 客户端会显示详细的连接过程
   - 注意查看ICE候选者类型
   - 关注连接状态变化

2. **分步测试**
   - 先测试信令服务器连接
   - 再测试STUN/TURN服务器
   - 最后测试WebRTC连接

3. **网络环境测试**
   - 在不同网络环境下测试
   - 使用移动热点测试
   - 测试不同的设备组合

## 8. 推荐的故障排除顺序

1. ✅ 检查信令服务器状态和连通性
2. ✅ 检查STUN服务器可达性
3. ✅ 检查TURN服务器配置和认证
4. ✅ 检查防火墙和端口开放
5. ✅ 检查客户端网络环境
6. ✅ 查看详细的连接日志
7. ✅ 测试不同的网络环境

通过这个系统性的诊断流程，应该能够定位到WebRTC连接失败的具体原因。