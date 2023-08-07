
#import <Cocoa/Cocoa.h>


static void InstallHandleSIGTERMFromRunLoop(void)
    // This routine installs a SIGTERM handler that's called on the main thread, allowing 
    // it to then call into Cocoa to quit the app.
{
    static dispatch_once_t   sOnceToken;
    static dispatch_source_t sSignalSource;

    dispatch_once(&sOnceToken, ^{
        signal(SIGTERM, SIG_IGN);
    
        sSignalSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_main_queue());
        assert(sSignalSource != NULL);
        
        dispatch_source_set_event_handler(sSignalSource, ^{
            assert([NSThread isMainThread]);
            
            [[NSApplication sharedApplication] terminate:nil];
        });
        
        dispatch_resume(sSignalSource);
    });
}

int main(int argc, char *argv[])
{
    int retVal;
	InstallHandleSIGTERMFromRunLoop();
    retVal = NSApplicationMain(argc, (const char **) argv);
    return retVal;
}
