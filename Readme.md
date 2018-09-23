# noglog [![Build Status][travis-image]][travis-url] [![Go Report Card][goreport-image]][goreport-url] [![GoDoc][godoc-image]][godoc-url]

noglog is a replacement for [github.com/golang/glog][glog] implementation.

This package is a "bring you own" logger for glog replacement. It will replace all the glog calls with any logger that implements `noglog.Logger` interface.

You can go from this:

```text
ERROR: logging before flag.Parse: I0921 14:49:49.283733       1 leaderelection.go:175] attempting to acquire leader lease example-lock...
```

to this:

```text
INFO[0000] attempting to acquire leader lease  example-lock...  source=k8s src="leaderelection.go:175"
```

or whatever format you want (or don't show at all).

## Features

- Replace glog messages with your own logger (implement small interface and done).
- No [flags] modification.

## Getting Started

For a complete example, check [this][example]

### Import library

First we need to add noglog as dependency, but it will need to be placed on `github.com/golang/glog` import path, so `github.com/slok/noglog` code replaces `github.com/golang/glog`

#### Using go modules

```text
require (
    github.com/google/glog master
)

replace (
    github.com/google/glog => github.com/slok/noglog master
)
```

#### Using dep

```toml
[[override]]
  name = "github.com/golang/glog"
  source = "github.com/slok/noglog"
  branch = "master"
```

### Set our custom logger

Import glog and the first thing that your app should do is instantiate your logger and set as the glog logger. Example:

```golang
import (
    "github.com/golang/glog"
)

func main() {
    // Import custom logger that satisfies noglog.Logger interface.
    logger := mylogger.New()

    glog.SetLogger(logger)
}
```

For security reasons if you don't set a logger, it will use a dummy logger that will disable Kubernetes logs. Sometimes this is useful also.
Your custom logger needs to satisfy `noglog.Logger` interface.
You have a helper if you want to create a logger using functions instead of creating a new type, `noglog.LoggerFunc`.

This helper gives a lot of power to set up loggers easily. Some examples...

Logrus:

```golang
import (
    "github.com/google/glog"
    "github.com/sirupsen/logrus"
)

func main() {
    // Our app logger.
    logger := logrus.New()
    logger.SetLevel(logrus.DebugLevel)

    // Set our glog replacement.
    glog.SetLogger(&glog.LoggerFunc{
        DebugfFunc: func(f string, a ...interface{}) { logger.Debugf(f, a...) },
        InfofFunc:  func(f string, a ...interface{}) { logger.Infof(f, a...) },
        WarnfFunc:  func(f string, a ...interface{}) { logger.Warnf(f, a...) },
        ErrorfFunc: func(f string, a ...interface{}) { logger.Errorf(f, a...) },
    })

    glog.Info("I'm batman!")
}
```

Example for zap:

```golang
import (
    "github.com/google/glog"
    "go.uber.org/zap"
)

func main() {
    // Our app logger.
    logger, _ := zap.NewProduction()
    slogger := logger.Sugar()

    // Set our glog replacement.
    glog.SetLogger(&glog.LoggerFunc{
        DebugfFunc: func(f string, a ...interface{}) { slogger.Debugf(f, a...) },
        InfofFunc:  func(f string, a ...interface{}) { slogger.Infof(f, a...) },
        WarnfFunc:  func(f string, a ...interface{}) { slogger.Warnf(f, a...) },
        ErrorfFunc: func(f string, a ...interface{}) { slogger.Errorf(f, a...) },
    })

    glog.Info("I'm batman!")
}
```

Example for zerolog:

```golang
import (
    "os"

    "github.com/google/glog"
    "github.com/rs/zerolog"
)

func main() {
    // Our app logger.
    w := zerolog.ConsoleWriter{Out: os.Stderr}
    logger := zerolog.New(w).With().Timestamp().Logger()

    // Set our glog replacement.
    glog.SetLogger(&glog.LoggerFunc{
        DebugfFunc: func(f string, a ...interface{}) { logger.Debug().Msgf(f, a...) },
        InfofFunc:  func(f string, a ...interface{}) { logger.Info().Msgf(f, a...) },
        WarnfFunc:  func(f string, a ...interface{}) { logger.Warn().Msgf(f, a...) },
        ErrorfFunc: func(f string, a ...interface{}) { logger.Error().Msgf(f, a...) },
    })

    glog.Info("I'm batman!")
}
```

## Why

Glog is a logger used on some important projects like Kubernetes, Glog modifies globals like `flag` of your program and it can't be done nothing to disable, modify...

For example in Kubernetes glog is around all the source code, they don't use a common app logger interface that it can be reimplement with any log implementation, or pass any logger as dependency injection, so the Kubernetes extensions that use [client-go] will get flags modification, unstructured logs around it well set log format lines...

## When to use noglog

- Tired of glog logs.
- Every extension/app of Kubernetes I do has anoying unstructured logs.
- My app flags have glog flags that I didn't ask for.
- `ERROR: logging before flag.Parse: W0922` WTF when using a custom `flag.FlagSet`.

## Alternatives

Although noglog can use any logger due to the simple interface, there are other alternatives that replace the logger for a specific logger with defaults, if you don't want to bring your own or customize these loggers here are the alternatives:

- [glog-logrus]
- [istio-glog](zap)

[travis-image]: https://travis-ci.org/slok/noglog.svg?branch=master
[travis-url]: https://travis-ci.org/slok/noglog
[goreport-image]: https://goreportcard.com/badge/github.com/slok/noglog
[goreport-url]: https://goreportcard.com/report/github.com/slok/noglog
[godoc-image]: https://godoc.org/github.com/slok/noglog?status.svg
[godoc-url]: https://godoc.org/github.com/slok/noglog
[glog]: https://github.com/golang/glog
[client-go]: https://github.com/kubernetes/client-go
[flags]: https://golang.org/pkg/flag
[glog-logrus]: https://github.com/kubermatic/glog-logrus
[istio-glog]: https://github.com/istio/glog
[example]: /example
