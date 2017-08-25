#include "chronos.h"

Chronos::Chronos(QObject *parent) :
    QObject(parent){
    setTime = 6;
    pauseTime.start();
    activity = new BackgroundActivity(this);
    
    
}

Chronos::~Chronos()
{
    activity->stop();
}

// Chronos is started with running = true
void Chronos::setRunning(bool status){
    mRunning = status;
    if(status){
        startTime.start();
        activity->setWakeupFrequency(BackgroundActivity::Range);
        activity->run();
        keepAliveChanged(true);
    }else{
        setTime = 6;
        activity->stop();
        keepAliveChanged(false);
    }

    runningChanged(mRunning);
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

        pauseChanged(status);
    }
}

void Chronos::setKeepAlive(bool running)
{
    if(running){
        activity->setWakeupFrequency(BackgroundActivity::Range);
        activity->run();
        keepAliveChanged(true);
    }else{
        activity->stop();
        keepAliveChanged(false);
    }
}
