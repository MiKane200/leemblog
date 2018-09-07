1. -H/--header <header>
2. -d/--data <data>
3. -X/--request <command>

e.g
curl -X POST  \
--header 'Content-Type: application/json' \
--header 'Accept: application/json'  \
--header 'appkey:key'  \
--header 'appsign=sign'  \
--header 'signmethod:md5'  \
--header 'deviceType:1'  \
--header 'deviceId:1'  \
-d '{"city":"shanghai","country":"China","headimg":"https://1.com/1.png","nick":"123","openid":"xxxxx","province":"Shanghai","sex":1,"unionid":"om-xxxxxx"}' \
'https://chaojihao.net/user/transfer'