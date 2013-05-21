//
//  ProcessInfoController.m
//  ActivityMonitor++
//
//  Created by st on 21/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <mach/machine.h>
#import <mach/mach_types.h>
#import <mach/mach_init.h>
#import <dlfcn.h>
#import "AMLog.h"
#import "ProcessInfo.h"
#import "ProcessInfoController.h"

@interface ProcessInfoController()
- (NSArray*)getAllProcesses;
- (void)getCommandLine:(ProcessInfo*)process;
- (void)getProcessIcon:(ProcessInfo*)process;
@end

@implementation ProcessInfoController

#pragma mark - public

- (NSArray*)getProcesses
{    
    NSArray *processes = [self getAllProcesses];
    
    for (ProcessInfo *process in processes)
    {
        [self getCommandLine:process];
        [self getProcessIcon:process];
    }
    
    // TODO: need to figure out how to fetch per-process thread info in order to provide
    // for example how many threads a process is running.
    // Currently task_info() fails if I try to use pid other than current process.

    return processes;
}

#pragma mark - private

- (NSArray*)getAllProcesses
{
    size_t size, processCount;
    struct kinfo_proc *procs = NULL;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    
    if (sysctl(mib, 4, NULL, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl to retrieve size has failed", __PRETTY_FUNCTION__);
        return result;
    }
    
    procs = malloc(size);

    if (sysctl(mib, 4, procs, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl to retrieve processes has failed", __PRETTY_FUNCTION__);
        return result;
    }
    
    processCount = size / sizeof(struct kinfo_proc);
    result = [NSMutableArray arrayWithCapacity:processCount];
    
    for (NSUInteger i = 0; i < processCount; ++i)
    {
        ProcessInfo *process = [[ProcessInfo alloc] init];
        process.name = [NSString stringWithCString:procs[i].kp_proc.p_comm encoding:NSUTF8StringEncoding];
        process.pid = procs[i].kp_proc.p_pid;
        process.priority = procs[i].kp_proc.p_priority;
        process.status = procs[i].kp_proc.p_stat;
        process.startTime = procs[i].kp_proc.p_starttime.tv_sec;
        [result addObject:process];
    }

    return result;
}

- (void)getCommandLine:(ProcessInfo*)process
{
    int mib[3], argmax, nargs, c = 0;
    char *procargs, *cp, *sp, *np;
    size_t size;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_ARGMAX;
    size = sizeof(argmax);
    if (sysctl(mib, 2, &argmax, &size, NULL, 0) == -1)
    {
        AMWarn(@"%s: sysctl() of KERN_ARGMAX has failed.", __PRETTY_FUNCTION__);
        return;
    }
    
    procargs = malloc(argmax);
    if (procargs == NULL)
    {
        AMWarn(@"%s: malloc() has failed", __PRETTY_FUNCTION__);
        return;
    }
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROCARGS2;
    mib[2] = process.pid;
    
    size = argmax;
    if (sysctl(mib, 3, procargs, &size, NULL, 0) == -1)
    {
        // Failure here means it's a system process.
        process.commandLine = [NSString stringWithFormat:@"(%@)", process.name];
        return;
    }
    
    memcpy(&nargs, procargs, sizeof(nargs));
    cp = procargs + sizeof(nargs);
    
    for (; cp < &procargs[size]; cp++)
    {
        if (*cp == '\0')
        {
            break;
        }
    }
    
    if (cp == &procargs[size])
    {
        return;
    }
    
    // Skip trailing '\0' characters.
    for (; cp < &procargs[size]; cp++)
    {
        if (*cp != '\0')
        {
            break;
        }
    }
    
    if (cp == &procargs[size])
    {
        return;
    }
    
    // Save where argv[0] string starts.
    sp = cp;
    
    /*
     * Iterate through the '\0'-terminated strings and convert '\0' to ' '
     * until a string is found that has a '=' character in it (or there are
     * no more strings in procargs).  There is no way to deterministically
     * know where the command arguments end and the environment strings
     * start, which is why the '=' character is searched for as a heuristic.
     */
    for (np = NULL; c < nargs && cp < &procargs[size]; cp++) {
        if (*cp == '\0') {
            c++;
            if (np != NULL) {
                /* Convert previous '\0'. */
                *np = ' ';
            }
            /* Note location of current '\0'. */
            np = cp;
        }
    }
    
    /*
     * sp points to the beginning of the arguments/environment string, and
     * np should point to the '\0' terminator for the string.
     */
    if (np == NULL || np == sp) {
        /* Empty or unterminated string. */
        return;
    }
    
    /* Make a copy of the string. */
    process.commandLine = [NSString stringWithCString:sp encoding:NSUTF8StringEncoding];
    
    /* Clean up. */
    free(procargs);
}

- (void)getProcessIcon:(ProcessInfo*)process
{
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
#define UIKITPATH "/System/Library/Framework/UIKit.framework/UIKit"
    
    /* TODO: can't figure out how to fetch the icon... */
    /*
    mach_port_t *p;
    void *uikit = dlopen(UIKITPATH, RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() = dlsym(uikit, "SBSSpringBoardServerPort");
    p = (mach_port_t*)SBSSpringBoardServerPort();
    dlclose(uikit);
    
    void *sbserv = dlopen(SBSERVPATH, RTLD_LAZY);
    NSArray *(*SBSCopyApplicationDisplayIdentifiers)(mach_port_t *port, BOOL runningApps, BOOL debuggable) = dlsym(sbserv, "SBSCopyApplicationDisplayIdentifiers");
    void*(*SBDisplayIdentifierForPID)(mach_port_t *port, int pid, char *result) = dlsym(sbserv, "SBDisplayIdentifierForPID");
    void*(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(sbserv, "SBFrontmostApplicationDisplayIdentifier");
    void*(*SBGetIconPNGData)(mach_port_t *port, char *identifier, size_t *size) = dlsym(sbserv, "SBGetIconPNGData");
    
    char appId[256];
    SBDisplayIdentifierForPID(p, process.pid, appId);
    
    char *png = malloc(1000000);
    png[0] = 0x66;
    void *ptr = nil;
    size_t size = 0;
    ptr = SBGetIconPNGData(p, appId, &size);
    
    UIImage *img = [UIImage imageWithData:[NSData dataWithBytes:ptr length:size]];
    
    NSLog(@"%s", appId);
    NSString *idString = @"id389801252";
    
    NSString *numericIDStr = [idString substringFromIndex:2];
    NSString *urlStr = [NSString stringWithFormat:@""];
    */

    // Temporary placeholder.
    CGRect rect = CGRectMake(0, 0, 100, 100);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [[UIColor grayColor] setFill];
    UIRectFill(rect);
    process.icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
