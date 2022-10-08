# rss.sh

## Introduction

Given a list of RSS feed URLs, `rss.sh` retrieve them and make a HTML for the posts, the most recent first.

## Usage

Edit `rss.sh` and insert the URLs, for example

```sh
cat >$FILE <<EOF
# Add your RSS feed URLs here
https://blog.regehr.org/feed
https://api.quantamagazine.org/feed/
EOF
```

To run the script, for example, to retrieve the blog posts in the last 10 days,

```sh
rss.sh -10d
```

it would generate a HTML and open it in the browser.
