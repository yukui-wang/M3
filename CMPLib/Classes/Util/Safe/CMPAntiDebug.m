//
//  CMPAntiDebug.m
//  CMPLib
//
//  Created by CRMO on 2019/5/22.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPAntiDebug.h"

#import <dlfcn.h>
#import <sys/sysctl.h>
#import <mach/task.h>
#import <mach/mach_init.h>
#include <termios.h>
#include <sys/ioctl.h>
#import <sys/types.h>
#import "NSObject+Thread.h"

#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

static __attribute__((always_inline)) void asm_exit() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov w16, #1\n"
            "svc #0x80\n"
            
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret");
#else
    exit(-1);
#endif
}

static __attribute__((always_inline)) void AntiDebug_001() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

static __attribute__((always_inline)) void AntiDebug_003() {
    syscall(26,31,0,0,0);
}

static __attribute__((always_inline)) void AntiDebug_004() {
#ifdef __arm__
    asm volatile(
                 "mov r0,#31\n"
                 "mov r1,#0\n"
                 "mov r2,#0\n"
                 "mov r12,#26\n"
                 "svc #80\n"
                 );
#endif
#ifdef __arm64__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"
                 "svc #128\n"
                 );
#endif
}

// 需要轮询调用
static __attribute__((always_inline)) void AntiDebug_005() {
    struct macosx_exception_info{
        exception_mask_t masks[EXC_TYPES_COUNT];
        mach_port_t ports[EXC_TYPES_COUNT];
        exception_behavior_t behaviors[EXC_TYPES_COUNT];
        thread_state_flavor_t flavors[EXC_TYPES_COUNT];
        mach_msg_type_number_t cout;
    };
    struct macosx_exception_info *info = malloc(sizeof(struct macosx_exception_info));
    task_get_exception_ports(mach_task_self(),
                             EXC_MASK_ALL,
                             info->masks,
                             &info->cout,
                             info->ports,
                             info->behaviors,
                             info->flavors);
    for(uint32_t i = 0; i < info->cout; i ++){
        if(info->ports[i] != 0 || info->flavors[i] == THREAD_STATE_NONE){
            NSLog(@"debugger detected via exception ports (null port)!\n");
            asm_exit();
        }
    }
}

// 需要轮询调用
static __attribute__((always_inline)) void AntiDebug_006() {
    if (isatty(1)) {
        NSLog(@"Being Debugged isatty");
        asm_exit();
    }
}

// 需要轮询调用
static __attribute__((always_inline)) void AntiDebug_007() {
    if (!ioctl(1, TIOCGWINSZ)) {
        NSLog(@"Being Debugged ioctl");
        asm_exit();
    }
}

@implementation CMPAntiDebug

- (void)startAntiDebug {
    AntiDebug_001();
    AntiDebug_003();
    AntiDebug_004();
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(antiDebug) userInfo:nil repeats:YES];
//    [timer fire];
}

- (void)antiDebug {
    [self dispatchAsyncToChild:^{
        AntiDebug_005();
        AntiDebug_006();
        AntiDebug_007();
    }];
}

@end
