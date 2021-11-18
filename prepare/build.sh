set -eo pipefail
BASEDIR=`cd $(dirname $0); pwd`

if [ ! -f "$BASEDIR/../.env" ]; then
    cp $BASEDIR/../.env-example $BASEDIR/../.env
fi

docker -v

cd $BASEDIR/../
docker-compose build

mkdir -p ~/bin
ln -s $BASEDIR/../run.sh ~/bin/docker-run

cat $BASEDIR/config/alias.txt >> ~/.zshrc
cat $BASEDIR/config/alias.txt >> ~/.bashrc
