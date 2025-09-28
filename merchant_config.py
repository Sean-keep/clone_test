# ../api_config.py
import os

dev = dict(
    redis_host='127.0.0.1',
    mysql_host='127.0.0.1',
    mysql_user='root',
    mysql_password='KmKatxJFLkL7pkif',
    mysql_database='newbee',
    listen_port=16666,
    login_url='/Merchant/auth/signin/',
    debug=True,
    merchant_url='',
    api_url='http://localhost:16666',
    api_url2='http://127.0.0.1:16666',
    cookie_key='580627e7a6d547bb83bd8aaa4da4b22b',
    key_aes='cc2d9ce856204e24878e6ebff54e07a6',
    key_jwt='d971f2b0747f4e648ca74cfc8b934c60',
    key_order='f07bf6948f6846ae911df0cbe73c8af7',
    # agent_url='http://127.0.0.1:19999/HTAgent/auth/signin/portal/',
    order_timeout=5,
    qrcode_release=5,
    recharge=True,  # 抢充值
    withdraw=True,  # 抢提现
    id_token_key='b6e569f25ab342f0b36d2e5532413b7c',
    admin_title='admin_title',
)

product = dict(
    redis_host='127.0.0.1',
    mysql_host='localhost',
    mysql_user='root',
    mysql_password='KmKatxJFLkL7pkif',
    mysql_database='newbee',
    listen_port=6666,
    login_url='/grab/auth/',
    debug=False,
    merchant_url='',
    # api_url='http://192.168.8.103:8888',
    # api_url='http://wopay.natapp4.cc',
    api_url='http://127.0.0.1:8888', # 订单页域名
    api_url2='http://127.0.0.1:8888',
    cookie_key='96362f1573ec45249e520521c6abe345',
    key_aes='8e1e367ad6ac41f085696557d82cf367',
    key_jwt='3e1c4877f55a4e9c84e5783fc025ed59',
    key_order='40c84be7730a411ab3c83bd11585e6d7',
    order_timeout=10,
    qrcode_release=10,
    recharge=False,
    withdraw=False,
    agent_url='http://127.0.0.1:19999/HTAgent/auth/signin/portal/',
    id_token_key='b6e569f25ab342f0b36d2e5532413b7c'
)


def get_config():
    env = os.environ.get('RUN_ENV', 'DEV')
    if env == 'DEV':
        return dev
    return product

