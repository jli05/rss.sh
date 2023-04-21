''' Read RSS entries from a list of URLs '''


def read_rss_entries(url):
    ''' Read RSS entries from given URL '''
    entries = []

    from warnings import warn
    try:
        from subprocess import Popen, PIPE
        proc = Popen(['curl', '-L', '-sS', url], text=True, stdout=PIPE)

        import xml.etree.ElementTree as ET
        tree = ET.fromstring(proc.stdout.read())

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
        warn(url)
        traceback.print_exc()

    if not entries:
        warn(f'{url}: 0 items')
    return entries


if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('--since')
    parser.add_argument('file', nargs='*',
                        help='file with URLs, one on each line')
    args = parser.parse_args()

    import fileinput
    urls = [line.strip() for line in fileinput.input(args.file)]
    urls = [url for url in urls
            if url and not url.startswith('#')]

    from functools import reduce
    entries = reduce(list.__add__, map(read_rss_entries, urls))
    entries = set(entries)
    if args.since:
        entries = filter(lambda t: t[0] >= args.since, entries)
    entries = sorted(entries, key=lambda t: t[0], reverse=True)
    for entry in entries:
        print(entry[1])
        print(entry[2])
        print(entry[0])
        print()
