//
//  AMUtils_Tests.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <sys/sysctl.h>
//#import <mach/mach_host.h>
//#import <mach/task_info.h>
//#import <mach/task.h>
//#import <mach/machine.h>
//#import <mach/mach_types.h>
//#import <mach/mach_init.h>
//#import <dlfcn.h>

#import <XCTest/XCTest.h>
#import "AMUtils.h"

@interface AMUtils_Tests : XCTestCase
- (void)_doTestSysCtl64WithSpecifier:(char*)specifier forSuccess:(BOOL)success;
- (void)_doTestSysCtlChrWithSpecifier:(char*)specifier forSuccess:(BOOL)success;
@end

@implementation AMUtils_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)test_getSysCtl64WithSpecifier
{
    [self _doTestSysCtl64WithSpecifier:"hw.memsize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.ncpu" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.activecpu" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.physicalcpu" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.physicalcpu_max" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.logicalcpu" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.logicalcpu_max" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.tbfrequency" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.cpufrequency" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.cpufrequency_max" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.cpufrequency_min" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.busfrequency" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.busfrequency_max" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.busfrequency_min" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.cputype" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.cpusubtype" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.cputhreadtype" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.byteorder" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.pagesize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.cachelinesize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.l1dcachesize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.l1icachesize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.l2cachesize" forSuccess:YES];
    [self _doTestSysCtl64WithSpecifier:"hw.l3cachesize" forSuccess:NO];
    [self _doTestSysCtl64WithSpecifier:"hw.packages" forSuccess:YES];
}

- (void)test_getSysCtlChrWithSpecifier
{
    [self _doTestSysCtlChrWithSpecifier:"hw.machine" forSuccess:YES];
    [self _doTestSysCtlChrWithSpecifier:"hw.machinemodel" forSuccess:NO];
    [self _doTestSysCtlChrWithSpecifier:"hw.machinearch" forSuccess:NO];
    
    // iOS 9 doesn't allow a sandboxed app to retrieve all processes anymore.
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    [self _doTestSysCtl:mib specifiedCount:4 forSuccess:NO];
}

- (void)test_percentageValue
{
    CGFloat max = 100.0;
    CGFloat min = 0.0;
    CGFloat percent = 20.0;
    CGFloat expected = 20.0;
    
    XCTAssertTrue([AMUtils percentageValueFromMax:max min:min percent:percent] == expected, @"AMUtils::percentageValueFromMax is dodgy (1)");
}

- (void)test_valuePercent
{
    CGFloat from = 50.0;
    CGFloat to = 100.0;
    CGFloat value = 60.0;
    CGFloat expected = 20.0;
    
    XCTAssertTrue([AMUtils valuePercentFrom:from to:to value:value] == expected, @"AMUtils::valuePercentFrom is dodgy");
}

#pragma mark - private

- (void)_doTestSysCtl64WithSpecifier:(char*)specifier forSuccess:(BOOL)success
{
    uint64_t val1, val2, val3;
    
    val1 = [AMUtils getSysCtl64WithSpecifier:specifier];
    val2 = [AMUtils getSysCtl64WithSpecifier:specifier];
    val3 = [AMUtils getSysCtl64WithSpecifier:specifier];
    
    if (success)
    {
        XCTAssertTrue(val1 == val2, @"'%s' is dodgy.", specifier);
        XCTAssertTrue(val2 == val3, @"'%s' is dodgy.", specifier);
        XCTAssertTrue(val1 != -1, @"'%s' failed.", specifier);
        XCTAssertTrue(val2 != -1, @"'%s' failed.", specifier);
        XCTAssertTrue(val3 != -1, @"'%s' failed.", specifier);
    }
    else
    {
        XCTAssertTrue(val1 == -1, @"'%s' failed. Expected: -1. Got: %llu", specifier, val1);
        XCTAssertTrue(val2 == -1, @"'%s' failed. Expected: -1. Got: %llu", specifier, val2);
        XCTAssertTrue(val3 == -1, @"'%s' failed. Expected: -1. Got: %llu", specifier, val3);
    }
}

- (void)_doTestSysCtlChrWithSpecifier:(char*)specifier forSuccess:(BOOL)success
{
    NSString *val1, *val2, *val3;
    
    val1 = [AMUtils getSysCtlChrWithSpecifier:specifier];
    val2 = [AMUtils getSysCtlChrWithSpecifier:specifier];
    val3 = [AMUtils getSysCtlChrWithSpecifier:specifier];
    
    if (success)
    {
        XCTAssertNotNil(val1, @"'%s' is dodgy: val1 == nil", specifier);
        XCTAssertNotNil(val2, @"'%s' is dodgy: val2 == nil", specifier);
        XCTAssertNotNil(val3, @"'%s' is dodgy: val3 == nil", specifier);
        XCTAssertTrue([val1 isEqualToString:val2], @"'%s' is dodgy: val1 != val2", specifier);
        XCTAssertTrue([val2 isEqualToString:val3], @"'%s' is dodgy: val2 != val3", specifier);
        XCTAssertFalse([val1 isEqualToString:@""], @"'%s' failed. val1 is empty", specifier);
        XCTAssertFalse([val2 isEqualToString:@""], @"'%s' failed: val2 is empty", specifier);
        XCTAssertFalse([val3 isEqualToString:@""], @"'%s' failed: val3 is empty", specifier);
    }
    else
    {
        XCTAssertNotNil(val1, @"'%s' is dodgy: val1 == nil", specifier);
        XCTAssertNotNil(val2, @"'%s' is dodgy: val2 == nil", specifier);
        XCTAssertNotNil(val3, @"'%s' is dodgy: val3 == nil", specifier);
        XCTAssertTrue([val1 isEqualToString:@""], @"'%s' failed. val1 is empty", specifier);
        XCTAssertTrue([val2 isEqualToString:@""], @"'%s' failed: val2 is empty", specifier);
        XCTAssertTrue([val3 isEqualToString:@""], @"'%s' failed: val3 is empty", specifier);
    }
}

- (void)_doTestSysCtl:(int *)specifier specifiedCount:(int)count forSuccess:(BOOL)success
{
    size_t size;
    int result = sysctl(specifier, count, NULL, &size, NULL, 0);
    if (success && result == -1)
    {
        XCTFail("Expected success, but got failure. Failed to run sysctl with %d specifiers.", count);
    }
    else if (!success && result != -1)
    {
        XCTFail("Expected failure, but got success. Good news!");
    }
}

@end
