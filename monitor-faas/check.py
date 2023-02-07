import requests

# import creds.py



spark_html = requests.get(spark_master_url,
                          auth=(spark_master_username, spark_master_password))

print(spark_html.text)
print(spark_html.status_code)

# <li><strong>Alive Workers:</strong> 1</li>
# <li><strong>Cores in use:</strong> 4 Total, 0 Used</li>
#<li><strong>Memory in use:</strong>
# 6.8 GiB Total,
# 0.0 B Used</li>

print("posting message:")

# curl -d "text=Hi I am a bot that can post messages to any public channel."
# -d "channel=C123456"
# -H "Authorization: Bearer xoxb-not-a-real-token-this-will-not-work"
# -X POST https://slack.com/api/chat.postMessage


# use the 'headers' parameter to set the HTTP headers:
post_message_resp = requests.post('https://slack.com/api/chat.postMessage',
                  data={
                      'text': 'hej',
                      'channel': 'spark-cluster-status'
                  },
                  headers={"Authorization": "Bearer " + slack_token})
print(post_message_resp.text)

# the 'demopage.asp' prints all HTTP Headers

