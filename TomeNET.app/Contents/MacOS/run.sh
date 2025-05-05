#!/usr/bin/env bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/X11/bin

type Xquartz > /dev/null 2>&1 || {
 osascript -e "display dialog \"Need Xquartz\" with icon caution buttons {\"Ok\"}"
 open "https://www.xquartz.org"
 exit
}

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
	DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

RC=~/.tomenetrc
[ -e $RC ] || cp "$DIR/.tomenetrc" ~/

grep -q "^##not first time$" $RC || {
  echo "##not first time" >> $RC && \
  osascript -e "display dialog \"Do you prefer graphical-style font?
You can always change this later in the games options.\" with title \"TomeNET first start question\" \
buttons {\"Yes\", \"No\"} default button \"Yes\" cancel button \"No\" \
with icon POSIX file \"$DIR/../Resources/icon.icns\"" > /dev/null 2>&1 && {
    sed -i -e "s/^Mainwindow_Font.*$/Mainwindow_Font 14x20tg/" $RC
  }
}

xset fp+ "$DIR/fonts"
xset fp rehash

cd $DIR || exit
_arch="$(arch)"
export DYLD_LIBRARY_PATH="./$_arch"
./tomenet-$_arch &
