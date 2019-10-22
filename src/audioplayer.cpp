#include "audioplayer.h"

AudioPlayer::AudioPlayer(QObject *parent) :
    QObject(parent){
    playlist = new QMediaPlaylist;
    player = new QMediaPlayer;
}

bool AudioPlayer::setSource(const QString &source){
    QFile inputList(QDir::homePath()+"/Music/playlists/"+source+".pls");
    if (inputList.open(QIODevice::ReadOnly)){
        playlist->clear();
        QTextStream in(&inputList);
        while ( !in.atEnd() ){
          QString line = in.readLine();
          if(line.at(0) == 'F'){
              while(line.at(0) != '=')
                  line.remove(0,1);
              line.remove(0,1);
              playlist->addMedia(QUrl(line));
          }
        }
        inputList.close();

        if(playlist->error()){
            qDebug() << playlist->errorString();
            return false;
        }else{
            playlist->setPlaybackMode(QMediaPlaylist::Loop);
            playlist->setCurrentIndex(1);
            player->setPlaylist(playlist);
            return true;
        }
    }else{
        qDebug() << "Cannot open source: "+source;
        return false;
    }
}

int AudioPlayer::play(){
    qDebug() << "Starting Player";
    player->play();
    return player->state();
}

void AudioPlayer::pause(){
    qDebug() << "Pausing Player";
    player->pause();
}

void AudioPlayer::stop(){
    player->stop();
}

void AudioPlayer::next(){
    playlist->next();
}

void AudioPlayer::shuffle(){
    qsrand(QDateTime::currentDateTime().toTime_t() );
    playlist->shuffle();
}
