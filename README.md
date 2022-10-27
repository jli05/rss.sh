# rss.sh

## Introduction

Given a list of RSS feed URLs, `rss.sh` retrieve them and make a HTML for the posts, the most recent first.

### Bring Your Own URLs

Edit `rss.sh` and insert the feed URLs, for example

```sh
cat >$FILE <<EOF
# Add your RSS feed URLs here
https://blog.regehr.org/feed
https://api.quantamagazine.org/feed/
EOF
```

To retrieve the blog posts in the last 10 days,

```sh
rss.sh -10d
```

it would generate a HTML and open it in the browser.

## The Format of Feed XML It Expects

Taken from [https://vitalik.ca/feed.xml](https://vitalik.ca/feed.xml),

```xml
<?xml version="1.0" ?>
<rss version="2.0">
<channel>
  <title>Vitalik Buterin's website</title>
  <link>https://vitalik.ca/</link>
  <description>Vitalik Buterin's website</description>
  <image>
      <url>http://vitalik.ca/images/icon.png</url>
      <title>Vitalik Buterin's website</title>
      <link>https://vitalik.ca/</link>
  </image>

<item>
<title>DAOs are not corporations: where decentralization in autonomous organizations matters</title>
<link>https://vitalik.ca/general/2022/09/20/daos.html</link>
<guid>https://vitalik.ca/general/2022/09/20/daos.html</guid>
<pubDate>Tue, 20 Sep 2022 00:00:00 +0000</pubDate>
<description></description>
</item>

<item>
...
</item>

</channel>
</rss>
```
