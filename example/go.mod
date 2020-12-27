module example

go 1.15

require (
	github.com/google/glog v0.3.5-0.20180716071806-8d7a107d68c1
	github.com/rs/zerolog v1.9.1
	github.com/sirupsen/logrus v1.0.6
	go.uber.org/atomic v1.3.2 // indirect
	go.uber.org/multierr v1.1.0 // indirect
	go.uber.org/zap v1.9.1
	golang.org/x/crypto v0.0.0-20180910181607-0e37d006457b // indirect
	golang.org/x/sys v0.0.0-20180921163948-d47a0f339242 // indirect
)

replace github.com/google/glog => ../
