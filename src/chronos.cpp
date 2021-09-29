#include "chronos.h"

Chronos::Chronos(QObject *parent) :
    QObject(parent){
    setTime = 6;
    pauseTime.start();
}

// Chronos is started with running = true
void Chronos::setRunning(bool status){
    mRunning = status;
    if(status){
        startTime.start();
    }else{
        setTime = 6;
    }

    emit runningChanged(mRunning);
}

// Restart cycle with new time
void Chronos::setNewTime(int newTime){
    setTime = newTime;
    startTime.restart();
}

int Chronos::getTime(){
    return setTime - startTime.elapsed()/1000;
}

void Chronos::setPause(bool status){
    if(mRunning){
        paused = status;
        if(paused){
            pauseTime.restart();
        }else{
            startTime = startTime.addMSecs(pauseTime.elapsed());
        }

        emit pauseChanged(status);
    }
}
