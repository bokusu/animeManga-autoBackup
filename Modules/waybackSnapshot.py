from waybackpy import WaybackMachineSaveAPI
import sys
import os
from dotenv import load_dotenv

load_dotenv()

lets = {
  'url': '',
  'ua': ''
}

def main(argv):
  for index, arg in enumerate(argv):
    if arg == "-u" or arg == "--url":
      lets['url'] = argv[index + 1]
    elif arg == "-a" or arg == "--userAgent":
      lets['ua'] = argv[index + 1]
    elif arg == "-h" or arg == "--help":
      print('''Wayback Machine Save API wrapper for animeManga-autoBackup
by @nattadasu

Usage:
  python waybackSnapshot.py --url <URL> --userAgent <User Agent>

Arguments:
  -u, --url
    Set URL to be saved.
  -a, --userAgent
    Set user agent.
  -h, --help
    Show this help message''')
      return

  if lets['ua'] == '':
    lets['ua'] = os.getenv('USER_AGENT')

  snapPages()

def snapPages():
  wb = WaybackMachineSaveAPI
  url = lets['url']
  ua = lets['ua']
  save = wb(url, ua)

  save.save()
  archived = save.archive_url

  # Replace HTML encoded characters like &amp; with their actual characters
  site_string = archived.replace('&amp;', '&')
  print(site_string)

if __name__ == '__main__':
    main(sys.argv)
