#include "EAGLContextHelper.h"
#include "UnityRendering.h"

#if UNITY_USES_GLES

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

extern "C" bool AllocateRenderBufferStorageFromEAGLLayer(void* eaglContext, void* eaglLayer)
{
    return [(__bridge EAGLContext*)eaglContext renderbufferStorage: GL_RENDERBUFFER fromDrawable: (__bridge CAEAGLLayer*)eaglLayer];
}

extern "C" void DeallocateRenderBufferStorageFromEAGLLayer(void* eaglContext)
{
    // After deprecating OpenGL ES, Apple implement gles driver in metal.
    // Alas, it seem that on older iOS versions (< 13.0) there seems to be a bug in
    // [EAGLContext renderbufferStorage: fromDrawable:nil]
    // resulting in metal validation failure.
    // Thankfully this code path is taken only to delete the backbuffer, so this is not that bad:
    //   we go there only on exit/going-to-background or unloading unity library
    // If we look at the metal - all this would mean drawable recreation (and this happens inside gles driver)
    //  so memory-wise we should be still fine ignoring this completely
    if (UnityiOS130orNewer())
        [(__bridge EAGLContext*)eaglContext renderbufferStorage: GL_RENDERBUFFER fromDrawable: nil];
}

extern "C" EAGLContext* UnityCreateContextEAGL(EAGLContext * parent, int api)
{
    const int       targetApi   = parent ? parent.API : api;
    EAGLSharegroup* group       = parent ? parent.sharegroup : nil;

    return [[EAGLContext alloc] initWithAPI: (EAGLRenderingAPI)targetApi sharegroup: group];
}

extern "C" void UnityMakeCurrentContextEAGL(EAGLContext* context)
{
    [EAGLContext setCurrentContext: context];
}

extern "C" EAGLContext* UnityGetCurrentContextEAGL()
{
    return [EAGLContext currentContext];
}

EAGLContextSetCurrentAutoRestore::EAGLContextSetCurrentAutoRestore(EAGLContext* cur_) : old([EAGLContext currentContext]), cur(cur_)
{
    if (old != cur)
    {
        [EAGLContext setCurrentContext: cur];
        UnityOnSetCurrentGLContext(cur);
    }
}

EAGLContextSetCurrentAutoRestore::EAGLContextSetCurrentAutoRestore(UnityDisplaySurfaceBase* surface)
    : old(surface->api == apiMetal ? nil : [EAGLContext currentContext]),
    cur(surface->api == apiMetal ? nil : ((UnityDisplaySurfaceGLES*)surface)->context)
{
    if (old != cur)
    {
        [EAGLContext setCurrentContext: cur];
        UnityOnSetCurrentGLContext(cur);
    }
}

EAGLContextSetCurrentAutoRestore::~EAGLContextSetCurrentAutoRestore()
{
    if (old != cur)
    {
        [EAGLContext setCurrentContext: old];
        if (old)
            UnityOnSetCurrentGLContext(old);
    }
}

#else // UNITY_USES_GLES

extern "C" bool AllocateRenderBufferStorageFromEAGLLayer(void*, void*)      { return false; }
extern "C" void DeallocateRenderBufferStorageFromEAGLLayer(void*)           {}

extern "C" EAGLContext* UnityCreateContextEAGL(EAGLContext*, int)           { return NULL; }
extern "C" void         UnityMakeCurrentContextEAGL(EAGLContext*)           {}
extern "C" EAGLContext* UnityGetCurrentContextEAGL()                        { return NULL; }

EAGLContextSetCurrentAutoRestore::EAGLContextSetCurrentAutoRestore(EAGLContext*)                {}
EAGLContextSetCurrentAutoRestore::EAGLContextSetCurrentAutoRestore(UnityDisplaySurfaceBase*)    {}
EAGLContextSetCurrentAutoRestore::~EAGLContextSetCurrentAutoRestore()                           {}

#endif