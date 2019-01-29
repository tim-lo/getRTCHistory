# About getRTCHistory
Simple bash script which produces changesets history of components of RTC/Jazz repository stream for [rtc2git](https://github.com/rtcTo/rtc2git).

## Preconditions:
* JAZZ SCM tool needs to be installed in your environment & added into paths
* You can download it from: https://jazz.net/downloads/rational-team-concert/, select the apropriate version, and then click on `More download options`, search for `SCM Tool`, select one for your OS, and download it.

## Usage:
```bash
./getRTCHistory.sh [Jazz Repository URL] [Project Area] [Name of Stream to be migrated] [Username] [Password]
```

e.g:
```bash
./getRTCHistory.sh "https://rtc-server.com/jazz/" "My Project Area" "My Awesome Stream" "tomas.kramaric@sk.ibm.com" "password"
```

## Tested with:
* RTC/Jazz 6.0.1
* macOS Sierra v.10.12.1 
