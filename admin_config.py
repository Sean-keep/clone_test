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
    key_aes='xxxxxx',
    key_jwt='xxxxxx',
    qrcode_release='xxxxxx',
    recharge='xxxxxx',
    withdraw='xxxxxx',
    secret_key='xxxxxxx',
    api_url='xxxxxxx',
    api_url2='xxxxxxx',
    agent_url='xxxxxxx',
    id_token_key='xxxxxxx',
    cookie_key='xxxxxxx',
    login_url='xxxxxxx',
    merchant_url='xxxxxxx',
    mi_url='xxxxxxx',
    admin_title='admin_titlexxxxxxx',
    path_allow='path_allowxxxxxxx',
    listen_port=9999,
    autoreload=False,
    rollbar_server_access_token='8b2e26232f564f9ab0a486cfa7288ee8',
    websocket_api_allow_host=['app_servers'],
    usdt_api_endpoint='https://data-center-staging.rubyxgem.com:2087/api/brave_troops/usdt/remits/place_order',
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

