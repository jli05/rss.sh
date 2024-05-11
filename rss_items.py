''' Read RSS entries from a list of URLs '''


def read_rss_entries(text):
    ''' Read RSS entries from given URL '''
    entries = []

    try:
        import xml.etree.ElementTree as ET
        tree = ET.fromstring(text.strip())

        NS = {'atom': 'http://www.w3.org/2005/Atom',
              'rss': 'http://purl.org/rss/1.0/',
              'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
              'dc': 'http://purl.org/dc/elements/1.1/'}
        from pandas import to_datetime
        if tree.tag.endswith('rss'):                # RSS 2.0
            for item in tree.iter('item'):
                pubtime = to_datetime(item.find('pubDate').text)
                entries.append((str(pubtime),
                                item.find('title').text,
                                item.find('link').text))
        elif tree.tag.endswith('RDF'):
            for item in tree.iterfind('rss:item', NS):
                pubtime = to_datetime(item.find('dc:date', NS).text)
                entries.append((str(pubtime),
                                item.find('rss:title', NS).text,
                                item.find('rss:link', NS).text))
        elif tree.tag.endswith('feed'):             # Atom
            for item in tree.iterfind('atom:entry', NS):
                pubtime = to_datetime(item.find('atom:updated', NS).text)
                entries.append((str(pubtime),
                                item.find('atom:title', NS).text,
                                item.find('atom:link', NS).attrib['href']))
        else:
            raise NotImplementedError(tree.tag)
    except:
        import traceback
        traceback.print_exc()

    if not entries:
        from warnings import warn
        warn('no items')
    return entries


if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('--since')
    parser.add_argument('file', nargs='?',
                        help="when ignored or '-' for stdin")
    args = parser.parse_args()

    if args.file and args.file != '-':
        with open(args.file) as f:
            text = f.read().strip()
    else:
        from sys import stdin
        text = stdin.read().strip()

    entries = read_rss_entries(text)
    if args.since:
        entries = filter(lambda t: t[0] >= args.since, entries)
    for entry in entries:
        print(f'{entry[1]}\n{entry[2]}\n{entry[0]}\n')
