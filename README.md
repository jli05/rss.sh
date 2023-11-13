# rss.sh

## Introduction

Given a list of RSS feed URLs, `rss.sh` gets the RSS entries.

## Usage

Edit `urls.txt` and insert the feed URLs, for example

```sh
# Add your RSS feed URLs here
https://blog.regehr.org/feed
https://api.quantamagazine.org/feed/
```

To get the title, URL and dates of the blog posts in the above URLs, and sync to S3 or publish to SNS,

```sh
cat urls.txt | NPROC=$(nproc) WGET='wget -q -O -' SINCE='' S3_URI='' SNS_TOPIC='' rss.sh
```

If using `curl`, use `WGET='curl -sSL'` instead. `WGET` and `SINCE` are obligatory. If neither `S3_URI` or `SNS_TOPIC` is provided, the results will be printed to `stdout`.

## The Format of Feed XML It Expects

RSS 2.0 and Atom are supported. One example is taken from [https://vitalik.ca/feed.xml](https://vitalik.ca/feed.xml),

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
