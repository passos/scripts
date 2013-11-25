#!/usr/bin/env python
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.keys import Keys
import time
import sys

# read the optus account from file
account_file=sys.argv[1]
f=open(account_file, 'r')
try:
    lines=f.readlines()
    username=lines[0].strip()
    password=lines[1].strip()
finally:
    f.close()

# get the optus traffic information
try:
    browser = webdriver.Firefox() 
    browser.get("https://www.optus.com.au/customercentre/myaccountlogin")
    assert "My Account" in browser.title

    browser.find_element_by_name("j_username").send_keys(username)
    browser.find_element_by_name("j_password").send_keys(password + Keys.RETURN)
    time.sleep(3)
    assert "My services" in browser.title

    try:
       status = browser.find_element_by_xpath("//p[@class='remainStatus']").text
       #total = browser.find_element_by_xpath("//div[@class='total']").text
       #remain = browser.find_element_by_xpath("//div[@class='remaining']").text
    except NoSuchElementException as e:
       assert 0, "load page error: " + str(e)
       exit(0)

    print status
    #print "remain:%s total:%s" % (remain, total)
finally:
    browser.close()
    browser.quit()

