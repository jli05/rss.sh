''' Read RSS entries from a list of URLs '''


def read_rss_entries(text):
    ''' Read RSS entries from given URL '''
    entries = []

    try:
        import xml.etree.ElementTree as ET
        tree = ET.fromstring(text.strip())

        NS = {'atom': 'http://www.w3.org/2005/Atom'}
        from pandas import to_datetime
        if tree.tag.endswith('rss'):                # RSS 2.0
            for item in tree.iter('item'):
                pubtime = to_datetime(item.find('pubDate').text)
                entries.append((str(pubtime),
                                item.find('title').text,
                                item.find('link').text))
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
