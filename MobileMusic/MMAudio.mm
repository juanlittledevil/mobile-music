//
//  MMAudio.m
//  MobileMusic
//
//  Created by Spencer Salazar on 6/27/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "MMAudio.h"
#import "mo_audio.h"
#import "FlareSound.h"


void audio_callback(Float32 * buffer, UInt32 numFrames, void * userData)
{
    MMAudio * mmaudio = (MMAudio *) userData;
    
    mmaudio->audio_callback(buffer, numFrames);
}

MMAudio * g_mmaudio = NULL;

MMAudio * MMAudio::instance()
{
    if(g_mmaudio == NULL)
        g_mmaudio = new MMAudio;
    return g_mmaudio;
}

MMAudio::MMAudio() :
addList(CircularBuffer<FlareSound *>(20)),
removeList(CircularBuffer<FlareSound *>(20))
{
    stk::Stk::setSampleRate(MOBILEMUSIC_SRATE);
}

void MMAudio::start()
{
    MoAudio::init(MOBILEMUSIC_SRATE, 512, 2);
    MoAudio::start(::audio_callback, this);    
    
    
//    wg = stk::BandedWG();
//    wg.setPreset(3);
//    wg.noteOn(220, 1.0);
//    wg.startBowing(1.0, 1.0);
}

void MMAudio::add(FlareSound * fs)
{
    addList.put(fs);
}

void MMAudio::remove(FlareSound * fs)
{
    removeList.put(fs);
}

void MMAudio::audio_callback(Float32 * buffer, UInt32 numFrames)
{
    FlareSound * fs = NULL;
    while(addList.get(fs))
        flareSounds.push_back(fs);
    while(removeList.get(fs))
    {
        flareSounds.remove(fs);
        fs->destroy();
        delete fs;
    }
          
    for(int i = 0; i < numFrames; i++)
    {
        // stereo interleaved operation
        float sample = 0;
        
        for(std::list<FlareSound *>::iterator i = flareSounds.begin(); i != flareSounds.end(); i++)
        {
            sample += (*i)->tick();
        }
        
        buffer[i*2] = sample;
        buffer[i*2+1] = sample;
    }
}

