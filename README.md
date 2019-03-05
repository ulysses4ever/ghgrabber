# GHGrabber

A small scraper for GitHub that grew.

## Requires

- GNU parallel
- GNU AWK 

```
    sudo apt install parallel gawk 
```

## Usage

```
    ./grab.sh [REPOSITORY LIST] [OUPUT DIRECTORY] [NUMBER OF PROCESSES]
```

## Example

```
    ./grab.sh repos/repo.list.00 /data/dejavuii/ghgrabber 16
```
