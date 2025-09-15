#!/usr/bin/env python3

import os
import sys
import time
import math
import socket
import threading
import requests, feedparser

from datetime import datetime
from collections import defaultdict
from urllib.parse import urlparse

# constants

TITLE = "{user}@{hostname} :: tilekitty"

SCROLL_WIDTH = 64
SCROLL_INTERVAL = 0.18
SCROLL_SEPARATOR = " :: "
SCROLL_RENDER = 3

MAX_ENTRIES = 8
MIN_ENTRIES = 2

FETCH_INTERVAL = 900  # in seconds. default: 900 (15 min)

# variables

visible_entries = []
active_entries = []
queued_entries = []

feeds_parsed = False
splash_title = None

# main

def main():
    global SCROLL_INTERVAL, SCROLL_RENDER
    global visible_entries, active_entries

    log(":: RSS TICKER STARTED ::")

    splash()
    time.sleep(4)

    fetch_thread = threading.Thread(target=periodic_fetch, daemon=True)
    fetch_thread.start()
    while True:
        if len(visible_entries) > 0:
            run_ticker()
        elif len(active_entries) > 0:
            visible_entries = active_entries[:SCROLL_RENDER]
            update_line()
        elif feeds_parsed:
            splash()
        time.sleep(SCROLL_INTERVAL)

def splash():
    global TITLE, SCROLL_WIDTH, splash_title
    if splash_title is None:
        splash_title = TITLE.replace("{user}", os.getenv("USER")).replace("{hostname}", os.uname().nodename)
    print(splash_title, flush=True)

# ticker

slot = 0
pos = 0
line = ""
def run_ticker():
    global pos
    update_ticker()
    render_ticker()
    pos += 1

def render_ticker():
    global SCROLL_WIDTH
    print(line[pos:pos+SCROLL_WIDTH], flush=True)

def update_ticker():
    global SCROLL_RENDER, SCROLL_SEPARATOR
    global active_entries, visible_entries, slot, pos

    _, length = get_headline(visible_entries[0])
    if pos >= length:
        visible_entries.pop(0)
        slot = (slot + 1) % len(active_entries)
        visible_entries.append(active_entries[(slot + SCROLL_RENDER) % len(active_entries)])
        update_line()

def update_line():
    global line, visible_entries, pos
    line = SCROLL_SEPARATOR.join(get_headline(entry)[0] for entry in visible_entries)
    pos = 0

def get_headline(entry):
    global SCROLL_SEPARATOR
    headline = entry.get('headline')
    length = entry.get('length')
    if not headline:
        entry['headline'] = "[" + entry['publisher'] + "] " + entry['title']
        entry['length'] = len(entry['headline']) + len(SCROLL_SEPARATOR)
        return get_headline(entry)
    return headline, length

# RSS fetch

def periodic_fetch():
    while True:
        if is_connected(3):
            entries = parse_feeds()
            consolidate_entries(entries)
            time.sleep(FETCH_INTERVAL)
        else:
            time.sleep(15)

def parse_feeds():
    global feeds_parsed

    log(":: PARSING FEEDS ::")
    urls = get_feed_urls()
    entries = []

    for url in urls:
        parsing_splash(url)
        log("On URL " + url)
        for i in range(3):
            time.sleep(0.2)
            feed = parse_url(url)
            if feed is None:
                continue
            publisher = feed.feed.get('title')
            if not publisher:
                log("Couldn't get publisher name, retrying")
                continue
            for entry in feed.entries:
                entries.append({
                    'title': entry.title,
                    'publisher': publisher,
                    'date': entry.get("published_parsed") or entry.get("updated_parsed"),
                    'url': entry.link
                })
            log("Appended " + str(len(feed.entries)) + " entries")
            break

    feeds_parsed = True
    return entries

def parse_url(url):
    try:
        resp = requests.get(url, timeout=5)
    except requests.exceptions.RequestException as e:
        log(f"Network error - {e}")
        return None

    if resp.status_code != 200:
        log(f"HTTP error - {resp.status_code}")
        return None

    feed = feedparser.parse(resp.content)

    if feed.bozo:
        log(f"Parsing error - {feed.bozo_exception}")
        return None

    if not feed.entries:
        log("Feed has no entries")
        return None

    return feed

def parsing_splash(url):
    if not line:
        print("parsing " + urlparse(url).netloc.replace('www.', '') + "...", flush=True)

def consolidate_entries(entries):
    global MAX_ENTRIES, queued_entries

    log("Consolidating entries")

    new_entries = separate_new_entries(entries)
    queued_entries.extend(new_entries)

    log("Found " + str(len(new_entries)) + " new entries")
    log("Queued entries: " + str(len(queued_entries)) + "/" + str(MAX_ENTRIES))

    if len(queued_entries) >= MAX_ENTRIES:
        log("Updating active entries")
        update_active_entries()
        queued_entries.clear()

def update_active_entries():
    global MAX_ENTRIES, MIN_ENTRIES
    global active_entries, queued_entries, slot
    # group by publisher
    entries_by_publisher = defaultdict(list)
    for entry in queued_entries:
        entries_by_publisher[entry['publisher']].append(entry)
    # sort queued headlines
    for publisher in entries_by_publisher:
        sorted_entries = sorted(entries_by_publisher[publisher], key=lambda x: x['date'], reverse=True)
        entries_by_publisher[publisher] = sorted_entries
    # consolidate into one list
    entries = []
    publishers = entries_by_publisher.keys()
    max_per_publisher = max(math.ceil(MAX_ENTRIES / len(publishers)), 1)
    for publisher in publishers:
        added = 0
        for entry in entries_by_publisher[publisher]:
            entries.append(entry)
            added += 1
            if added >= max_per_publisher:
                break
    # set active entries and shuffle
    active_entries = entries[0:MAX_ENTRIES]
    import random
    random.shuffle(active_entries)
    # set slot back to 0
    slot = 0

seen_urls = set()
def separate_new_entries(entries):
    global seen_urls
    new_entries = []
    for e in entries:
        url = e['url']
        if url not in seen_urls:
            new_entries.append(e)
            seen_urls.add(url)
    return new_entries

feed_urls = []
def get_feed_urls():
    global feed_urls
    if (len(feed_urls) == 0):
        feed_urls = read_feed_repo()
    return feed_urls

def read_feed_repo():
    filepath = os.path.expanduser("~/.tilekitty/resources/user/feeds.txt")
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read().splitlines()
    return []

# util

def is_connected(timeout):
    try:
        socket.setdefaulttimeout(timeout)
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.connect(("8.8.8.8", 53))
        return True
    except OSError:
        return False

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {msg}", file=sys.stderr, flush=True)

# execute main

main()

