import os

dev = dict(
    redis_host='127.0.0.1',
    mysql_host='127.0.0.1',
    mysql_user='root',
    mysql_password=r'KmKatxJFLkL7pkif',
    mysql_database='newbee',
    debug=True,
    order_timeout=5,
    pay_url='http://localhost:9000/order/',
    key_order='xxxxxx',
    secret_key='xxxxxxx',
    autoreload=False,
    rollbar_server_access_token='8b2e26232f564f9ab0a486cfa7288ee8',
    websocket_api_allow_host=['app_servers'],
    usdt_api_endpoint='https://data-center-staging.rubyxgem.com:2087/api/brave_troops/usdt/remits/place_order',
    key_aes='xxxxxkey_aes',
    key_jwt='d971f2b0747f4e648ca74cfc8b934c60',
    api_url='http://zk2.ipay268.cc',
    api_url2='api_url2 xxxxxx',
    agent_url='http://127.0.0.1:8888/HTAdmin/auth/signin/',
    qrcode_release=5,
    recharge=True,  # 抢充值
    withdraw=True,  # 抢提现
    id_token_key='b6e569f25ab342f0b36d2e5532413b7c',
    admin_title='admin_title',
    cookie_key='580627e7a6d547bb83bd8aaa4da4b22b',
    login_url='/grab/auth/',
    merchant_url='merchant_urlxxxxxx',
    listen_port=19999,
)


product = dict(
    redis_host='127.0.0.1',
    mysql_host='127.0.0.1',
    mysql_user='root',
    mysql_password=r'KmKatxJFLkL7pkif',
    mysql_database='newbee',
    debug=False,
    api_url='https://slapi.jsa23.com/api/',
    cookie_key='580627e7a6d547bb83bd8aaa4da4b22b',
    id_token_key='2e05364f510a4dc6a9b760711d8465b4'
)


def get_config():
    env = os.environ.get('RUN_ENV', 'DEV')
    if env == 'DEV':
        return dev
    return product

