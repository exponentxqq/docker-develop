set -eo pipefail
BASEDIR=`cd $(dirname $0); pwd`

if [ ! -f "$BASEDIR/../.env" ]; then
    echo env file not exists
    exit 1
fi

docker -v

cd $BASEDIR/../
docker-compose build

mkdir -p ~/bin
ln -s $BASEDIR/../run.sh ~/bin/docker-run

cat $BASEDIR/config/alias.txt >> ~/.zshrc
cat $BASEDIR/config/alias.txt >> ~/.bashrc
