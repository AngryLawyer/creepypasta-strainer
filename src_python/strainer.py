import sqlite3
import requests
from random import sample
import textwrap
from printer import ThermalPrinter

LINE_WIDTH = 32
potm = "http://creepypasta.wikia.com/api/v1/Articles/List?category=PotM&limit=1000"
spotlighted = "http://creepypasta.wikia.com/api/v1/Articles/List?category=Spotlighted_Pastas&limit=1000"

def get_json_from_url(url):
    return requests.get(url).json()

def get_ids_from_article_list(data):
    return [item['id'] for item in data['items']]

def get_ids_from_url(url):
    data = get_json_from_url(url)
    return get_ids_from_article_list(data)

def get_id_list():
    each = get_ids_from_url(potm) + get_ids_from_url(spotlighted)
    return each

def get_newest_story(c, story_list):
    if len(story_list) == 0:
        return "NO STORIES FOUND"
    first = story_list[0]
    c.execute("INSERT INTO `visited` (`source`, `source_id`) VALUES (?, ?)", ('creepypasta.wikia.com', first))
    story_data = get_json_from_url("http://creepypasta.wikia.com/api/v1/Articles/AsSimpleJson?id=%s" % first)
    return story_data

def strip_printed_stories(c, story_list, source):
    existing_ids = [item[0] for item in c.execute("SELECT source_id FROM `visited` WHERE `source`='%s'" % source)]
    return [story for story in story_list if story not in existing_ids]

def parse_list_item(item):
    return textwrap.fill("* %s" % item['text'], LINE_WIDTH)

def parse_content_item(item):
    if item['type'] == 'paragraph':
        return textwrap.fill(item['text'], LINE_WIDTH)
    elif item['type'] == 'list':
        return "\n".join(parse_list_item(li) for li in item['elements'])
    return ''

def parse_content_list(section):
    return "\n".join(parse_content_item(item) for item in section['content'])

def parse_title(section):
    # CENTRE ME
    return "\n" + textwrap.fill(section['title'], LINE_WIDTH)

def parse_section(section):
    return "\n".join([parse_title(section), parse_content_list(section)])

def parse_story(data):
    sections = [parse_section(section) for section in data['sections']]
    return "\n".join(sections)

conn = sqlite3.connect('creepypasta.db')
c = conn.cursor()

ids = get_id_list()
stripped = strip_printed_stories(c, ids, "creepypasta.wikia.com")
shuffled = sample(ids, len(ids))
newest = get_newest_story(c, shuffled)

printer = ThermalPrinter()
printer.print_text(newest)

conn.commit()
conn.close()
