#!/usr/bin/env python
import oauth2 as oauth
import urllib
import sys

tweet_url='https://api.twitter.com/1.1/statuses/update.json'

consumer_key='QMTvGMReNmrkcb7WV9Byg'
consumer_secret='z4n0WeL6yY3LLaqQDelu8HKVOhSGd8a1kzKOhE0n0'
oauth_token=access_token='1719134676-aZMWLt1PJ1vF1gzWR2kcgdOtOSpiNL4VLrpQBJ2'
oauth_token_secret=access_token_secret='dCLZdSRVWdg3WmSCpnsvNIiqpjUq0VUhhSPefdB4'

def oauth_req(url, http_method="GET", post_body=None, http_headers=None):
    consumer = oauth.Consumer(key=consumer_key, secret=consumer_secret)
    token = oauth.Token(key=oauth_token, secret=oauth_token_secret)
    client = oauth.Client(consumer, token)

    resp, content = client.request(
        url,
        method=http_method,
        body="status="+post_body,
        headers=http_headers
    )
    return content

def tweet(msg):
    req = oauth_req(tweet_url, 'POST', msg)
    #print req

if __name__=="__main__":
    msg = ' '.join(sys.argv[1:])
    tweet(msg)

# vim: set noai ts=4 sts=4 et sw=4 ft=python
