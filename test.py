import requests
import socks
import socket
import time

# 要测试的 SOCKS5 代理列表
proxies = [
    "14ab0e453de6e:8fa42bdeaa@5.45.39.19:12324",
    "14a1a217fdd5b:00f5b35c4a@67.210.127.146:12324",
    "14ab0e453de6e:8fa42bdeaa@216.97.237.16:12324",
    "14a1a217fdd5b:00f5b35c4a@45.147.152.83:12324",
    "14a1a217fdd5b:00f5b35c4a@104.234.111.152:12324",
    "14ab0e453de6e:8fa42bdeaa@209.200.248.43:12324",
    "14ab0e453de6e:8fa42bdeaa@216.227.222.8:12324",
    "14ab0e453de6e:8fa42bdeaa@67.210.127.175:12324",
    "14a1a217fdd5b:00f5b35c4a@209.200.249.162:12324",
    "14a1a217fdd5b:00f5b35c4a@104.234.71.93:12324"
]

def test_proxy(proxy):
    try:
        # 分解代理字符串
        user_pass, host_port = proxy.split('@')
        username, password = user_pass.split(':')
        host, port = host_port.split(':')

        # 设置 SOCKS5 代理
        socks.set_default_proxy(socks.SOCKS5, host, int(port), True, username, password)
        socket.socket = socks.socksocket

        # 发出 HTTP 请求
        response = requests.get("https://httpbin.org/ip", timeout=10)
        print(f"[✅] Proxy {proxy} OK | Your IP: {response.json().get('origin')}")
    except Exception as e:
        print(f"[❌] Proxy {proxy} failed | Error: {e}")

def reset_socket():
    # 清除 SOCKS5 设置，防止污染后续连接
    socket.socket = socket._socketobject if hasattr(socket, "_socketobject") else socket.create_connection

if __name__ == "__main__":
    print("开始测试 SOCKS5 代理...\n")
    for proxy in proxies:
        test_proxy(proxy)
        reset_socket()
        time.sleep(1)  # 可选：避免请求过快导致 IP 被暂时封锁
