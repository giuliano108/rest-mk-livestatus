# rest-mk-livestatus

Lets you query Nagios/[mk-livestatus](https://mathias-kettner.de/checkmk_livestatus.html) via a REST API.

Input is a JSON object that models `mk-livestatus`'s query language (see `@@schema` in `livestatus/querystring_builder.rb`).

Output is a JSON array.

## Run

```
bundle install
bundle exec rackup
```

## Use

Example: which services are not OK on the hosts that match the regexp?

```
curl -s -d '
{
  "table": "services",
  "columns": [
    "host_name",
    "display_name",
    "state"
  ],
  "filters": [
    {
      "column": "host_name",
      "op": "~",
      "value": "^host[1234].(dc1|dc2).domain.com"
    },
    {
      "column": "state",
      "op": ">",
      "value": "0"
    }
  ]
}' http://localhost:9292/livestatus/v1/myqueryname | jq .
[
  {
    "host_name": "host1.dc1.domain.com",
    "display_name": "service1",
    "state": "1"
  },
  {
    "host_name": "host3.dc2.domain.com",
    "display_name": "service1",
    "state": "2"
  }
]

```
