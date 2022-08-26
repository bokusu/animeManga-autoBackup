#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# cSpell:ignore ANIDB dotenv mylist acnt

from bs4 import BeautifulSoup
from datetime import datetime
from dotenv import load_dotenv
import json
import os
import requests

load_dotenv()

aniDB_Uid = os.environ.get("ANIDB_UID")
aniDb_homepage = "https://anidb.net/user/" + aniDB_Uid
aniDb_myList = aniDb_homepage + "/mylist"

userAgent = os.environ.get("USER_AGENT")

hReq = requests.get(aniDb_homepage, headers={"User-Agent": userAgent})
soup = BeautifulSoup(hReq.text, features="html.parser")

get_animeCount = soup.find("tr", {"class": "acnt"})
grab_number = get_animeCount.find("td", {"class": "value"}).text
countPerPage = int(grab_number) // 30           # 30 is the number of anime per page

pagesToFetch = countPerPage - 1

# animeList = []

# for i in range(pagesToFetch):
#     for anime in lists:
#         animeList.append(anime)