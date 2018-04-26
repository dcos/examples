# How to use httpbin on DC/OS

[httpbin](https://github.com/kennethreitz/httpbin) is an HTTP Request &
Response Service, written in Python with the Flask framework. Basically, it's
an HTTP server that responds in predictable ways to special HTTP requests and
echoes back a lot of the data given to it, so that a developer can see what
HTTP client code is doing -- e.g.: what request headers are being set and such.
It is also a fairly simple application and thus it's interesting to look at as
an example of how to package and deploy applications on DC/OS.

- Estimated time for completion: 3 minutes
- Target audience: Software developers who want to use httpbin to test their
  HTTP client code
- Scope: Install and use httpbin in DC/OS.

**Table of Contents**

- [Prerequisites](#prerequisites)
- [Install httpbin](#install-httpbin)
- [Use httpbin](#use-httpbin)
- [Uninstall httpbin](#uninstall-httpbin)

## Prerequisites

- A running DC/OS 1.11 cluster.
- [DC/OS CLI](https://docs.mesosphere.com/1.11/cli/) installed.

## Install httpbin

If you want to access httpbin from outside of the DC/OS cluster you can use
[Marathon-LB](https://docs.mesosphere.com/services/marathon-lb/),
which is recommended for production usage.

In the following we will use the DC/OS [Admin
Router](https://docs.mesosphere.com/1.11/developing-services/)
to provide access to httpbin, which is fine for dev/test setups:

```bash
$ dcos package install httpbin
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies. Preview packages should never be used in production!
Continue installing? [yes/no] yes
Installing Marathon app for package [httpbin] version [1.0.0]
DC/OS httpbin is being installed!

	Documentation: https://github.com/Runscope/httpbin
```

After this, you should see the httpbin service running via the `Services` tab of the DC/OS UI:

![httpbin DC/OS service](img/services.png)

## Use httpbin

From detailed view (clicking on the external icon) link leads to httpbin:

![httpbin UI](img/click.png)

![httpbin UI](img/httpbin-ui.png)

Please be aware that the links, as they are abolute, will not work in this UI.

To get started with httpbin you can do some HTTP requests with HTTPie or curl.

First we will need to authenticate dcos-cli with your cluster, so that we can
get the Authorization token we need to communicate with the cluster:

```
$ dcos auth login
```

Now you can do an HTTP request to httpbin's `/get` endpoint.

```
$ curl -H "Authorization: token=$(dcos config show core.dcos_acs_token)" -H "Hello: World" $(dcos config show core.dcos_url)/service/httpbin/get
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Authorization": "token=eyJhbGciOiJIUzI1NiIsImtpZCI6InNl....",
    "Connection": "upgrade",
    "Hello": "World",
    "Host": "m1.dcos",
    "User-Agent": "curl/7.52.1"
  },
  "origin": "192.168.65.1",
  "url": "http://m1.dcos/get"
}

```

Note how httpbin returns back in the JSON response tons of info about the
request it received, including among other things, the standard headers sent by
`curl` as well as the custom `Hello` header that we specified.

As another example, try using httpbin's `/delay/:seconds` endpoint:

```
$ time curl -H "Authorization: token=$(dcos config show core.dcos_acs_token)" -H "Hello: World" $(dcos config show core.dcos_url)/service/httpbin/delay/3
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Authorization": "token=eyJhbGciOiJIUzI1NiIsImtpZCI6InNlY3JldCIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIzeUY1VE9TemRsSTQ1UTF4c3B4emVvR0JlOWZOeG05bSIsImVtYWlsIjoiY2dhbGlzdGVvQHN0cmF0aW8uY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImV4cCI6MTUwOTM1ODg3NiwiaWF0IjoxNTA4OTI2ODc2LCJpc3MiOiJodHRwczovL2Rjb3MuYXV0aDAuY29tLyIsInN1YiI6Imdvb2dsZS1vYXV0aDJ8MTEwMzYyODIzOTM3OTgwOTY0NTU4IiwidWlkIjoiY2dhbGlzdGVvQHN0cmF0aW8uY29tIn0.GbUjyr7hQFeSLO9jK75oHcNKywEHTdHd1bmw_zGjEv4",
    "Connection": "upgrade",
    "Hello": "World",
    "Host": "m1.dcos",
    "User-Agent": "curl/7.52.1"
  },
  "origin": "192.168.65.1",
  "url": "http://m1.dcos/delay/3"
}

real    0m3,733s
user    0m0,828s
sys     0m0,068s
```

Here httpbin delayed the respone by 3 seconds. This can be useful if working on
code that makes HTTP requests and you want to simulate an unresponsive server.

## Uninstall httpbin

To uninstall httpbin:

```bash
$ dcos package uninstall httpbin
```

## Further resources

1. [httpbin GitHub repo](https://github.com/kennethreitz/httpbin)
1. [httpbin.org](http://httpbin.org/)
