//
//  AMUtils_Tests.m
//  ActivityMonitor++
//
//  Created by st on 07/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <sys/sysctl.h>
#import "AMUtils.h"
#import "AMUtils_Tests.h"

@interface AMUtils_Tests()
- (void)_doTestSysCtl64WithSpecifier:(char*)specifier forSuccess:(BOOL)success;
- (void)_doTestSysCtlChrWithSpecifier:(char*)specifier forSuccess:(BOOL)success;
@end

@implementation AMUtils_Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
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
}

- (void)test_percentageValue
{
    float max = 100.0f;
    float min = 0.0f;
    float percent = 20.0f;
    float expected = 20.0f;
    
    STAssertTrue([AMUtils percentageValueFromMax:max min:min percent:percent] == expected, @"AMUtils::percentageValueFromMax is dodgy (1)");
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
        STAssertTrue(val1 == val2, @"'%s' is dodgy.", specifier);
        STAssertTrue(val2 == val3, @"'%s' is dodgy.", specifier);
        STAssertTrue(val1 != -1, @"'%s' failed.", specifier);
        STAssertTrue(val2 != -1, @"'%s' failed.", specifier);
        STAssertTrue(val3 != -1, @"'%s' failed.", specifier);
    }
    else
    {
        STAssertTrue(val1 == -1, @"'%s' failed.", specifier);
        STAssertTrue(val2 == -1, @"'%s' failed.", specifier);
        STAssertTrue(val3 == -1, @"'%s' failed.", specifier);
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
        STAssertNotNil(val1, @"'%s' is dodgy: val1 == nil", specifier);
        STAssertNotNil(val2, @"'%s' is dodgy: val2 == nil", specifier);
        STAssertNotNil(val3, @"'%s' is dodgy: val3 == nil", specifier);
        STAssertTrue([val1 isEqualToString:val2], @"'%s' is dodgy: val1 != val2", specifier);
        STAssertTrue([val2 isEqualToString:val3], @"'%s' is dodgy: val2 != val3", specifier);
        STAssertFalse([val1 isEqualToString:@""], @"'%s' failed. val1 is empty", specifier);
        STAssertFalse([val2 isEqualToString:@""], @"'%s' failed: val2 is empty", specifier);
        STAssertFalse([val3 isEqualToString:@""], @"'%s' failed: val3 is empty", specifier);
    }
    else
    {
        STAssertNotNil(val1, @"'%s' is dodgy: val1 == nil", specifier);
        STAssertNotNil(val2, @"'%s' is dodgy: val2 == nil", specifier);
        STAssertNotNil(val3, @"'%s' is dodgy: val3 == nil", specifier);
        STAssertTrue([val1 isEqualToString:@""], @"'%s' failed. val1 is empty", specifier);
        STAssertTrue([val2 isEqualToString:@""], @"'%s' failed: val2 is empty", specifier);
        STAssertTrue([val3 isEqualToString:@""], @"'%s' failed: val3 is empty", specifier);
    }
}

@end
